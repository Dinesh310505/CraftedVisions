import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/BookProfessionalServlet")
public class BookProfessionalServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String userEmail = (session != null) ? (String) session.getAttribute("email") : null;
        String proEmail = request.getParameter("proEmail");

        if (userEmail == null) {
            // Not logged in
            response.sendRedirect("Login.html");
            return;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO bookings (user_email, professional_email, booking_time) VALUES (?, ?, NOW())")) {
            ps.setString(1, userEmail);
            ps.setString(2, proEmail);
            ps.executeUpdate();
            // Redirect to a confirmation page or back with a success message
            response.sendRedirect("bookingSuccess.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("bookingError.jsp");
        }
    }
}