<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String email = (String) session.getAttribute("email");
    String username = null;
    boolean loggedIn = false;
    boolean isProfessional = false;
    int bookingCount = 0;

    if (email == null) {
        response.sendRedirect("Login.html");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "root", "root15");

        // Get username
        PreparedStatement ps = conn.prepareStatement("SELECT name FROM users WHERE email = ?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            username = rs.getString("name");
            loggedIn = true;
        }
        rs.close();
        ps.close();

        // Check if professional
        PreparedStatement ps2 = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM professionals WHERE email = ?");
        ps2.setString(1, email);
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next() && rs2.getInt("cnt") > 0) {
            isProfessional = true;
        }
        rs2.close();
        ps2.close();

        // Get pending booking count if professional
        if (isProfessional) {
            PreparedStatement ps3 = conn.prepareStatement(
                "SELECT COUNT(*) AS bcnt FROM bookings WHERE professional_email = ? AND status = 'pending'"
            );
            ps3.setString(1, email);
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) {
                bookingCount = rs3.getInt("bcnt");
            }
            rs3.close();
            ps3.close();
        }
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Bookings - Crafted Visions</title>
    <link rel="stylesheet" href="css/viewbookings.css">
</head>
<body>
    <div class="header">
        <div class="logo">
            <img src="images/logo.png" alt="Palette Icon" />
            Crafted Visions
        </div>
        <div class="header-buttons">
            <%
                if (loggedIn) {
                    if (isProfessional) {
            %>
                <button id="myBookingsBtn">My Bookings (<%= bookingCount %>)</button>
            <%
                    }
            %>
                <button id="logoutBtn">Log Out</button>
            <%
                } else {
            %>
                <button id="loginBtn">Log In</button>
                <button id="registerBtn">Register</button>
            <%
                }
            %>
        </div>
    </div>
    <div class="container">
        <a href="Home.jsp" class="back-btn">&larr; Back to Home</a>
        <h2>My Bookings</h2>
        <table>
            <tr>
                <th>Client Name</th>
                <th>Client Email</th>
                <th>Phone</th>
                <th>Booking Time</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "root", "root15");
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT b.id, b.user_email, b.booking_time, b.status, u.name, u.phonenumber " +
                        "FROM bookings b JOIN users u ON b.user_email = u.email " +
                        "WHERE b.professional_email = ? ORDER BY b.booking_time DESC"
                    );
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();
                    boolean hasBookings = false;
                    while (rs.next()) {
                        hasBookings = true;
                        int bookingId = rs.getInt("id");
                        String userEmail = rs.getString("user_email");
                        String bookingTime = rs.getString("booking_time");
                        String status = rs.getString("status");
                        String clientName = rs.getString("name");
                        String phone = rs.getString("phonenumber");
            %>
            <tr>
                <td><%= clientName %></td>
                <td>
                    <% if ("accepted".equals(status)) { %>
                        <%= userEmail %>
                    <% } else { %>
                        <span>Hidden</span>
                    <% } %>
                </td>
                <td>
                    <% if ("accepted".equals(status)) { %>
                        <%= phone %>
                    <% } else { %>
                        <span>Hidden</span>
                    <% } %>
                </td>
                <td><%= bookingTime %></td>
                <td class="status-<%= status %>"><%= status.substring(0,1).toUpperCase() + status.substring(1) %></td>
                <td>
                    <% if ("pending".equals(status)) { %>
                        <form method="post" action="BookingActionServlet" style="display:inline;">
                            <input type="hidden" name="bookingId" value="<%= bookingId %>">
                            <input type="hidden" name="action" value="accept">
                            <button class="btn accept" type="submit">Accept</button>
                        </form>
                        <form method="post" action="BookingActionServlet" style="display:inline;">
                            <input type="hidden" name="bookingId" value="<%= bookingId %>">
                            <input type="hidden" name="action" value="reject">
                            <button class="btn reject" type="submit">Reject</button>
                        </form>
                    <% } else { %>
                        <span>-</span>
                    <% } %>
                </td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
                    conn.close();
                    if (!hasBookings) {
            %>
            <tr>
                <td colspan="6" style="text-align:center;">No bookings yet.</td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='6'>Error loading bookings.</td></tr>");
                }
            %>
        </table>
    </div>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var myBookingsBtn = document.getElementById('myBookingsBtn');
        if (myBookingsBtn) {
            myBookingsBtn.onclick = function() {
                window.location.href = 'viewBookings.jsp';
            };
        }
        var logoutBtn = document.getElementById('logoutBtn');
        if (logoutBtn) {
            logoutBtn.onclick = function() {
                window.location.href = 'Logout.html';
            };
        }
        var loginBtn = document.getElementById('loginBtn');
        if (loginBtn) {
            loginBtn.onclick = function() {
                window.location.href = 'Login.html';
            };
        }
        var registerBtn = document.getElementById('registerBtn');
        if (registerBtn) {
            registerBtn.onclick = function() {
                window.location.href = 'Register.html';
            };
        }
    });
    </script>
</body>
</html>