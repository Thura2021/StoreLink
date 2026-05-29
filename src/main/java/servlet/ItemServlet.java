package servlet;

import java.io.*;
import java.nio.file.Paths;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ItemServlet")
@MultipartConfig(
  fileSizeThreshold = 1024 * 1024,      // 1MB
  maxFileSize = 10 * 1024 * 1024,       // 10MB
  maxRequestSize = 20 * 1024 * 1024     // 20MB
)
public class ItemServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  private static final String URL =
    "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  // uploads folder (webapp/uploads/items)
  private static final String UPLOAD_DIR = "uploads/items";

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    // LOGIN USER
    HttpSession session = request.getSession(false);
    String createdBy = null;
    if (session != null) createdBy = (String) session.getAttribute("userName");
    if (createdBy == null) createdBy = "unknown";

    String code = request.getParameter("code");
    String name = request.getParameter("name");
    String groupCode = request.getParameter("group_code");
    String categoryCode = request.getParameter("category_code");
    String tableCode = request.getParameter("table_code");
    String note = request.getParameter("note");
    String qtyStr = request.getParameter("qty");
    String priceStr = request.getParameter("price");

    if (isEmpty(code) || isEmpty(name) || isEmpty(groupCode) || isEmpty(categoryCode)
        || isEmpty(tableCode) || isEmpty(qtyStr) || isEmpty(priceStr)) {

      request.setAttribute("error", "入力が不足しています。もう一度確認してください。");
      keepFormValues(request);
      request.getRequestDispatcher("/item.jsp").forward(request, response);
      return;
    }

    int qty;
    double price;
    try {
      qty = Integer.parseInt(qtyStr);
      price = Double.parseDouble(priceStr);
    } catch (Exception e) {
      request.setAttribute("error", "数量または価格の形式が正しくありません。");
      keepFormValues(request);
      request.getRequestDispatcher("/item.jsp").forward(request, response);
      return;
    }

    // photo save
    String photoPath = null;
    Part photoPart = null;

    try {
      photoPart = request.getPart("photo");
    } catch (IllegalStateException e) {
      request.setAttribute("error", "画像サイズが大きすぎます（最大10MB）。");
      keepFormValues(request);
      request.getRequestDispatcher("/item.jsp").forward(request, response);
      return;
    }

    if (photoPart != null && photoPart.getSize() > 0) {
      String submitted = Paths.get(photoPart.getSubmittedFileName()).getFileName().toString();
      String lower = submitted.toLowerCase();
      if (!(lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png")
          || lower.endsWith(".gif") || lower.endsWith(".webp"))) {
        request.setAttribute("error", "画像ファイル（jpg/png/gif/webp）のみアップロード可能です。");
        keepFormValues(request);
        request.getRequestDispatcher("/item.jsp").forward(request, response);
        return;
      }

      String ext = submitted.contains(".") ? submitted.substring(submitted.lastIndexOf(".")) : "";
      String fileName = code + "_" + System.currentTimeMillis() + ext;

      String appPath = request.getServletContext().getRealPath("");
      File uploadBase = new File(appPath, UPLOAD_DIR);
      if (!uploadBase.exists()) uploadBase.mkdirs();

      File savedFile = new File(uploadBase, fileName);

      try (InputStream in = photoPart.getInputStream();
           FileOutputStream out = new FileOutputStream(savedFile)) {

        byte[] buf = new byte[8192];
        int len;
        while ((len = in.read(buf)) != -1) {
          out.write(buf, 0, len);
        }
      }

      photoPath = UPLOAD_DIR + "/" + fileName;
    }

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
      throw new ServletException(e);
    }

    try (Connection con = DriverManager.getConnection(URL, USER, PASS);
         PreparedStatement ps = con.prepareStatement(
           "INSERT INTO items " +
           "(code, name, group_code, category_code, qty, price, table_code, note, created_by, created_at, photo) " +
           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?)"
         )) {

      ps.setString(1, code);
      ps.setString(2, name);
      ps.setString(3, groupCode);
      ps.setString(4, categoryCode);
      ps.setInt(5, qty);
      ps.setDouble(6, price);
      ps.setString(7, tableCode);
      ps.setString(8, note);
      ps.setString(9, createdBy);
      ps.setString(10, photoPath);

      ps.executeUpdate();

      // ✅ drawer page name: မင်းအရင်က item_list သုံးနေတယ်
      response.sendRedirect(request.getContextPath() + "/drawer.jsp?page=item_list");

    } catch (SQLException e) {
      request.setAttribute("error", "保存できませんでした。商品コードが重複していないか確認してください。");
      keepFormValues(request);
      request.getRequestDispatcher("/item.jsp").forward(request, response);
    }
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    // ✅ detail API: /ItemServlet?action=detail&code=xxx
    String action = request.getParameter("action");
    if ("detail".equals(action)) {
      sendItemDetailJson(request, response);
      return;
    }

    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    response.setContentType("text/plain; charset=UTF-8");
    response.getWriter().write("Bad Request");
  }

  private void sendItemDetailJson(HttpServletRequest request, HttpServletResponse response)
      throws IOException {

    response.setContentType("application/json; charset=UTF-8");

    // (optional) login check
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("userName") == null) {
      response.setStatus(401);
      response.getWriter().write("{\"ok\":false,\"message\":\"not logged in\"}");
      return;
    }

    String code = request.getParameter("code");
    if (isEmpty(code)) {
      response.setStatus(400);
      response.getWriter().write("{\"ok\":false,\"message\":\"code is required\"}");
      return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      con = DriverManager.getConnection(URL, USER, PASS);

      ps = con.prepareStatement("SELECT * FROM items WHERE code = ? LIMIT 1");
      ps.setString(1, code);
      rs = ps.executeQuery();

      if (!rs.next()) {
        response.getWriter().write("{\"ok\":false,\"message\":\"not found\"}");
        return;
      }

      ResultSetMetaData md = rs.getMetaData();
      int n = md.getColumnCount();

      StringBuilder json = new StringBuilder();
      json.append("{\"ok\":true,\"data\":{");

      for (int i = 1; i <= n; i++) {
        String col = md.getColumnLabel(i);
        Object val = rs.getObject(i);

        json.append("\"").append(escapeJson(col)).append("\":");
        if (val == null) {
          json.append("null");
        } else if (val instanceof Number || val instanceof Boolean) {
          json.append(val.toString());
        } else {
          json.append("\"").append(escapeJson(String.valueOf(val))).append("\"");
        }

        if (i < n) json.append(",");
      }

      json.append("}}");
      response.getWriter().write(json.toString());

    } catch (Exception e) {
      response.setStatus(500);
      response.getWriter().write("{\"ok\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
    } finally {
      try { if (rs != null) rs.close(); } catch (Exception e) {}
      try { if (ps != null) ps.close(); } catch (Exception e) {}
      try { if (con != null) con.close(); } catch (Exception e) {}
    }
  }

  private boolean isEmpty(String s) {
    return s == null || s.trim().isEmpty();
  }

  private void keepFormValues(HttpServletRequest request) {
    request.setAttribute("code", request.getParameter("code"));
    request.setAttribute("name", request.getParameter("name"));
    request.setAttribute("group_code", request.getParameter("group_code"));
    request.setAttribute("category_code", request.getParameter("category_code"));
    request.setAttribute("table_code", request.getParameter("table_code"));
    request.setAttribute("qty", request.getParameter("qty"));
    request.setAttribute("price", request.getParameter("price"));
    request.setAttribute("note", request.getParameter("note"));
  }

  private static String escapeJson(String s) {
    if (s == null) return "";
    StringBuilder b = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      switch (c) {
        case '\\': b.append("\\\\"); break;
        case '"':  b.append("\\\""); break;
        case '\n': b.append("\\n"); break;
        case '\r': b.append("\\r"); break;
        case '\t': b.append("\\t"); break;
        default:
          if (c < 0x20) b.append(String.format("\\u%04x", (int)c));
          else b.append(c);
      }
    }
    return b.toString();
  }
}
