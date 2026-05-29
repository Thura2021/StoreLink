<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<link rel="stylesheet" href="css/itemsDetail.css">

<%
  String userName = (String)session.getAttribute("userName");
  String role = (String)session.getAttribute("role");
  if(userName == null){
    response.sendRedirect("login.jsp");
    return;
  }

  boolean isAdmin = (role != null && "admin".equalsIgnoreCase(role));
  if(!isAdmin){
%>
  <div style="padding:14px; border:1px solid rgba(255,0,0,.25); background:rgba(255,0,0,.06); border-radius:12px; font-weight:900;">
    権限がありません（adminのみ）
  </div>
<%
    return;
  }

  final String URL  = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  final String USER = "root";
  final String PASS = "";

  String selectedUserId = request.getParameter("uid");
  if(selectedUserId == null) selectedUserId = "";

  // ✅ selected user's current permission flags
  boolean pViewDash=false;
  boolean pViewGroup=false, pEditGroup=false;
  boolean pViewCat=false,  pEditCat=false;
  boolean pViewTable=false,pEditTable=false;
  boolean pViewItem=false, pEditItem=false;
  boolean pImportItem=false, pExportItem=false;
  boolean pManageUsers=false;

  if(!selectedUserId.isEmpty()){
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try{
      Class.forName("com.mysql.cj.jdbc.Driver");
      con = DriverManager.getConnection(URL, USER, PASS);

      ps = con.prepareStatement("SELECT perm_key, allowed FROM user_permissions WHERE user_id=?");
      ps.setInt(1, Integer.parseInt(selectedUserId));
      rs = ps.executeQuery();

      while(rs.next()){
        String k = rs.getString("perm_key");
        boolean a = rs.getInt("allowed")==1;

        if("VIEW_DASHBOARD".equals(k)) pViewDash = a;

        if("VIEW_GROUP".equals(k)) pViewGroup = a;
        if("EDIT_GROUP".equals(k)) pEditGroup = a;

        if("VIEW_CATEGORY".equals(k)) pViewCat = a;
        if("EDIT_CATEGORY".equals(k)) pEditCat = a;

        if("VIEW_TABLE".equals(k)) pViewTable = a;
        if("EDIT_TABLE".equals(k)) pEditTable = a;

        if("VIEW_ITEM".equals(k)) pViewItem = a;
        if("EDIT_ITEM".equals(k)) pEditItem = a;

        if("IMPORT_ITEM".equals(k)) pImportItem = a;
        if("EXPORT_ITEM".equals(k)) pExportItem = a;

        if("MANAGE_USERS".equals(k)) pManageUsers = a;
      }

    }catch(Exception e){
      // ignore
    }finally{
      try{ if(rs!=null) rs.close(); }catch(Exception e){}
      try{ if(ps!=null) ps.close(); }catch(Exception e){}
      try{ if(con!=null) con.close(); }catch(Exception e){}
    }
  }
%>

<div style="display:flex; justify-content:space-between; align-items:flex-end; gap:10px; margin-bottom:12px;">
  <div>
    <div style="font-size:20px; font-weight:1000; color:#01074A;">設定</div>
    <div style="font-size:12px; color:rgba(0,0,0,.55); margin-top:4px;">staff のアクセス権限を設定できます。</div>
  </div>
  <a href="drawer.jsp?page=create_user"
     style="text-decoration:none; font-weight:900; background:rgba(227,251,167,.70); border:1px solid rgba(227,251,167,.95); color:#01074A; padding:10px 12px; border-radius:12px;">
     アカウント作成
  </a>
</div>

