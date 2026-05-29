package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ExportItemsServlet")
public class ExportItemsServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  private static final String URL =
      "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/csv; charset=UTF-8");
    response.setHeader("Content-Disposition", "attachment; filename=\"items.csv\"");

    try (PrintWriter out = response.getWriter()) {

      // ✅ BOM for Excel UTF-8
      out.print("\uFEFF");

      out.println("code,name,group_code,category_code,qty,price,table_code,note,created_by,created_at,photo");

      Class.forName("com.mysql.cj.jdbc.Driver");
      try (Connection con = DriverManager.getConnection(URL, USER, PASS);
           PreparedStatement ps = con.prepareStatement(
             "SELECT code,name,group_code,category_code,qty,price,table_code,note,created_by,created_at,photo " +
             "FROM items ORDER BY created_at DESC"
           );
           ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
          out.print(csv(rs.getString("code"))); out.print(",");
          out.print(csv(rs.getString("name"))); out.print(",");
          out.print(csv(rs.getString("group_code"))); out.print(",");
          out.print(csv(rs.getString("category_code"))); out.print(",");
          out.print(rs.getInt("qty")); out.print(",");
          out.print(rs.getBigDecimal("price")); out.print(",");
          out.print(csv(rs.getString("table_code"))); out.print(",");
          out.print(csv(rs.getString("note"))); out.print(",");
          out.print(csv(rs.getString("created_by"))); out.print(",");
          out.print(csv(String.valueOf(rs.getTimestamp("created_at")))); out.print(",");
          out.print(csv(rs.getString("photo")));
          out.println();
        }
      }
    } catch (Exception e) {
      throw new ServletException(e);
    }
  }

  private String csv(String s) {
    if (s == null) return "\"\"";
    String v = s.replace("\"", "\"\"");
    return "\"" + v + "\"";
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    doGet(request, response);
  }
}
