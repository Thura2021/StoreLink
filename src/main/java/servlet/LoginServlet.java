package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  private static final String URL =
    "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
      throw new ServletException(e);
    }

    try (Connection con = DriverManager.getConnection(URL, USER, PASS)) {

      // ✅ user
      try (PreparedStatement ps = con.prepareStatement(
          "SELECT id, username, password, role FROM users WHERE username = ?")) {
        ps.setString(1, username);

        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next() && password != null && password.equals(rs.getString("password"))) {

            int userId = rs.getInt("id");
            String role = rs.getString("role"); // admin/staff

            HttpSession session = request.getSession(true);
            session.setAttribute("userId", userId);
            session.setAttribute("userName", rs.getString("username"));
            session.setAttribute("role", role);

            // ✅ permissions map load
            Map<String, Boolean> perms = loadPerms(con, userId, role);
            session.setAttribute("perms", perms);

            response.sendRedirect("drawer.jsp?page=dashboard");
            return;
          }
        }
      }

      response.sendRedirect("login.jsp?error=1");

    } catch (Exception e) {
      throw new ServletException(e);
    }
  }

  private Map<String, Boolean> loadPerms(Connection con, int userId, String role) throws SQLException {
    Map<String, Boolean> map = new HashMap<>();

    // ✅ admin = all true
    if ("admin".equalsIgnoreCase(role)) {
      String[] all = {
        "VIEW_DASHBOARD",
        "VIEW_GROUP","EDIT_GROUP",
        "VIEW_CATEGORY","EDIT_CATEGORY",
        "VIEW_TABLE","EDIT_TABLE",
        "VIEW_ITEM","EDIT_ITEM",
        "IMPORT_ITEM","EXPORT_ITEM",
        "MANAGE_USERS"
      };
      for (String k : all) map.put(k, true);
      return map;
    }

    // ✅ staff: DB에서 읽기 (없으면 false)
    try (PreparedStatement ps = con.prepareStatement(
        "SELECT perm_key, allowed FROM user_permissions WHERE user_id = ?")) {
      ps.setInt(1, userId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          map.put(rs.getString("perm_key"), rs.getInt("allowed") == 1);
        }
      }
    }
    return map;
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.sendRedirect("login.jsp");
  }
}
