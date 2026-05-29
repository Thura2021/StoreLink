<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<style>
/* ===== Scoped styles: table output ===== */
.tout{ width:100%; }

.tout-head{
  display:flex;
  align-items:flex-end;
  justify-content:space-between;
  gap:12px;
  padding:6px 2px 12px;
  border-bottom:1px solid rgba(0,0,0,.10);
  margin-bottom:12px;
}

.tout-title{
  font-size:20px;
  font-weight:900;
  color:#01074A;
}
.tout-sub{
  margin-top:4px;
  font-size:12px;
  color:rgba(0,0,0,.55);
}

.tout-tools{
  display:flex;
  gap:10px;
  align-items:center;
  flex-wrap:wrap;
}

.tout-search{
  width:300px;
  max-width:52vw;
  padding:10px 12px;
  border-radius:12px;
  border:1px solid rgba(0,0,0,.14);
  outline:none;
}
.tout-search:focus{
  border-color:rgba(1,7,74,.45);
  box-shadow:0 0 0 3px rgba(1,7,74,.10);
}

.tout-chip{
  font-size:12px;
  font-weight:900;
  padding:6px 10px;
  border-radius:999px;
  background:rgba(227,251,167,.70);
  color:#01074A;
  border:1px solid rgba(227,251,167,.95);
  white-space:nowrap;
}

/* Card */
.tout-card{
  background:#fff;
  border:1px solid rgba(0,0,0,.10);
  border-radius:16px;
  box-shadow:0 10px 24px rgba(0,0,0,.10);
  overflow:hidden;
}

/* Table */
.tout-table-wrap{ width:100%; overflow:auto; }

.tout-table{
  width:100%;
  border-collapse:collapse;
  min-width:820px;
  background:#fff;
}

.tout-table thead th{
  position:sticky;
  top:0;
  background:#01074A;
  color:#fff;
  padding:10px;
  font-size:13px;
  text-align:left;
  white-space:nowrap;
}

.tout-table tbody td{
  padding:10px;
  border-bottom:1px solid rgba(0,0,0,.08);
  font-size:13px;
  white-space:nowrap;
}

.tout-table tbody tr:hover{
  background:rgba(227,251,167,.35);
}

.tout-code{
  font-weight:900;
  color:#01074A;
}

.tout-empty{
  padding:18px 12px;
  text-align:center;
  color:rgba(0,0,0,.55);
}

@media (max-width:520px){
  .tout-head{ flex-direction:column; align-items:flex-start; }
  .tout-tools{ width:100%; }
  .tout-search{ width:100%; max-width:100%; }
}

/* ===== clickable row ===== */
tr.tout-row{ cursor:pointer; }
tr.tout-row:hover{ background:rgba(227,251,167,.35); }

/* ===== table detail panel (right panel / mobile bottom sheet) ===== */
.tdetail-overlay{
  position:fixed; inset:0;
  background:rgba(0,0,0,.35);
  opacity:0; pointer-events:none;
  transition:.2s;
  z-index:1600;
}
.tdetail-overlay.show{ opacity:1; pointer-events:auto; }

.tdetail-panel{
  position:fixed;
  top:0; right:0;
  height:100vh;
  width:520px;
  max-width:92vw;
  background:#fff;
  box-shadow:-20px 0 40px rgba(0,0,0,.18);
  transform:translateX(110%);
  transition:.25s;
  z-index:1700;
  display:flex;
  flex-direction:column;
}
.tdetail-panel.show{ transform:translateX(0); }

.tdetail-head{
  padding:14px;
  border-bottom:1px solid rgba(0,0,0,.10);
  display:flex;
  align-items:flex-start;
  justify-content:space-between;
  gap:10px;
}
.tdetail-title{
  font-weight:1000;
  color:#01074A;
  font-size:16px;
}
.tdetail-sub{
  margin-top:4px;
  font-size:12px;
  color:rgba(0,0,0,.55);
}
.tdetail-close{
  border:none;
  cursor:pointer;
  font-weight:1000;
  padding:8px 10px;
  border-radius:10px;
  background:rgba(0,0,0,.06);
  color:#333;
}

.tdetail-body{ flex:1; overflow:auto; padding:14px; }

.tdetail-info{
  display:flex; gap:10px; flex-wrap:wrap;
  margin-bottom:10px;
}
.tdetail-chip{
  font-size:12px; font-weight:900;
  padding:6px 10px; border-radius:999px;
  background:rgba(227,251,167,.70);
  color:#01074A;
  border:1px solid rgba(227,251,167,.95);
  white-space:nowrap;
}

