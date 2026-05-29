package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateItemInlineServlet")
public class UpdateItemInlineServlet extends HttpServlet {
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
    String role = (session == null) ? null : (String) session.getAttribute("role");

    boolean isAdmin = (role != null && "admin".equalsIgnoreCase(role));
    @SuppressWarnings("unchecked")
    Map<String, Boolean> perms = (session == null) ? null : (Map<String, Boolean>) session.getAttribute("perms");
    boolean canEdit = isAdmin || (perms != null && Boolean.TRUE.equals(perms.get("EDIT_ITEM")));

    if(!canEdit){
      response.sendError(403);
      return;
    }

    String code = request.getParameter("code");
    String name = request.getParameter("name");
    String qtyStr = request.getParameter("qty");
    String priceStr = request.getParameter("price");
    String note = request.getParameter("note");

    if(code == null || code.trim().isEmpty()){
      response.sendRedirect("drawer.jsp?page=item_list");
      return;
    }

    int qty = 0;
    int price = 0;
    try{ qty = Integer.parseInt(qtyStr); }catch(Exception e){}
    try{ price = Integer.parseInt(priceStr); }catch(Exception e){}

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
      throw new ServletException(e);
    }

    try (Connection con = DriverManager.getConnection(URL, USER, PASS)) {
      try (PreparedStatement ps = con.prepareStatement(
          "UPDATE items SET name=?, qty=?, price=?, note=? WHERE code=?")) {
        ps.setString(1, name);
        ps.setInt(2, qty);
        ps.setInt(3, price);
        ps.setString(4, note);
        ps.setString(5, code);
        ps.executeUpdate();
      }
    } catch (SQLException e) {
      throw new ServletException(e);
    }

    // item list ကိုပြန်
    response.sendRedirect("drawer.jsp?page=item_list");
  }
}
