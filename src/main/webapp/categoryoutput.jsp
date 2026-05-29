<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<style>
/* ===== Scoped styles: only for category output area ===== */
.cout { width: 100%; }

.cout-head{
  display:flex;
  align-items:flex-end;
  justify-content:space-between;
  gap:12px;
  padding: 6px 2px 12px;
  border-bottom: 1px solid rgba(0,0,0,.10);
  margin-bottom: 12px;
}

.cout-title{
  font-size: 20px;
  font-weight: 900;
  color: #01074A;
}

.cout-sub{
  margin-top: 4px;
  font-size: 12px;
  color: rgba(0,0,0,.55);
}

.cout-tools{
  display:flex;
  gap:10px;
  align-items:center;
  flex-wrap: wrap;
}

.cout-search{
  width: 320px;
  max-width: 52vw;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid rgba(0,0,0,.14);
  outline: none;
}
.cout-search:focus{
  border-color: rgba(1,7,74,.45);
  box-shadow: 0 0 0 3px rgba(1,7,74,.10);
}

.cout-chip{
  font-size: 12px;
  font-weight: 900;
  padding: 6px 10px;
  border-radius: 999px;
  background: rgba(227,251,167,.70);
  color: #01074A;
  border: 1px solid rgba(227,251,167,.95);
  white-space: nowrap;
}

/* Card */
.cout-card{
  background: #fff;
  border: 1px solid rgba(0,0,0,.10);
  border-radius: 16px;
  box-shadow: 0 10px 24px rgba(0,0,0,.10);
  overflow: hidden;
}

/* Table */
.cout-table-wrap{
  width: 100%;
  overflow: auto;
}

.cout-table{
  width:100%;
  border-collapse: collapse;
  background:#fff;
  min-width: 760px;
}

.cout-table thead th{
  position: sticky;
  top: 0;
  background: #01074A;
  color: #fff;
  padding: 10px 10px;
  font-size: 13px;
  text-align: left;
  z-index: 1;
  white-space: nowrap;
}

.cout-table tbody td{
  padding: 10px 10px;
  border-bottom: 1px solid rgba(0,0,0,.08);
  font-size: 13px;
  white-space: nowrap;
}

.cout-table tbody tr:hover{
  background: rgba(227,251,167,.35);
}

.cout-code{
  font-weight: 900;
  color: #01074A;
}

.cout-empty{
  padding: 18px 12px;
  text-align:center;
  color: rgba(0,0,0,.55);
}

@media (max-width: 520px){
  .cout-head{ align-items:flex-start; flex-direction:column; }
  .cout-tools{ width:100%; }
  .cout-search{ width:100%; max-width:100%; }
}
</style>

<div class="cout">

  <div class="cout-head">
    <div>
      <div class="cout-title">カテゴリー一覧</div>
      <div class="cout-sub">登録済みのカテゴリーを確認できます。</div>
    </div>

    <div class="cout-tools">
      <input id="coutSearch" class="cout-search" type="search"
             placeholder="検索（グループ / カテゴリーコード / 名前 / メモ）"
             oninput="filterCategories()">
      <span class="cout-chip" id="coutCount">件数：-</span>
    </div>
  </div>

  <div class="cout-card">
    <div class="cout-table-wrap">
      <table class="cout-table" id="coutTable">
        <thead>
          <tr>
            <th style="width:160px;">グループ</th>
            <th style="width:140px;">カテゴリーコード</th>
            <th>カテゴリー名</th>
            <th style="width:260px;">メモ</th>
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

              // ✅ group name join (group_code -> groups.name)
              String sql =
                "SELECT c.group_code, g.name AS group_name, c.code AS category_code, c.name AS category_name, c.note " +
                "FROM categories c " +
                "LEFT JOIN groups g ON c.group_code = g.code " +
                "ORDER BY c.group_code, c.code";

              ps = con.prepareStatement(sql);
              rs = ps.executeQuery();

              boolean hasRow = false;
              while (rs.next()) {
                hasRow = true;
                count++;

                String groupCode = rs.getString("group_code");
                String groupName = rs.getString("group_name");
                if (groupName == null) groupName = "";

                String categoryCode = rs.getString("category_code");
                String categoryName = rs.getString("category_name");
                String note = rs.getString("note");
                if (note == null) note = "";
          %>
              <tr>
                <td><span class="cout-code"><%= groupCode %></span>　<%= groupName %></td>
                <td class="cout-code"><%= categoryCode %></td>
                <td><%= categoryName %></td>
                <td><%= note %></td>
              </tr>
          <%
              }

              if (!hasRow) {
          %>
              <tr>
                <td colspan="4" class="cout-empty">まだデータがありません。</td>
              </tr>
          <%
              }
            } catch (Exception e) {
          %>
              <tr>
                <td colspan="4" class="cout-empty">読み込みエラー：<%= e.getMessage() %></td>
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
  (function(){
    var chip = document.getElementById("coutCount");
    if(chip){
      chip.textContent = "件数：<%= count %>";
    }
  })();

  function filterCategories(){
    var input = document.getElementById("coutSearch");
    var q = (input ? input.value : "").toLowerCase().trim();

    var table = document.getElementById("coutTable");
    if(!table) return;

    var rows = table.tBodies[0].rows;
    var shown = 0;

    for(var i=0;i<rows.length;i++){
      var row = rows[i];

      // skip empty/error row (colspan)
      if(row.cells.length < 4){
        row.style.display = "";
        continue;
      }

      var text =
        (row.cells[0].innerText + " " +
         row.cells[1].innerText + " " +
         row.cells[2].innerText + " " +
         row.cells[3].innerText).toLowerCase();

      var ok = (q === "" || text.indexOf(q) !== -1);
      row.style.display = ok ? "" : "none";
      if(ok) shown++;
    }

    var chip = document.getElementById("coutCount");
    if(chip){
      chip.textContent = "表示：" + shown + " / <%= count %>";
    }
  }
</script>
