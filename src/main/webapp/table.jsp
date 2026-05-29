<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Table Maker</title>

  <style>
:root{
  --navy:#01074A;
  --bg:#f4f7f6;
  --line: rgba(0,0,0,.12);
}
body{
  margin:0;
  background:var(--bg);
  font-family:"Segoe UI",sans-serif;
}
.hd{
  max-width:720px;
  margin: 0 auto;
  padding: 8px 0 12px;
}
h2{
  margin:0 0 6px;
  font-size:20px;
  font-weight:1000;
  color:var(--navy);
}
.sub{
  font-size:12px;
  color:rgba(0,0,0,.55);
  font-weight:800;
}
.card{
  max-width:720px;
  margin: 0 auto;
  background:#fff;
  padding:16px;
  border-radius:16px;
  box-shadow:0 10px 24px rgba(0,0,0,.10);
  border:1px solid var(--line);
}
label{
  display:block;
  margin-top:12px;
  font-size:12px;
  font-weight:900;
  color:#555;
}
input,select{
  width:100%;
  padding:12px;
  border-radius:12px;
  border:1px solid rgba(0,0,0,.18);
  margin-top:6px;
  outline:none;
  background:#fff;
}
input:focus, select:focus{
  border-color: rgba(1,7,74,.35);
  box-shadow: 0 0 0 3px rgba(1,7,74,.08);
}

/* ✅ one row buttons */
.row{
  display:flex;
  gap:10px;
  justify-content:flex-end;
  align-items:center;
  flex-wrap:wrap;
  margin-top:16px;
}
.btn{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  padding:12px 16px;
  border-radius:12px;
  font-weight:1000;
  text-decoration:none;
  border:none;
  cursor:pointer;
}
.btn-primary{
  background:var(--navy);
  color:#fff;
}
.btn-ghost{
  background:rgba(1,7,74,.08);
  color:var(--navy);
  border:1px solid rgba(1,7,74,.18);
}
.btn:hover{ opacity:.92; }
  </style>

  <script>
    function fetchTableName() {
      const code = document.getElementById("code").value;
      const xhr = new XMLHttpRequest();
      xhr.open("GET", "GetTableNameServlet?code=" + encodeURIComponent(code), true);
      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
          document.getElementById("name").value = xhr.responseText;
        }
      };
      xhr.send();
    }

    function fetchTableCodeIfExists() {
      const name = document.getElementById("name").value;
      const xhr = new XMLHttpRequest();
      xhr.open("GET", "GetTableCodeServlet?name=" + encodeURIComponent(name), true);
      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
          const result = xhr.responseText.trim();
          if (result !== "") {
            document.getElementById("code").value = result;
          }
        }
      };
      xhr.send();
    }
  </script>
</head>

<body>
  <div class="hd">
    <h2>テーブルを作成</h2>
    <div class="sub">保存するとこの画面に戻ります。次へで商品作成へ進みます。</div>
  </div>

  <div class="card">
    <form action="<%= request.getContextPath() %>/TableServlet" method="post">
      <!-- ✅ Save ပြီးရင် ဒီ page (drawer) ကိုပဲပြန်လာ -->
      <input type="hidden" name="returnTo" value="drawer.jsp?page=table_add">

      <!-- Group Code -->
      <label>グループ:</label>
      <select name="group_code" required>
        <%
          Connection conG=null; Statement stG=null; ResultSet rsG=null;
          try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            conG = DriverManager.getConnection("jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8","root","");
            stG = conG.createStatement();
            rsG = stG.executeQuery("SELECT code, name FROM groups ORDER BY code");
            while(rsG.next()){
              String gcode = rsG.getString("code");
              String gname = rsG.getString("name");
        %>
          <option value="<%= gcode %>"><%= gcode %> - <%= (gname==null?"":gname) %></option>
        <%
            }
          }catch(Exception e){
            // ignore
          }finally{
            try{ if(rsG!=null) rsG.close(); }catch(Exception e){}
            try{ if(stG!=null) stG.close(); }catch(Exception e){}
            try{ if(conG!=null) conG.close(); }catch(Exception e){}
          }
        %>
      </select>

      <!-- Table Code -->
      <label>テーブルコード:</label>
      <input list="codeList" id="code" name="code" onblur="fetchTableName()" required>

      <datalist id="codeList">
        <%
          Connection con1=null; Statement st1=null; ResultSet rs1=null;
          try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            con1 = DriverManager.getConnection("jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8","root","");
            st1 = con1.createStatement();
            rs1 = st1.executeQuery("SELECT code FROM `tables` ORDER BY code");
            while(rs1.next()){
              String tcode = rs1.getString("code");
        %>
          <option value="<%= tcode %>">
        <%
            }
          }catch(Exception e){
            // ignore
          }finally{
            try{ if(rs1!=null) rs1.close(); }catch(Exception e){}
            try{ if(st1!=null) st1.close(); }catch(Exception e){}
            try{ if(con1!=null) con1.close(); }catch(Exception e){}
          }
        %>
      </datalist>

      <!-- Table Name -->
      <label>テーブル名:</label>
      <!-- ✅ fetchTableCode() မဟုတ်! IfExists သုံး -->
      <input list="nameList" id="name" name="name" onblur="fetchTableCodeIfExists()" required>

      <datalist id="nameList">
        <%
          Connection con2=null; Statement st2=null; ResultSet rs2=null;
          try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            con2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8","root","");
            st2 = con2.createStatement();
            rs2 = st2.executeQuery("SELECT DISTINCT name FROM `tables` ORDER BY name");
            while(rs2.next()){
              String tname = rs2.getString("name");
        %>
          <option value="<%= tname %>">
        <%
            }
          }catch(Exception e){
            // ignore
          }finally{
            try{ if(rs2!=null) rs2.close(); }catch(Exception e){}
            try{ if(st2!=null) st2.close(); }catch(Exception e){}
            try{ if(con2!=null) con2.close(); }catch(Exception e){}
          }
        %>
      </datalist>

      <label>メモ:</label>
      <input type="text" name="note">

      <!-- ✅ one row buttons -->
      <div class="row">
        <button class="btn btn-primary" type="submit">保存</button>
        <a class="btn btn-ghost" href="drawer.jsp?page=table_list">戻る</a>
        <a class="btn btn-ghost" href="drawer.jsp?page=item_add">次へ</a>
      </div>
    </form>
  </div>
</body>
</html>
