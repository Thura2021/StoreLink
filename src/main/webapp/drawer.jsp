<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>STORE LINK</title>
  <link rel="stylesheet" href="css/drawer.css">
</head>
<body>

<%
  String userName = (String) session.getAttribute("userName");
  Integer userId = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");
  Map<String, Boolean> perms = (Map<String, Boolean>) session.getAttribute("perms");

  if (userName == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  if (perms == null) perms = new HashMap<>();

  boolean isAdmin = (role != null && "admin".equalsIgnoreCase(role));

  // permission helper
  boolean canViewDashboard = isAdmin || Boolean.TRUE.equals(perms.get("VIEW_DASHBOARD"));
  boolean canViewGroup     = isAdmin || Boolean.TRUE.equals(perms.get("VIEW_GROUP"));
  boolean canViewCategory  = isAdmin || Boolean.TRUE.equals(perms.get("VIEW_CATEGORY"));
  boolean canViewTable     = isAdmin || Boolean.TRUE.equals(perms.get("VIEW_TABLE"));
  boolean canViewItem      = isAdmin || Boolean.TRUE.equals(perms.get("VIEW_ITEM"));
  boolean canManageUsers   = isAdmin || Boolean.TRUE.equals(perms.get("MANAGE_USERS"));

  String currentPage = request.getParameter("page");
  if (currentPage == null || currentPage.isEmpty()) currentPage = "dashboard";
%>

<header class="app-header">
  <button class="menu-btn" type="button" onclick="toggleDrawer()">☰</button>
  <span class="app-title">STORE LINK</span>
</header>

<div class="overlay" id="overlay" onclick="closeDrawer()"></div>

<aside class="drawer" id="drawer">
  <div class="drawer-header">
    <div class="title">メニュー</div>
  </div>

  <!-- ===== MENU ===== -->
  <nav class="drawer-menu">

    <% if (canViewDashboard) { %>
      <a href="drawer.jsp?page=dashboard"
         class="<%= "dashboard".equals(currentPage) ? "active" : "" %>">
        ダッシュボード
      </a>
    <% } %>

    <% if (canViewGroup) { %>
      <a href="drawer.jsp?page=group_list"
         class="<%= "group_list".equals(currentPage) ? "active" : "" %>">
        グループ
      </a>
    <% } %>

    <% if (canViewCategory) { %>
      <a href="drawer.jsp?page=category_list"
         class="<%= "category_list".equals(currentPage) ? "active" : "" %>">
        カテゴリー
      </a>
    <% } %>

    <% if (canViewTable) { %>
      <a href="drawer.jsp?page=table_list"
         class="<%= "table_list".equals(currentPage) ? "active" : "" %>">
        テーブル
      </a>
    <% } %>

    <% if (canViewItem) { %>
      <a href="drawer.jsp?page=item_list"
         class="<%= "item_list".equals(currentPage) ? "active" : "" %>">
        商品
      </a>
    <% } %>

    <% if (canManageUsers) { %>
      <hr>
      <a href="drawer.jsp?page=create_user"
         class="<%= "create_user".equals(currentPage) ? "active" : "" %>">
        アカウント作成
      </a>
      <a href="drawer.jsp?page=settings"
         class="<%= "settings".equals(currentPage) ? "active" : "" %>">
        権限設定
      </a>
    <% } %>

  </nav>

  <div class="drawer-footer">
    <div class="login-userline">
      ログイン中：<b><%= userName %></b>
    </div>
    <a class="logout" href="LogoutServlet">ログアウト</a>
  </div>
</aside>

<!-- ===== CONTENT ===== -->
<main class="content">
  <div class="content-box">
  <%
    String pageFile = "dashboard.jsp";

    if ("dashboard".equals(currentPage)) {
      pageFile = canViewDashboard ? "dashboard.jsp" : "403.jsp";

    } else if ("group_list".equals(currentPage)) {
      pageFile = canViewGroup ? "groupoutput.jsp" : "403.jsp";

    } else if ("category_list".equals(currentPage)) {
      pageFile = canViewCategory ? "categoryoutput.jsp" : "403.jsp";

    } else if ("table_list".equals(currentPage)) {
      pageFile = canViewTable ? "tableoutput.jsp" : "403.jsp";

    } else if ("item_list".equals(currentPage)) {
      pageFile = canViewItem ? "itemoutput.jsp" : "403.jsp";

    } else if ("group_add".equals(currentPage)) {
      pageFile = canViewGroup ? "group.jsp" : "403.jsp";

    } else if ("category_add".equals(currentPage)) {
      pageFile = canViewCategory ? "category.jsp" : "403.jsp";

    } else if ("table_add".equals(currentPage)) {
      pageFile = canViewTable ? "table.jsp" : "403.jsp";

    } else if ("item_add".equals(currentPage)) {
      pageFile = canViewItem ? "item.jsp" : "403.jsp";

    } else if ("create_user".equals(currentPage)) {
      pageFile = canManageUsers ? "create_user.jsp" : "403.jsp";

    } else if ("settings".equals(currentPage)) {
      pageFile = canManageUsers ? "settings.jsp" : "403.jsp";
    }
  %>

    <jsp:include page="<%= pageFile %>" />
  </div>
</main>

<!-- ✅ Floating + Button (AppSheet style) -->
<button class="fab" type="button" onclick="toggleFabMenu()" aria-label="Add">+</button>

<!-- ✅ FAB Menu -->
<div class="fab-menu" id="fabMenu">
  <div class="fab-menu-title">作成メニュー</div>

  <% if (canViewGroup) { %>
    <a class="fab-item" href="drawer.jsp?page=group_add" onclick="closeFabMenu()">グループを作成</a>
  <% } %>

  <% if (canViewCategory) { %>
    <a class="fab-item" href="drawer.jsp?page=category_add" onclick="closeFabMenu()">カテゴリーを作成</a>
  <% } %>

  <% if (canViewTable) { %>
    <a class="fab-item" href="drawer.jsp?page=table_add" onclick="closeFabMenu()">テーブルを作成</a>
  <% } %>

  <% if (canViewItem) { %>
    <a class="fab-item" href="drawer.jsp?page=item_add" onclick="closeFabMenu()">アイテムを作成</a>
  <% } %>
</div>

<script src="js/drawer.js"></script>
</body>
</html>
