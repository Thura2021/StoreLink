<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>STORE LINK - ログイン</title>
  <link rel="stylesheet" href="css/login.css">
</head>
<body class="login-body">

  <div class="login-card">
    <div class="login-brand">
      <div class="login-logo">STORE LINK</div>
      <div class="login-sub">店舗管理システム</div>
    </div>

    <%
      String error = request.getParameter("error");
      if ("1".equals(error)) {
    %>
      <div class="login-error">ユーザー名またはパスワードが間違っています。</div>
    <%
      }
    %>

    <form class="login-form" action="LoginServlet" method="post">
      <label class="login-label" for="username">ユーザー名</label>
      <input class="login-input" id="username" type="text" name="username" required>

      <label class="login-label" for="password">パスワード</label>
      <input class="login-input" id="password" type="password" name="password" required>

      <button class="login-btn" type="submit">ログイン</button>
    </form>

    <div class="login-foot">© StoreLink</div>
  </div>

</body>
</html>
