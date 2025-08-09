import java.io.IOException;
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
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        password = hashPassword(password);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT name FROM users WHERE email = ? AND password = ?")) {

            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String name = rs.getString("name");

                HttpSession session = request.getSession();
                session.setAttribute("name", name);
                session.setAttribute("email", email);

                // Update last_login time in users table
                try (PreparedStatement ps2 = conn.prepareStatement(
                        "UPDATE users SET last_login = NOW() WHERE email = ?")) {
                    ps2.setString(1, email);
                    ps2.executeUpdate();
                }

                response.sendRedirect("Home.jsp");
            } else {
                response.setContentType("text/html");
                response.getWriter().println("<h2 style='color:red;'>Invalid email or password!</h2>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<h2 style='color:red;'>Database error!</h2>");
        }
    }

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
