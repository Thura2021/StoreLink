<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<style>
/* ===== Scoped styles: only for group output area ===== */
.gout {
  width: 100%;
}

.gout-head{
  display:flex;
  align-items:flex-end;
  justify-content:space-between;
  gap:12px;
  padding: 6px 2px 12px;
  border-bottom: 1px solid rgba(0,0,0,.10);
  margin-bottom: 12px;
}

.gout-title{
  font-size: 20px;
  font-weight: 900;
  color: #01074A;
}

.gout-sub{
  margin-top: 4px;
  font-size: 12px;
  color: rgba(0,0,0,.55);
}

.gout-tools{
  display:flex;
  gap:10px;
  align-items:center;
}

.gout-search{
  width: 260px;
  max-width: 42vw;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid rgba(0,0,0,.14);
  outline: none;
}
.gout-search:focus{
  border-color: rgba(1,7,74,.45);
  box-shadow: 0 0 0 3px rgba(1,7,74,.10);
}

.gout-chip{
  font-size: 12px;
  font-weight: 900;
  padding: 6px 10px;
  border-radius: 999px;
  background: rgba(227,251,167,.70);
  color: #01074A;
  border: 1px solid rgba(227,251,167,.95);
  white-space: nowrap;
}

/* Card container */
.gout-card{
  background: #fff;
  border: 1px solid rgba(0,0,0,.10);
  border-radius: 16px;
  box-shadow: 0 10px 24px rgba(0,0,0,.10);
  overflow: hidden;
}

/* Table */
.gout-table-wrap{
  width: 100%;
  overflow: auto;
}

.gout-table{
  width:100%;
  border-collapse: collapse;
  background:#fff;
  min-width: 520px;
}

.gout-table thead th{
  position: sticky;
  top: 0;
  background: #01074A;
  color: #fff;
  padding: 10px 10px;
  font-size: 13px;
  text-align: left;
  z-index: 1;
}

.gout-table tbody td{
  padding: 10px 10px;
  border-bottom: 1px solid rgba(0,0,0,.08);
  font-size: 13px;
}

.gout-table tbody tr:hover{
  background: rgba(227,251,167,.35);
}

.gout-code{
  font-weight: 900;
  color: #01074A;
}

.gout-empty{
  padding: 18px 12px;
  text-align:center;
  color: rgba(0,0,0,.55);
}

/* Mobile */
@media (max-width: 520px){
  .gout-tools{ width:100%; }
  .gout-search{ width:100%; max-width:100%; }
  .gout-head{ align-items:flex-start; flex-direction:column; }
}
</style>

<div class="gout">

  <div class="gout-head">
    <div>
      <div class="gout-title">グループ一覧</div>
      <div class="gout-sub">登録済みのグループを確認できます。</div>
    </div>

    <div class="gout-tools">
      <input id="goutSearch" class="gout-search" type="search" placeholder="検索（コード / 名前 / メモ）" oninput="filterGroups()">
      <span class="gout-chip" id="goutCount">件数：-</span>
    </div>
  </div>

  <div class="gout-card">
    <div class="gout-table-wrap">
      <table class="gout-table" id="goutTable">
        <thead>
          <tr>
            <th style="width:140px;">コード</th>
            <th>グループ名</th>
            <th style="width:240px;">メモ</th>
          </tr>
        </thead>
        <tbody>
          <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            int count = 0;

            try {
              Class.forName("com.mysql.cj.jdbc.Driver");
              con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
                "root", ""
              );

              String sql = "SELECT code, name, note FROM groups ORDER BY code";
              ps = con.prepareStatement(sql);
              rs = ps.executeQuery();

              boolean hasRow = false;
              while (rs.next()) {
                hasRow = true;
                count++;

                String code = rs.getString("code");
                String name = rs.getString("name");
                String note = rs.getString("note");
                if (note == null) note = "";
          %>
              <tr>
                <td class="gout-code"><%= code %></td>
                <td><%= name %></td>
                <td><%= note %></td>
              </tr>
          <%
              }

              if (!hasRow) {
          %>
              <tr>
                <td colspan="3" class="gout-empty">まだデータがありません。</td>
              </tr>
          <%
              }
            } catch (Exception e) {
          %>
              <tr>
                <td colspan="3" class="gout-empty">読み込みエラー：<%= e.getMessage() %></td>
              </tr>
          <%
            } finally {
              try { if (rs != null) rs.close(); } catch (Exception e) {}
              try { if (ps != null) ps.close(); } catch (Exception e) {}
              try { if (con != null) con.close(); } catch (Exception e) {}
            }
          %>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
  // Show total count (server-side count injected safely via text replace below)
  (function(){
    var chip = document.getElementById("goutCount");
    if(chip){
      chip.textContent = "件数：<%= count %>";
    }
  })();

  function filterGroups(){
    var input = document.getElementById("goutSearch");
    var q = (input ? input.value : "").toLowerCase().trim();

    var table = document.getElementById("goutTable");
    if(!table) return;

    var rows = table.tBodies[0].rows;
    var shown = 0;

    for(var i=0;i<rows.length;i++){
      var row = rows[i];
      // skip empty/error row (colspan)
      if(row.cells.length < 3){
        row.style.display = "";
        continue;
      }
      var text = (row.cells[0].innerText + " " + row.cells[1].innerText + " " + row.cells[2].innerText).toLowerCase();
      var ok = (q === "" || text.indexOf(q) !== -1);
      row.style.display = ok ? "" : "none";
      if(ok) shown++;
    }

    var chip = document.getElementById("goutCount");
    if(chip){
      chip.textContent = "表示：" + shown + " / <%= count %>";
    }
  }
</script>
