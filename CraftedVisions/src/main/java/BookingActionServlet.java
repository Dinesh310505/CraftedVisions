import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/BookingActionServlet")
public class BookingActionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String bookingId = request.getParameter("bookingId");
        String action = request.getParameter("action");
        String status = "pending";
        if ("accept".equals(action)) status = "accepted";
        else if ("reject".equals(action)) status = "rejected";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE bookings SET status = ?, status_updated_at = NOW() WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(bookingId));
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        // Optionally, you can add a message or redirect to a confirmation page
        response.sendRedirect("viewBookings.jsp");
    }
}