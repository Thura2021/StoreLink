package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ItemHistoryServlet")
public class ItemHistoryServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  private static final String URL =
      "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    String code = request.getParameter("code");
    if (code == null) code = "";
    code = code.trim().replace("\uFEFF","").replace("\u200B","");

    if (code.isEmpty()) {
      response.getWriter().print("{\"ok\":false,\"message\":\"code required\"}");
      return;
    }

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
      throw new ServletException(e);
    }

    ArrayList<String> rows = new ArrayList<>();

    try (Connection con = DriverManager.getConnection(URL, USER, PASS);
         PreparedStatement ps = con.prepareStatement(
           "SELECT diff, note, created_at " +
           "FROM item_history " +
           "WHERE item_code = ? " +
           "ORDER BY created_at DESC, id DESC " +
           "LIMIT 30"
         )) {

      ps.setString(1, code);

      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          int diff = rs.getInt("diff");
          String note = rs.getString("note");
          java.sql.Timestamp at = rs.getTimestamp("created_at");

          String noteSafe = (note == null ? "" : escapeJson(note));
          String atSafe = (at == null ? "" : escapeJson(at.toString()));

          rows.add("{\"diff\":" + diff + ",\"note\":\"" + noteSafe + "\",\"at\":\"" + atSafe + "\"}");
        }
      }

    } catch (Exception e) {
      response.getWriter().print("{\"ok\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
      return;
    }

    StringBuilder sb = new StringBuilder();
    sb.append("{\"ok\":true,\"code\":\"").append(escapeJson(code)).append("\",\"rows\":[");
    for (int i=0;i<rows.size();i++){
      if(i>0) sb.append(",");
      sb.append(rows.get(i));
    }
    sb.append("]}");

    response.getWriter().print(sb.toString());
  }

  private String escapeJson(String s){
    if(s==null) return "";
    return s.replace("\\","\\\\").replace("\"","\\\"").replace("\r"," ").replace("\n"," ");
  }
}
