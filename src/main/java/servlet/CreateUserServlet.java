package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CreateUserServlet")
public class CreateUserServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  private static final String URL =
    "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("userName") == null) {
      response.sendRedirect("login.jsp");
      return;
    }

    String loginUser = (String) session.getAttribute("userName");
    if (!"admin".equalsIgnoreCase(loginUser)) {
      response.sendRedirect("drawer.jsp?page=dashboard");
      return;
    }

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if (username == null || password == null ||
        username.trim().isEmpty() || password.trim().isEmpty()) {
      response.sendRedirect("drawer.jsp?page=create_user&error=1");
      return;
    }

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      try (Connection con = DriverManager.getConnection(URL, USER, PASS);
           PreparedStatement ps =
             con.prepareStatement("INSERT INTO users(username,password) VALUES(?,?)")) {

        ps.setString(1, username.trim());
        ps.setString(2, password.trim());
        ps.executeUpdate();

        response.sendRedirect("drawer.jsp?page=create_user&ok=1");
      }
    } catch (SQLIntegrityConstraintViolationException e) {
      response.sendRedirect("drawer.jsp?page=create_user&error=2");
    } catch (Exception e) {
      throw new ServletException(e);
    }
  }
}
