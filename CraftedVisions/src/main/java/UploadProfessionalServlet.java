import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UploadProfessionalServlet")
public class UploadProfessionalServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        String email = request.getParameter("email");
        String profession = request.getParameter("profession");
        String bio = request.getParameter("bio");
        String socialLink = request.getParameter("social_link");

        // Always get name and phone from users table for this email
        String name = "";
        String phonenumber = "";

        try (Connection conn = DBConnection.getConnection()) {
            // Check if user exists
            PreparedStatement userPs = conn.prepareStatement("SELECT name, phonenumber FROM users WHERE email = ?");
            userPs.setString(1, email);
            ResultSet userRs = userPs.executeQuery();
            if (!userRs.next()) {
                out.println("<h2 style='color:red;'>You must register as a user first.</h2>");
                userRs.close();
                userPs.close();
                return;
            }
            name = userRs.getString("name");
            phonenumber = userRs.getString("phonenumber");
            userRs.close();
            userPs.close();

            // Try to insert as professional (will fail if already exists due to UNIQUE constraint)
            try {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO professionals (email, name, phonenumber, profession, bio, social_link) VALUES (?, ?, ?, ?, ?, ?)"
                );
                ps.setString(1, email);
                ps.setString(2, name);
                ps.setString(3, phonenumber);
                ps.setString(4, profession);
                ps.setString(5, bio);
                ps.setString(6, socialLink);
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("Home.jsp");
            } catch (SQLException e) {
                // If duplicate, show friendly message
                if (e.getMessage().contains("Duplicate") || e.getMessage().contains("UNIQUE")) {
                    out.println("<h2 style='color:red;'>You are already registered as a professional!</h2>");
                } else {
                    e.printStackTrace();
                    out.println("<h2 style='color:red;'>Database error!</h2>");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<h2 style='color:red;'>Database error!</h2>");
        }
    }
}