<form action="<%= request.getContextPath() %>/SavePermissionsServlet" method="post"
      style="background:#fff; border:1px solid rgba(0,0,0,.10); border-radius:16px; padding:14px; box-shadow:0 10px 24px rgba(0,0,0,.10);">

  <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center; margin-bottom:12px;">
    <div style="font-weight:1000; color:#01074A;">対象ユーザー</div>

    <select name="user_id"
            onchange="location.href='drawer.jsp?page=settings&uid='+this.value"
            style="padding:10px 12px; border-radius:12px; border:1px solid rgba(0,0,0,.14); min-width:220px;">
      <option value="">選択してください</option>

      <%
        Connection conU = null;
        PreparedStatement psU = null;
        ResultSet rsU = null;

        try{
          Class.forName("com.mysql.cj.jdbc.Driver");
          conU = DriverManager.getConnection(URL, USER, PASS);

          // ✅ staff だけ表示したいなら WHERE role='staff' にしてOK
          psU = conU.prepareStatement("SELECT id, username, role FROM users ORDER BY id");
          rsU = psU.executeQuery();

          while(rsU.next()){
            int id = rsU.getInt("id");
            String uname = rsU.getString("username");
            String r = rsU.getString("role");
            if(r==null) r="staff";
            String sel = String.valueOf(id).equals(selectedUserId) ? "selected" : "";
      %>
        <option value="<%= id %>" <%= sel %>><%= uname %> (<%= r %>)</option>
      <%
          }
        }catch(Exception e){
        }finally{
          try{ if(rsU!=null) rsU.close(); }catch(Exception e){}
          try{ if(psU!=null) psU.close(); }catch(Exception e){}
          try{ if(conU!=null) conU.close(); }catch(Exception e){}
        }
      %>
    </select>

    <button type="submit"
            style="border:none; background:#01074A; color:#fff; font-weight:1000; padding:10px 14px; border-radius:12px; cursor:pointer;">
      保存
    </button>
  </div>

  <div style="display:grid; grid-template-columns: repeat(2, minmax(220px, 1fr)); gap:10px;">

    <!-- Dashboard -->
    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="VIEW_DASHBOARD" <%= pViewDash ? "checked" : "" %>>
      ダッシュボード（閲覧）
    </label>

    <!-- Items -->
    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="VIEW_ITEM" <%= pViewItem ? "checked" : "" %>>
      商品一覧（閲覧）
    </label>

    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="EDIT_ITEM" <%= pEditItem ? "checked" : "" %>>
      商品（編集・削除）
    </label>

    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="EXPORT_ITEM" <%= pExportItem ? "checked" : "" %>>
      商品（Excel出力）
    </label>

    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="IMPORT_ITEM" <%= pImportItem ? "checked" : "" %>>
      商品（Excel入力）
    </label>

    <!-- Group -->
    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="VIEW_GROUP" <%= pViewGroup ? "checked" : "" %>>
      グループ（閲覧）
    </label>

    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="EDIT_GROUP" <%= pEditGroup ? "checked" : "" %>>
      グループ（編集）
    </label>

    <!-- Category -->
    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="VIEW_CATEGORY" <%= pViewCat ? "checked" : "" %>>
      カテゴリー（閲覧）
    </label>

    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="EDIT_CATEGORY" <%= pEditCat ? "checked" : "" %>>
      カテゴリー（編集）
    </label>

    <!-- Table -->
    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="VIEW_TABLE" <%= pViewTable ? "checked" : "" %>>
      テーブル（閲覧）
    </label>

    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="EDIT_TABLE" <%= pEditTable ? "checked" : "" %>>
      テーブル（編集）
    </label>

    <!-- Manage Users (staff には基本OFF推奨) -->
    <label style="display:flex; gap:10px; align-items:center; padding:12px; border:1px solid rgba(0,0,0,.10); border-radius:12px; background:#fafafa; font-weight:900;">
      <input type="checkbox" name="perm" value="MANAGE_USERS" <%= pManageUsers ? "checked" : "" %>>
      アカウント管理（作成・権限）
    </label>

  </div>

  <div style="margin-top:10px; font-size:12px; color:rgba(0,0,0,.55);">
    ※ admin は常に全機能を利用できます。staff のみ設定が適用されます。
  </div>
</form>
