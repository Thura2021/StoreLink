<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>403 Forbidden</title>
  <style>
    body{font-family:Segoe UI, sans-serif;background:#f2f1ef;margin:0}
    .box{max-width:560px;margin:60px auto;background:#fff;border-radius:12px;padding:24px;box-shadow:0 10px 30px rgba(0,0,0,.08)}
    h1{margin:0 0 8px;font-size:22px}
    p{margin:8px 0;color:#444;line-height:1.6}
    a{display:inline-block;margin-top:14px;text-decoration:none;color:#2563eb}
    .sub{color:#666;font-size:13px}
  </style>
</head>
<body>
  <div class="box">
    <h1>403 - アクセス権限がありません</h1>
    <p>このページは権限を持つユーザーのみアクセスできます。</p>
    <p class="sub">（staff アカウントで制限ページを開いた可能性があります）</p>
    <a href="<%= request.getContextPath() %>/login.jsp">ログイン画面へ戻る</a>
  </div>
</body>
</html>
