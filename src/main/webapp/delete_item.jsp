<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");

String code = request.getParameter("code");
if(code == null || code.trim().isEmpty()){
  response.sendRedirect("drawer.jsp?page=item_list");
  return;
}

String url = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
String user = "root";
String pass = "";

Connection con = null;
PreparedStatement ps = null;

try{
  Class.forName("com.mysql.cj.jdbc.Driver");
  con = DriverManager.getConnection(url, user, pass);

  ps = con.prepareStatement("DELETE FROM items WHERE code=?");
  ps.setString(1, code);
  ps.executeUpdate();

}catch(Exception e){
  out.println("<div style='padding:16px;font-weight:900;color:#b00;'>削除エラー：" + e.getMessage() + "</div>");
  out.println("<div style='padding:0 16px 16px;'><a href='drawer.jsp?page=item_list'>戻る</a></div>");
  return;
}finally{
  try{ if(ps!=null) ps.close(); }catch(Exception e){}
  try{ if(con!=null) con.close(); }catch(Exception e){}
}

response.sendRedirect("drawer.jsp?page=item_list");
%>
