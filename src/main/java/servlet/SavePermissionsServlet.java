package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SavePermissionsServlet")
public class SavePermissionsServlet extends HttpServlet {
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
    String role = (session == null) ? null : (String) session.getAttribute("role"); // ✅ FIX
    if (role == null || !"admin".equalsIgnoreCase(role)) {
      response.sendError(403);
      return;
    }

    String userIdStr = request.getParameter("user_id");
    if (userIdStr == null || userIdStr.trim().isEmpty()) {
      response.sendRedirect("drawer.jsp?page=settings");
      return;
    }

    int userId = Integer.parseInt(userIdStr);

    String[] selected = request.getParameterValues("perm");
    Set<String> set = new HashSet<>();
    if (selected != null) {
      for (String p : selected) set.add(p);
    }

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
      throw new ServletException(e);
    }

    try (Connection con = DriverManager.getConnection(URL, USER, PASS)) {

      // ✅ clean old perms
      try (PreparedStatement del = con.prepareStatement("DELETE FROM user_permissions WHERE user_id=?")) {
        del.setInt(1, userId);
        del.executeUpdate();
      }

      // ✅ insert selected perms (allowed=1)
      try (PreparedStatement ins = con.prepareStatement(
          "INSERT INTO user_permissions(user_id, perm_key, allowed) VALUES(?, ?, 1)")) {
        for (String key : set) {
          ins.setInt(1, userId);
          ins.setString(2, key);
          ins.addBatch();
        }
        ins.executeBatch();
      }

    } catch (SQLException e) {
      throw new ServletException(e);
    }

    response.sendRedirect("drawer.jsp?page=settings&uid=" + userId);
  }
}
