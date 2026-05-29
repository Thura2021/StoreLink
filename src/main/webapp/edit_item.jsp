<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");

// params
String code         = request.getParameter("code");
String name         = request.getParameter("name");
String qtyS         = request.getParameter("qty");
String priceS       = request.getParameter("price");
String note         = request.getParameter("note");

String tableCode    = request.getParameter("table_code");
String groupCode    = request.getParameter("group_code");
String categoryCode = request.getParameter("category_code");

// optional return (where to go after save)
String ret = request.getParameter("return");
if(ret == null || ret.trim().isEmpty()){
  ret = "drawer.jsp?page=item_list";
}

// validate
if (code == null || code.trim().isEmpty()) { out.println("ERROR: code required"); return; }
if (name == null || name.trim().isEmpty()) { out.println("ERROR: name required"); return; }

if(qtyS == null) qtyS = "0";
if(priceS == null) priceS = "0";
if(note == null) note = "";

if(tableCode == null) tableCode = "";
if(groupCode == null) groupCode = "";
if(categoryCode == null) categoryCode = "";

int qty = 0;
int price = 0;
try { qty = Integer.parseInt(qtyS.trim()); } catch (Exception e) { qty = 0; }
try { price = (int)Double.parseDouble(priceS.trim()); } catch (Exception e) { price = 0; }

// DB
String url  = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
String user = "root";
String pass = "";

Connection con = null;
PreparedStatement ps = null;

boolean ok = false;
String err = null;

try {
  Class.forName("com.mysql.cj.jdbc.Driver");
  con = DriverManager.getConnection(url, user, pass);

  // ✅ build SQL dynamically: empty means "no change"
  StringBuilder sb = new StringBuilder();
  sb.append("UPDATE items SET name=?, qty=?, price=?, note=?");

  boolean updTable = !tableCode.trim().isEmpty();
  boolean updGroup = !groupCode.trim().isEmpty();
  boolean updCate  = !categoryCode.trim().isEmpty();

  if(updTable) sb.append(", table_code=?");
  if(updGroup) sb.append(", group_code=?");
  if(updCate)  sb.append(", category_code=?");

  sb.append(" WHERE code=?");

  ps = con.prepareStatement(sb.toString());

  int idx = 1;
  ps.setString(idx++, name);
  ps.setInt(idx++, qty);
  ps.setInt(idx++, price);
  ps.setString(idx++, note);

  if(updTable) ps.setString(idx++, tableCode);
  if(updGroup) ps.setString(idx++, groupCode);
  if(updCate)  ps.setString(idx++, categoryCode);

  ps.setString(idx++, code);

  int updated = ps.executeUpdate();
  if (updated == 1) {
    ok = true;
  } else {
    err = "ERROR: item not found";
  }

} catch (Exception e) {
  err = "ERROR: " + e.getMessage();

} finally {
  try { if (ps != null) ps.close(); } catch (Exception e) {}
  try { if (con != null) con.close(); } catch (Exception e) {}
}

if (ok) {
  response.sendRedirect(ret);
} else {
  out.println(err == null ? "ERROR" : err);
}
%>
