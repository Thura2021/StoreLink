package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/TableItemsServlet")
public class TableItemsServlet extends HttpServlet {

  private static final String URL  = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String tableCode = request.getParameter("table_code");
    if (tableCode == null) tableCode = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    PrintWriter out = response.getWriter();

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      con = DriverManager.getConnection(URL, USER, PASS);

      String sql =
        "SELECT code, name, qty, price " +
        "FROM items " +
        "WHERE table_code = ? " +
        "ORDER BY code";

      ps = con.prepareStatement(sql);
      ps.setString(1, tableCode);
      rs = ps.executeQuery();

      StringBuilder json = new StringBuilder();
      json.append("{\"ok\":true,\"rows\":[");

      boolean first = true;
      while (rs.next()) {
        if (!first) json.append(",");
        first = false;

        String code = rs.getString("code");
        String name = rs.getString("name");
        int qty = rs.getInt("qty");
        int price = (int) rs.getDouble("price");

        json.append("{")
            .append("\"code\":\"").append(escape(code)).append("\",")
            .append("\"name\":\"").append(escape(name)).append("\",")
            .append("\"qty\":").append(qty).append(",")
            .append("\"price\":").append(price)
            .append("}");
      }

      json.append("]}");
      out.print(json.toString());

    } catch (Exception e) {
      out.print("{\"ok\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
    } finally {
      try { if (rs != null) rs.close(); } catch (Exception e) {}
      try { if (ps != null) ps.close(); } catch (Exception e) {}
      try { if (con != null) con.close(); } catch (Exception e) {}
    }
  }

  private String escape(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r");
  }
}
