<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Session and user info
    String email = (String) session.getAttribute("email");
    String username = null;
    boolean loggedIn = false;
    boolean isProfessional = false;
    int bookingCount = 0;

    if (email != null) {
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
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Crafted Visions</title>
<link rel="stylesheet" href="css/stylehome.css">    
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
            %>
                <button id="myBookingsBtn">
                    My Bookings<% if (isProfessional) { %> (<%= bookingCount %>)<% } %>
                </button>
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
    <!-- Welcome message if logged in -->
    <%
        if (loggedIn) {
    %>
        <div style="text-align:center; margin: 24px 0; font-size:1.2rem; color:#222;">
            Welcome, <b><%= username %></b>!
        </div>
    <%
        }
    %>

    <!-- Hero Section -->
    <div class="hero">
        <div class="hero-text">
            <h1>Discover the beauty of<br>crafted visions.</h1>
            <p>Explore the world of creative possibilities.</p>
        </div>
        <div class="hero-image">
            <img src="images/main.png" alt="Art Desk" />
        </div>
    </div>

    <div class="centered-text">
        Discover the artistry of our community
    </div>

    <!-- Steps Section -->
    <div class="steps-section">
        <div class="steps-content">
            <div class="steps-image">
                <img src="images/creativehub.png" alt="Creative Hub" />
            </div>
            <div class="steps-info">
                <div class="steps-title">Joining our<br>creative hub</div>
                <div class="steps-desc">Simplify your creative endeavors in just 3 steps</div>
                <div class="steps-list">
                    <div class="step">
                        <div class="step-title">Step 1</div>
                        <div>Connect with our experts for a personalized consultation.</div>
                    </div>
                    <div class="step">
                        <div class="step-title">Step 2</div>
                        <div>Receive tailored guidance for your creative journey.</div>
                    </div>
                    <div class="step">
                        <div class="step-title">Step 3</div>
                        <div>Optimize operations with ease.</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Skills Section -->
    <div class="skills-section">
        <h2>Crafted Visions Skills</h2>
        <p>Discover top skills on Crafted Visions</p>
    </div>

    <!-- Opportunities Section -->
    <div class="opportunities-section">
        <h3>Innovative Opportunities</h3>
        <p>Crafted Visions welcomes talented individuals who strive for excellence and innovation!</p>
        <div class="opportunities-grid">
            <div class="opportunity-card">
                <h4>Photographer</h4>
                <p>Capturing timeless moments with precision and purpose.</p>
                <a href="photographer.jsp"><button>Discover</button></a>
            </div>
            <div class="opportunity-card">
                <h4>Singer</h4>
                <p>Where passion meets melody to create timeless harmony.</p>
                <a href="singer.jsp"><button>Discover</button></a>
            </div>
            <div class="opportunity-card">
                <h4>Dancer</h4>
                <p>Expressing the inexpressible through the language of movement.</p>
                <a href="dancer.jsp"><button>Discover</button></a>
            </div>
            <div class="opportunity-card">
                <h4>Decorator</h4>
                <p>Where creativity meets craftsmanship in every corner.</p>
                <a href="decorator.jsp"><button>Discover</button></a>
            </div>
            <div class="opportunity-card">
                <h4>Event Manager</h4>
                <p>Crafting unforgettable experiences with precision and passion.</p>
                <a href="eventmanager.jsp"><button>Discover</button></a>
            </div>
            <div class="opportunity-card">
                <h4>Chef</h4>
                <p>Creating memorable moments, one plate at a time.</p>
                <a href="chef.jsp"><button>Discover</button></a>
            </div>
            <div class="opportunity-card">
                <h4>Teacher</h4>
                <p>Educating with purpose, empowering with knowledge.</p>
                <a href="teacher.jsp"><button>Discover</button></a>
            </div>
            <div class="opportunity-card">
                <h4>Home Organizer</h4>
                <p>Transforming chaos into harmony, one space at a time.</p>
                <a href="homeorganizer.jsp"><button>Discover</button></a>
            </div>
        </div>
    </div>

    <!-- Join Section -->
    <div class="join-section">
        <div class="join-content">
            <div class="join-text">
                <div class="join-title">Join Crafted<br>Visions today</div>
                <div class="join-desc">Experience the future of work.</div>
            </div>
            <div class="join-image">
                <img src="images/join.png" alt="Join Crafted Visions" />
            </div>
        </div>
    </div>

    <!-- Footer -->
    <div class="footer">
        <div class="footer-title">Crafted Visions</div>
        <div class="footer-desc">2025 © Crafted Visions All rights reserved.</div>
    </div>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var myBookingsBtn = document.getElementById('myBookingsBtn');
        if (myBookingsBtn) {
            <% if (isProfessional) { %>
                myBookingsBtn.onclick = function() {
                    window.location.href = 'viewBookings.jsp';
                };
            <% } else { %>
                myBookingsBtn.onclick = function() {
                    window.location.href = 'myBookings.jsp';
                };
            <% } %>
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