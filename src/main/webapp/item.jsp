<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>商品登録</title>

<style>
:root{
  --black:#010101;
  --navy:#01074A;
  --mint:#4ABB91;
  --lime:#E3FBA7;
}
*{ box-sizing:border-box; font-family:"Segoe UI",sans-serif; }
body{ margin:0; background:#f4f7f6; }

.form-wrap{
  width:100%;
  max-width:820px;
  margin:0 auto;
  padding:16px;
}
.form-head{
  display:flex;
  align-items:flex-end;
  justify-content:space-between;
  gap:10px;
  padding:6px 2px 12px;
  border-bottom:1px solid rgba(0,0,0,.10);
  margin-bottom:12px;
}
.form-title{ font-size:20px; font-weight:1000; color:var(--navy); }
.form-sub{ margin-top:4px; font-size:12px; color:rgba(0,0,0,.55); }

.card{
  background:#fff;
  border:1px solid rgba(0,0,0,.10);
  border-radius:16px;
  box-shadow:0 10px 24px rgba(0,0,0,.10);
  padding:14px;
}

.error{
  background:rgba(255,70,70,.10);
  border:1px solid rgba(255,70,70,.28);
  color:rgba(140,0,0,.9);
  padding:10px 12px;
  border-radius:12px;
  font-weight:900;
  font-size:13px;
  margin-bottom:12px;
}

.grid{
  display:grid;
  grid-template-columns: 1fr 1fr;
  gap:12px;
}
@media (max-width: 680px){
  .grid{ grid-template-columns:1fr; }
}

.field{ display:flex; flex-direction:column; gap:6px; }
label{ font-size:12px; font-weight:900; color:rgba(0,0,0,.70); }

input, select{
  width:100%;
  padding:11px 12px;
  border-radius:12px;
  border:1px solid rgba(0,0,0,.14);
  outline:none;
  background:#fff;
}
input:focus, select:focus{
  border-color: rgba(1,7,74,.45);
  box-shadow: 0 0 0 3px rgba(1,7,74,.10);
}

.row{
  display:flex;
  gap:10px;
  flex-wrap:wrap;
  margin-top:12px;
}

.btn{
  border:none;
  padding:12px 14px;
  border-radius:12px;
  font-weight:1000;
  cursor:pointer;
  transition:.2s;
}
.btn-primary{
  background:var(--navy);
  color:#fff;
}
.btn-primary:hover{
  background:var(--black);
  transform:translateY(-1px);
  box-shadow:0 12px 22px rgba(0,0,0,.18);
}
.btn-ghost{
  background:rgba(1,7,74,.08);
  color:var(--navy);
  border:1px solid rgba(1,7,74,.18);
  text-decoration:none;
  display:inline-flex;
  align-items:center;
}
.btn-ghost:hover{ background:rgba(227,251,167,.55); }

.hint{
  font-size:12px;
  color:rgba(0,0,0,.55);
  margin-top:6px;
}
</style>
</head>

<body>
<div class="form-wrap">

  <div class="form-head">
    <div>
      <div class="form-title">商品登録</div>
      <div class="form-sub">必要事項を入力して保存してください。</div>
    </div>
  </div>

  <div class="card">
    <% if (request.getAttribute("error") != null) { %>
      <div class="error"><%= request.getAttribute("error") %></div>
    <% } %>

    <!-- ✅ multipart for photo upload -->
    <form action="<%= request.getContextPath() %>/ItemServlet" method="post" enctype="multipart/form-data">

      <div class="grid">

        <!-- Group -->
        <div class="field">
          <label>グループ</label>
          <select name="group_code" required>
            <%
              String selectedGroup = (String)request.getAttribute("group_code");
              try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(
                  "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
                  "root", ""
                );
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT code, name FROM groups ORDER BY code");

                while (rs.next()) {
                  String code = rs.getString("code");
                  String name = rs.getString("name");
            %>
              <option value="<%= code %>" <%= (selectedGroup!=null && code.equals(selectedGroup)) ? "selected" : "" %>>
                <%= code %> - <%= name %>
              </option>
            <%
                }
                rs.close();
                stmt.close();
                con.close();
              } catch (Exception e) {}
            %>
          </select>
        </div>

        <!-- Category -->
        <div class="field">
          <label>カテゴリー</label>
          <select name="category_code" required>
            <%
              String selectedCategory = (String)request.getAttribute("category_code");
              try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(
                  "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
                  "root", ""
                );
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT code, name FROM categories ORDER BY code");

                while (rs.next()) {
                  String code = rs.getString("code");
                  String name = rs.getString("name");
            %>
              <option value="<%= code %>" <%= (selectedCategory!=null && code.equals(selectedCategory)) ? "selected" : "" %>>
                <%= code %> - <%= name %>
              </option>
            <%
                }
                rs.close();
                stmt.close();
                con.close();
              } catch (Exception e) {}
            %>
          </select>
        </div>

        <!-- Table -->
        <div class="field">
          <label>テーブル</label>
          <select name="table_code" required>
            <%
              String selectedTable = (String)request.getAttribute("table_code");
              try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(
                  "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
                  "root", ""
                );
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT code, name FROM `tables` ORDER BY code");

                while (rs.next()) {
                  String code = rs.getString("code");
                  String name = rs.getString("name");
            %>
              <option value="<%= code %>" <%= (selectedTable!=null && code.equals(selectedTable)) ? "selected" : "" %>>
                <%= code %> - <%= name %>
              </option>
            <%
                }
                rs.close();
                stmt.close();
                con.close();
              } catch (Exception e) {}
            %>
          </select>
        </div>

        <!-- Photo -->
        <div class="field">
          <label>写真（任意）</label>
          <input type="file" name="photo" accept="image/*">
          <div class="hint">※ 画像はサーバに保存し、DBにはパスを保存します。</div>
        </div>

        <!-- Item Code -->
        <div class="field">
          <label>商品コード</label>
          <input type="text" name="code"
                 value="<%= request.getAttribute("code") != null ? request.getAttribute("code") : "" %>"
                 required>
        </div>

        <!-- Item Name -->
        <div class="field">
          <label>商品名</label>
          <input type="text" name="name"
                 value="<%= request.getAttribute("name") != null ? request.getAttribute("name") : "" %>"
                 required>
        </div>

        <!-- Qty -->
        <div class="field">
          <label>在庫（数量）</label>
          <input type="number" name="qty" min="0"
                 value="<%= request.getAttribute("qty") != null ? request.getAttribute("qty") : "" %>"
                 required>
        </div>

        <!-- Price -->
        <div class="field">
          <label>価格</label>
          <input type="number" step="0.01" name="price" min="0"
                 value="<%= request.getAttribute("price") != null ? request.getAttribute("price") : "" %>"
                 required>
        </div>

        <!-- Note -->
        <div class="field" style="grid-column:1/-1;">
          <label>メモ</label>
          <input type="text" name="note"
                 value="<%= request.getAttribute("note") != null ? request.getAttribute("note") : "" %>">
        </div>

      </div>

      <div class="row">
        <button class="btn btn-primary" type="submit">保存</button>
        <a class="btn btn-ghost" href="drawer.jsp?page=item">キャンセル</a>
        <a class="btn btn-ghost" href="drawer.jsp?page=item">一覧へ</a>
      </div>

    </form>

  </div>
</div>
</body>
</html>
