<%@ page import="java.sql.*" %>
<%
    // Session and user info for navbar
    String email = (String) session.getAttribute("email");
    String username = null;
    boolean loggedIn = false;
    boolean isProfessional = false;
    int bookingCount = 0;

    if (email != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "root", "root15");

            PreparedStatement ps = conn.prepareStatement("SELECT name, phonenumber FROM users WHERE email = ?");
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            String phonenumber = "";
            if (rs.next()) {
                username = rs.getString("name");
                phonenumber = rs.getString("phonenumber");
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
    <title>Become a Professional - Crafted Visions</title>
    <link rel="stylesheet" href="css/upload.css">
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
                    } else {
            %>
                <button onclick="window.location.href='upload.jsp'">Upload</button>
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
        <h2>Become a Professional</h2>
        <%
            if (!loggedIn) {
        %>
            <div class="message">You must be logged in to register as a professional.</div>
        <%
            } else if (isProfessional) {
        %>
            <div class="message">You are already registered as a professional.</div>
        <%
            } else {
        %>
        <form method="post" action="UploadProfessionalServlet">
            <label>Name</label>
            <input type="text" name="name" value="<%= username %>" readonly />

            <label>Email</label>
            <input type="email" name="email" value="<%= email %>" readonly />

            <label for="profession">Profession*</label>
            <select id="profession" name="profession" required>
                <option value="">Select Profession</option>
                <option value="Photographer">Photographer</option>
                <option value="Singer">Singer</option>
                <option value="Dancer">Dancer</option>
                <option value="Decorator">Decorator</option>
                <option value="Event Manager">Event Manager</option>
                <option value="Chef">Chef</option>
                <option value="Teacher">Teacher</option>
                <option value="Home Organizer">Home Organizer</option>
            </select>

            <label for="bio">Bio*</label>
            <textarea id="bio" name="bio" rows="4" required></textarea>

            <label for="social_link">Social Media Link</label>
            <input type="url" id="social_link" name="social_link" placeholder="https://..." />

            <button type="submit">Submit</button>
        </form>
        <%
            }
        %>
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