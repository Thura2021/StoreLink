package servlet;

import java.io.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ImportItemsServlet")
@MultipartConfig
public class ImportItemsServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  private static final String URL =
      "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    Part filePart = request.getPart("file");
    if (filePart == null || filePart.getSize() == 0) {
      response.sendRedirect("drawer.jsp?page=item_list");
      return;
    }

    // login user
    HttpSession session = request.getSession(false);
    String createdBy = (session != null && session.getAttribute("userName") != null)
        ? (String) session.getAttribute("userName")
        : "import";

    int inserted = 0;
    int updated = 0;
    int skipped = 0;

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      try (Connection con = DriverManager.getConnection(URL, USER, PASS)) {

        con.setAutoCommit(false);

        String sqlInsert =
          "INSERT INTO items (code,name,group_code,category_code,qty,price,table_code,note,created_by,created_at,photo) " +
          "VALUES (?,?,?,?,?,?,?,?,?,NOW(),?)";

        String sqlUpdate =
          "UPDATE items SET name=?, group_code=?, category_code=?, qty=?, price=?, table_code=?, note=?, photo=? " +
          "WHERE code=?";

        try (PreparedStatement psIns = con.prepareStatement(sqlInsert);
             PreparedStatement psUpd = con.prepareStatement(sqlUpdate);
             BufferedReader br = new BufferedReader(new InputStreamReader(filePart.getInputStream(), "UTF-8"))) {

          String line;
          boolean first = true;

          while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;

            // header skip
            if (first) {
              first = false;
              if (line.toLowerCase().startsWith("code,")) continue;
            }

            List<String> cols = parseCsvLine(line);

            // Expected columns:
            // 0 code,1 name,2 group_code,3 category_code,4 qty,5 price,6 table_code,7 note,8 created_by,9 created_at,10 photo
            if (cols.size() < 8) { skipped++; continue; }

            String code = safe(cols, 0);
            String name = safe(cols, 1);
            String groupCode = safe(cols, 2);
            String categoryCode = safe(cols, 3);
            String qtyStr = safe(cols, 4);
            String priceStr = safe(cols, 5);
            String tableCode = safe(cols, 6);
            String note = safe(cols, 7);
            String photo = (cols.size() >= 11) ? safe(cols, 10) : null;

            if (code == null || code.trim().isEmpty()) { skipped++; continue; }
            if (name == null || name.trim().isEmpty()) { skipped++; continue; }

            int qty;
            BigDecimal price;
            try {
              qty = Integer.parseInt(qtyStr.trim());
              price = new BigDecimal(priceStr.trim());
              if (qty < 0 || price.compareTo(BigDecimal.ZERO) < 0) { skipped++; continue; }
            } catch (Exception ex) {
              skipped++; continue;
            }

            // exists?
            boolean exists = false;
            try (PreparedStatement chk = con.prepareStatement("SELECT code FROM items WHERE code=?")) {
              chk.setString(1, code);
              try (ResultSet rs = chk.executeQuery()) {
                exists = rs.next();
              }
            }

            if (exists) {
              psUpd.setString(1, name);
              psUpd.setString(2, groupCode);
              psUpd.setString(3, categoryCode);
              psUpd.setInt(4, qty);
              psUpd.setBigDecimal(5, price);
              psUpd.setString(6, tableCode);
              psUpd.setString(7, note);
              psUpd.setString(8, photo);
              psUpd.setString(9, code);
              psUpd.executeUpdate();
              updated++;
            } else {
              psIns.setString(1, code);
              psIns.setString(2, name);
              psIns.setString(3, groupCode);
              psIns.setString(4, categoryCode);
              psIns.setInt(5, qty);
              psIns.setBigDecimal(6, price);
              psIns.setString(7, tableCode);
              psIns.setString(8, note);
              psIns.setString(9, createdBy);
              psIns.setString(10, photo);
              psIns.executeUpdate();
              inserted++;
            }
          }

          con.commit();
        } catch (Exception e) {
          con.rollback();
          throw e;
        } finally {
          con.setAutoCommit(true);
        }
      }

      // ✅ result message (optional: you can show this anywhere)
      request.getSession().setAttribute("importMsg",
        "取込完了：追加 " + inserted + " / 更新 " + updated + " / スキップ " + skipped);

      response.sendRedirect("drawer.jsp?page=item_list");

    } catch (Exception e) {
      throw new ServletException(e);
    }
  }

  private String safe(List<String> cols, int idx) {
    if (idx < 0 || idx >= cols.size()) return null;
    return cols.get(idx);
  }

  // Basic CSV parser (supports quoted values with commas)
  private List<String> parseCsvLine(String line) {
    List<String> out = new ArrayList<>();
    StringBuilder cur = new StringBuilder();
    boolean inQ = false;

    for (int i = 0; i < line.length(); i++) {
      char ch = line.charAt(i);
      if (inQ) {
        if (ch == '"') {
          if (i + 1 < line.length() && line.charAt(i + 1) == '"') {
            cur.append('"');
            i++;
          } else {
            inQ = false;
          }
        } else {
          cur.append(ch);
        }
      } else {
        if (ch == '"') {
          inQ = true;
        } else if (ch == ',') {
          out.add(cur.toString());
          cur.setLength(0);
        } else {
          cur.append(ch);
        }
      }
    }
    out.add(cur.toString());
    return out;
  }
}
