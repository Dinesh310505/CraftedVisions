import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String phonenumber = request.getParameter("phonenumber");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        if (!password.equals(confirmPassword)) {
            out.println("<h2 style='color:red;'>Error: Passwords do not match!</h2>");
            return;
        }

        // Hash the password using SHA-256
        String hashedPassword = hashPassword(password);

        try (Connection conn = DBConnection.getConnection()) {
            // Check if email or phone number already exists
            PreparedStatement checkPs = conn.prepareStatement(
                "SELECT * FROM users WHERE email = ? OR phonenumber = ?"
            );
            checkPs.setString(1, email);
            checkPs.setString(2, phonenumber);
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                out.println("<h2 style='color:red;'>Error: An account with this email or phone number already exists!</h2>");
                rs.close();
                checkPs.close();
                return;
            }
            rs.close();
            checkPs.close();

            // Insert new user with hashed password
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (name, email, password, phonenumber) VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, hashedPassword); // Store hashed password
            ps.setString(4, phonenumber);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("Login.html");
            } else {
                out.println("<h2 style='color:red;'>Registration failed!</h2>");
            }
            ps.close();

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<h2 style='color:red;'>Database error!</h2>");
        }
    }

    // Utility method to hash a password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
}