.tdetail-list{
  width:100%;
  border-collapse:collapse;
}
.tdetail-list th{
  text-align:left;
  font-size:12px;
  background:#01074A;
  color:#fff;
  padding:10px;
  white-space:nowrap;
}
.tdetail-list td{
  padding:10px;
  border-bottom:1px solid rgba(0,0,0,.08);
  font-size:13px;
  vertical-align:top;
}
.tdetail-code{ font-weight:1000; color:#01074A; }
.tdetail-qty{
  font-weight:1000;
  display:inline-block;
  min-width:44px;
  text-align:center;
  padding:6px 10px;
  border-radius:999px;
  background:rgba(0,0,0,.06);
}
.tdetail-qty.low{
  background:rgba(255,80,80,.15);
  border:1px solid rgba(255,80,80,.30);
}

/* mobile bottom sheet */
@media (max-width: 820px){
  .tdetail-panel{
    left:0; right:0;
    top:auto; bottom:0;
    width:100%;
    height:78vh;
    border-top-left-radius:16px;
    border-top-right-radius:16px;
    transform:translateY(110%);
  }
  .tdetail-panel.show{ transform:translateY(0); }
}
</style>

<div class="tout">

  <div class="tout-head">
    <div>
      <div class="tout-title">テーブル一覧</div>
      <div class="tout-sub">登録済みのテーブルを確認できます。（行をクリックすると中の商品が表示されます）</div>
    </div>

    <div class="tout-tools">
      <input id="toutSearch" class="tout-search" type="search"
             placeholder="検索（グループ / テーブルコード / 名前 / メモ）"
             oninput="filterTables()">
      <span class="tout-chip" id="toutCount">件数：-</span>
    </div>
  </div>

  <div class="tout-card">
    <div class="tout-table-wrap">
      <table class="tout-table" id="toutTable">
        <thead>
          <tr>
            <th style="width:160px;">グループ</th>
            <th style="width:140px;">テーブルコード</th>
            <th>テーブル名</th>
            <th style="width:260px;">メモ</th>
          </tr>
        </thead>
        <tbody>
          <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            int count = 0;

            try{
              Class.forName("com.mysql.cj.jdbc.Driver");
              con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
                "root", ""
              );

              // ✅ ここは元のSQL 그대로
              String sql =
                "SELECT t.code AS table_code, t.name AS table_name, t.note, " +
                "t.group_code, g.name AS group_name " +
                "FROM tables t " +
                "LEFT JOIN groups g ON t.group_code = g.code " +
                "ORDER BY t.group_code, t.code";

              ps = con.prepareStatement(sql);
              rs = ps.executeQuery();

              boolean hasRow = false;
              while(rs.next()){
                hasRow = true;
                count++;

                String groupCode = rs.getString("group_code");
                String groupName = rs.getString("group_name");
                if(groupName == null) groupName = "";

                String tableCode = rs.getString("table_code");
                String tableName = rs.getString("table_name");

                String note = rs.getString("note");
                if(note == null) note = "";

                // safe for dataset
                String tableNameSafe = (tableName == null ? "" : tableName.replace("\"","&quot;"));
          %>
              <tr class="tout-row"
                  onclick="openTableItems(this)"
                  data-table="<%= tableCode %>"
                  data-tname="<%= tableNameSafe %>"
                  data-group="<%= groupCode %>">
                <td><span class="tout-code"><%= groupCode %></span>　<%= groupName %></td>
                <td class="tout-code"><%= tableCode %></td>
                <td><%= tableName %></td>
                <td><%= note %></td>
              </tr>
          <%
              }

              if(!hasRow){
          %>
              <tr>
                <td colspan="4" class="tout-empty">まだデータがありません。</td>
              </tr>
          <%
              }
            }catch(Exception e){
          %>
              <tr>
                <td colspan="4" class="tout-empty">読み込みエラー：<%= e.getMessage() %></td>
              </tr>
          <%
            }finally{
              try{ if(rs!=null) rs.close(); }catch(Exception e){}
              try{ if(ps!=null) ps.close(); }catch(Exception e){}
              try{ if(con!=null) con.close(); }catch(Exception e){}
            }
          %>
        </tbody>
      </table>
    </div>
  </div>

</div>

<!-- ===== Table Items Detail Panel ===== -->
<div class="tdetail-overlay" id="tDetailOverlay" onclick="closeTableItems()"></div>

<aside class="tdetail-panel" id="tDetailPanel" aria-hidden="true">
  <div class="tdetail-head">
    <div>
      <div class="tdetail-title" id="tTitle">テーブル詳細</div>
      <div class="tdetail-sub" id="tSub">-</div>
    </div>
    <button class="tdetail-close" type="button" onclick="closeTableItems()">閉じる</button>
  </div>

  <div class="tdetail-body">
    <div class="tdetail-info">
      <span class="tdetail-chip" id="tCountChip">件数：-</span>
    </div>

    <div id="tBody">
      <div style="padding:12px;border:1px solid rgba(0,0,0,.10);border-radius:12px;background:#fafafa;font-weight:900;">
        行をクリックすると、このテーブルの商品が表示されます。
      </div>
    </div>
  </div>
