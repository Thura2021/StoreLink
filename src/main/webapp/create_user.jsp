<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>

<%
  String userName = (String) session.getAttribute("userName");
  String role = (String) session.getAttribute("role");
  Map<String, Boolean> perms = (Map<String, Boolean>) session.getAttribute("perms");

  if (userName == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  boolean isAdmin = (role != null && "admin".equalsIgnoreCase(role));
  boolean canManage = isAdmin; // admin role = always OK
  if (!canManage) {
    response.sendRedirect("drawer.jsp?page=dashboard");
    return;
  }

  String error = request.getParameter("error");
  String ok = request.getParameter("ok");
%>

<style>
:root{
  --black:#010101;
  --navy:#01074A;
  --mint:#4ABB91;
  --lime:#E3FBA7;
  --card:#ffffff;
  --line: rgba(0,0,0,.10);
}

.ucreate{
  width:100%;
}

.ucreate-head{
  display:flex;
  align-items:flex-end;
  justify-content:space-between;
  gap:12px;
  padding:6px 4px 12px;
  border-bottom:1px solid var(--line);
  margin-bottom:12px;
}

.ucreate-title{
  font-size:20px;
  font-weight:1000;
  color:var(--navy);
}
.ucreate-sub{
  margin-top:4px;
  font-size:12px;
  color:rgba(0,0,0,.55);
}

.ucreate-card{
  background:var(--card);
  border:1px solid var(--line);
  border-radius:16px;
  box-shadow:0 10px 24px rgba(0,0,0,.10);
  overflow:hidden;
}

.ucreate-card-head{
  padding:14px 16px;
  background:rgba(1,7,74,.04);
  border-bottom:1px solid rgba(0,0,0,.08);
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:10px;
}
.ucreate-card-head .badge{
  font-size:11px;
  font-weight:1000;
  padding:6px 10px;
  border-radius:999px;
  border:1px solid rgba(74,187,145,.28);
  background:rgba(74,187,145,.18);
  color:var(--navy);
}

.ucreate-body{
  padding:16px;
}

.alert{
  border-radius:14px;
  padding:12px 14px;
  font-weight:900;
  margin-bottom:12px;
  border:1px solid rgba(0,0,0,.10);
}
.alert.ok{
  background:rgba(74,187,145,.12);
  border-color:rgba(74,187,145,.28);
  color:#0c5137;
}
.alert.err{
  background:rgba(255,0,0,.06);
  border-color:rgba(255,0,0,.18);
  color:#7a0000;
}

.form-grid{
  display:grid;
  grid-template-columns: 180px 1fr;
  gap:12px 14px;
  align-items:center;
}

.label{
  font-weight:1000;
  color:rgba(0,0,0,.70);
}

.input, .select{
  width:100%;
  padding:11px 12px;
  border-radius:12px;
  border:1px solid rgba(0,0,0,.14);
  outline:none;
  background:#fff;
}
.input:focus, .select:focus{
  border-color:rgba(1,7,74,.45);
  box-shadow:0 0 0 3px rgba(1,7,74,.10);
}

.help{
  grid-column: 2 / 3;
  font-size:12px;
  color:rgba(0,0,0,.55);
  margin-top:-6px;
}

.actions{
  margin-top:16px;
  display:flex;
  gap:10px;
  justify-content:flex-end;
  flex-wrap:wrap;
}

.btn{
  border:none;
  cursor:pointer;
  font-weight:1000;
  padding:10px 14px;
  border-radius:12px;
  transition:.15s;
}
.btn-primary{
  background:var(--navy);
  color:#fff;
}
.btn-primary:hover{ filter:brightness(1.05); }
.btn-ghost{
  background:rgba(0,0,0,.06);
  color:#222;
}
.btn-ghost:hover{ background:rgba(0,0,0,.10); }

@media (max-width: 720px){
  .form-grid{ grid-template-columns: 1fr; }
  .help{ grid-column: 1 / 2; margin-top:-4px; }
  .actions{ justify-content:stretch; }
  .btn{ width:100%; }
}
</style>

<div class="ucreate">

  <div class="ucreate-head">
    <div>
      <div class="ucreate-title">アカウント作成</div>
      <div class="ucreate-sub">ユーザーを追加します（管理者のみ）</div>
    </div>
  </div>

  <div class="ucreate-card">

    <div class="ucreate-card-head">
      <div style="font-weight:1000; color:var(--navy);">新規ユーザー</div>
      <div class="badge">CREATE USER</div>
    </div>

    <div class="ucreate-body">

      <% if ("1".equals(ok)) { %>
        <div class="alert ok">保存しました。</div>
      <% } %>

      <% if ("1".equals(error)) { %>
        <div class="alert err">入力が不足しています。</div>
      <% } else if ("2".equals(error)) { %>
        <div class="alert err">そのユーザー名は既に存在します。</div>
      <% } %>

      <form action="<%= request.getContextPath() %>/CreateUserServlet" method="post" autocomplete="off">
        <div class="form-grid">

          <div class="label">ユーザー名</div>
          <div>
            <input class="input" type="text" name="username" required placeholder="例：staff01">
          </div>
          <div class="help">※ 半角英数字がおすすめ（スペースなし）</div>

          <div class="label">パスワード</div>
          <div>
            <input class="input" type="password" name="password" required placeholder="********">
          </div>
          <div class="help">※ 8文字以上推奨</div>

          <div class="label">権限</div>
          <div>
            <select class="select" name="role">
              <option value="staff">staff</option>
              <option value="admin">admin</option>
            </select>
          </div>
          <div class="help">※ admin は全権限、staff は権限設定に従います</div>

        </div>

        <div class="actions">
          <a class="btn btn-ghost" href="drawer.jsp?page=dashboard" style="text-decoration:none; display:inline-block; text-align:center;">
            戻る
          </a>
          <button class="btn btn-primary" type="submit">保存</button>
        </div>
      </form>

    </div>
  </div>

</div>
