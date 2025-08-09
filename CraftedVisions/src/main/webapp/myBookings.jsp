<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String email = (String) session.getAttribute("email");
    String username = null;
    boolean loggedIn = false;

    if (email == null) {
        response.sendRedirect("Login.html");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "root", "root15");
        PreparedStatement ps = conn.prepareStatement("SELECT name FROM users WHERE email = ?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            username = rs.getString("name");
            loggedIn = true;
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Bookings - Crafted Visions</title>
    <link rel="stylesheet" href="css/mybookings.css">
</head>
<body>
    <div class="header">
        <div class="logo">
            <img src="images/logo.png" alt="Palette Icon" />
            Crafted Visions
        </div>
        <div class="header-buttons">
            <button id="myBookingsBtn">My Bookings</button>
            <button id="logoutBtn">Log Out</button>
        </div>
    </div>
    <div class="container">
        <a href="Home.jsp" class="back-btn">&larr; Back to Home</a>
        <h2>My Bookings</h2>
        <table>
            <tr>
                <th>Professional Name</th>
                <th>Profession</th>
                <th>Booking Time</th>
                <th>Status</th>
            </tr>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "root", "root15");
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT b.booking_time, b.status, p.name, p.profession " +
                        "FROM bookings b JOIN professionals p ON b.professional_email = p.email " +
                        "WHERE b.user_email = ? ORDER BY b.booking_time DESC"
                    );
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();
                    boolean hasBookings = false;
                    while (rs.next()) {
                        hasBookings = true;
                        String professionalName = rs.getString("name");
                        String profession = rs.getString("profession");
                        String bookingTime = rs.getString("booking_time");
                        String status = rs.getString("status");
            %>
            <tr>
                <td><%= professionalName %></td>
                <td><%= profession %></td>
                <td><%= bookingTime %></td>
                <td class="status-<%= status %>"><%= status.substring(0,1).toUpperCase() + status.substring(1) %></td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
                    conn.close();
                    if (!hasBookings) {
            %>
            <tr>
                <td colspan="4" style="text-align:center;">No bookings yet.</td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='4'>Error loading bookings.</td></tr>");
                }
            %>
        </table>
    </div>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var myBookingsBtn = document.getElementById('myBookingsBtn');
        if (myBookingsBtn) {
            myBookingsBtn.onclick = function() {
                window.location.href = 'myBookings.jsp';
            };
        }
        var logoutBtn = document.getElementById('logoutBtn');
        if (logoutBtn) {
            logoutBtn.onclick = function() {
                window.location.href = 'Logout.html';
            };
        }
    });
    </script>
</body>
</html>