</aside>

<script>
(function(){
  var chip = document.getElementById("toutCount");
  if(chip){
    chip.textContent = "件数：<%= count %>";
  }
})();

function filterTables(){
  var q = document.getElementById("toutSearch").value.toLowerCase().trim();
  var table = document.getElementById("toutTable");
  if(!table) return;

  var rows = table.tBodies[0].rows;
  var shown = 0;

  for(var i=0;i<rows.length;i++){
    var row = rows[i];
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

  var chip = document.getElementById("toutCount");
  if(chip){
    chip.textContent = "表示：" + shown + " / <%= count %>";
  }
}

/* =========================
   ✅ Table items panel logic
========================= */
let __TABLE_CURRENT__ = null;

function openTableItems(tr){
  const tableCode = tr.dataset.table || "";
  const tableName = tr.dataset.tname || "";
  const groupCode = tr.dataset.group || "";

  __TABLE_CURRENT__ = { tableCode, tableName, groupCode };

  // open panel
  const o = document.getElementById("tDetailOverlay");
  const p = document.getElementById("tDetailPanel");
  if(o) o.classList.add("show");
  if(p){
    p.classList.add("show");
    p.setAttribute("aria-hidden","false");
  }
  document.body.style.overflow = "hidden";

  // header
  const title = document.getElementById("tTitle");
  const sub   = document.getElementById("tSub");
  if(title) title.textContent = "テーブル：" + (tableName || "-") + " (" + tableCode + ")";
  if(sub)   sub.textContent   = "グループ：" + (groupCode || "-");

  // loading
  const body = document.getElementById("tBody");
  if(body){
    body.innerHTML =
      "<div style='padding:12px;border:1px solid rgba(0,0,0,.10);border-radius:12px;background:#fafafa;font-weight:900;'>読み込み中...</div>";
  }

  // fetch items in table
  fetch("TableItemsServlet?table_code=" + encodeURIComponent(tableCode))
    .then(r => r.json())
    .then(data => {
      if(!data || !data.ok){
        const msg = (data && data.message) ? escapeHtml(data.message) : "読み込みエラー";
        if(body){
          body.innerHTML =
            "<div style='padding:12px;border:1px solid rgba(255,0,0,.20);border-radius:12px;background:rgba(255,0,0,.06);font-weight:900;color:#7a0000;'>" +
            msg +
            "</div>";
        }
        return;
      }

      const rows = data.rows || [];
      const chip = document.getElementById("tCountChip");
      if(chip) chip.textContent = "件数：" + rows.length;

      if(rows.length === 0){
        if(body){
          body.innerHTML =
            "<div style='padding:12px;border:1px solid rgba(0,0,0,.10);border-radius:12px;background:#fafafa;font-weight:900;'>このテーブルには商品がありません。</div>";
        }
        return;
      }

      let html = "";
      html += "<table class='tdetail-list'>";
      html += "<thead><tr><th style='width:130px;'>商品コード</th><th>商品名</th><th style='width:120px;'>在庫</th><th style='width:120px;'>価格</th></tr></thead>";
      html += "<tbody>";

      for(let i=0;i<rows.length;i++){
        const code = rows[i].code || "";
        const name = rows[i].name || "";
        const qty  = Number(rows[i].qty || 0);
        const price= Number(rows[i].price || 0);

        const lowClass = (qty <= 5) ? "low" : "";
        html += "<tr>";
        html += "<td class='tdetail-code'>" + escapeHtml(code) + "</td>";
        html += "<td>" + escapeHtml(name) + "</td>";
        html += "<td><span class='tdetail-qty " + lowClass + "'>" + qty + "</span></td>";
        html += "<td>¥" + price + "</td>";
        html += "</tr>";
      }

      html += "</tbody></table>";

      if(body) body.innerHTML = html;
    })
    .catch(() => {
      if(body){
        body.innerHTML =
          "<div style='padding:12px;border:1px solid rgba(255,0,0,.20);border-radius:12px;background:rgba(255,0,0,.06);font-weight:900;color:#7a0000;'>" +
          "読み込みエラー" +
          "</div>";
      }
    });
}

function closeTableItems(){
  const o = document.getElementById("tDetailOverlay");
  const p = document.getElementById("tDetailPanel");
  if(o) o.classList.remove("show");
  if(p){
    p.classList.remove("show");
    p.setAttribute("aria-hidden","true");
  }
  document.body.style.overflow = "";
}

function escapeHtml(s){
  if(s==null) return "";
  return String(s)
    .replace(/&/g,"&amp;")
    .replace(/</g,"&lt;")
    .replace(/>/g,"&gt;")
    .replace(/"/g,"&quot;");
}

// ESC close
document.addEventListener("keydown", function(e){
  if(e.key === "Escape"){
    closeTableItems();
  }
});
</script>
