<%@ page import="java.sql.*" %>
<%
    // Session and user info for navbar
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("Login.html");
        return;
    }
    String username = null;
    boolean loggedIn = false;
    boolean isProfessional = false;
    int bookingCount = 0;

    if (email != null) {
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

            PreparedStatement ps2 = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM professionals WHERE email = ?");
            ps2.setString(1, email);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next() && rs2.getInt("cnt") > 0) {
                isProfessional = true;
            }
            rs2.close();
            ps2.close();

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
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dancers - Crafted Visions</title>
    <link rel="stylesheet" href="css/profession.css">
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
            <button onclick="window.location.href='upload.jsp'">Upload</button>
        </div>
    </div>

    <div class="main-content">
        <h2>Dancers</h2>
        <div class="cards-grid">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "root", "root15");
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT name, bio, social_link, email FROM professionals WHERE profession = ?"
                    );
                    ps.setString(1, "Dancer");
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        String proName = rs.getString("name");
                        String proBio = rs.getString("bio");
                        String socialLink = rs.getString("social_link");
                        String proEmail = rs.getString("email");
            %>
            <div class="pro-card">
                <h4><%= proName %></h4>
                <p><%= proBio %></p>
                <% if(socialLink != null && !socialLink.trim().isEmpty()) { %>
                    <a class="social-link" href="<%= socialLink %>" target="_blank">View Social Media</a>
                <% } %>
                <form action="BookProfessionalServlet" method="post">
                    <input type="hidden" name="proEmail" value="<%= proEmail %>">
                    <button type="submit">Book</button>
                </form>
            </div>
            <%
                    }
                    rs.close();
                    ps.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<p>Error loading professionals.</p>");
                }
            %>
        </div>
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