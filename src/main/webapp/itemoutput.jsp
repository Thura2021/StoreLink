<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
  String role = (String)session.getAttribute("role");
  Map<String, Boolean> perms = (Map<String, Boolean>)session.getAttribute("perms");

  boolean isAdmin = (role != null && "admin".equalsIgnoreCase(role));
  boolean canView   = isAdmin || (perms!=null && Boolean.TRUE.equals(perms.get("VIEW_ITEM")));
  boolean canExport = isAdmin || (perms!=null && Boolean.TRUE.equals(perms.get("EXPORT_ITEM")));
  boolean canEdit   = isAdmin || (perms!=null && Boolean.TRUE.equals(perms.get("EDIT_ITEM")));
  boolean canImport = isAdmin || (perms!=null && Boolean.TRUE.equals(perms.get("IMPORT_ITEM")));

  if(!canView){
    response.setStatus(403);
%>
  <div style="padding:16px; font-weight:700;">権限がありません。</div>
<%
    return;
  }

  String imp = request.getParameter("imp");
  String n = request.getParameter("n");

  List<String> importErrors = (List<String>)session.getAttribute("importErrors");
  if(importErrors != null) session.removeAttribute("importErrors");
%>

<link rel="stylesheet" href="css/itemoutput.css?v=20260124_groupcat">

<style>
/* mapping: show/open vs active */
.confirm-overlay.show, .confirm-overlay.active{ opacity:1 !important; pointer-events:auto !important; }
.confirm-box.show, .confirm-box.active{ opacity:1 !important; transform:translate(-50%,-50%) scale(1) !important; }

.detail-overlay.show, .detail-overlay.active{ opacity:1 !important; pointer-events:auto !important; }
.detail-panel.open, .detail-panel.active{ transform:none !important; }

/* small modal for import */
.imp-overlay{ position:fixed; inset:0; background:rgba(0,0,0,.35); opacity:0; pointer-events:none; transition:.18s; z-index:9998; }
.imp-box{ position:fixed; left:50%; top:50%; transform:translate(-50%,-50%) scale(.98);
  width:min(520px, calc(100vw - 32px)); background:#fff; border-radius:14px;
  box-shadow:0 18px 50px rgba(0,0,0,.25); opacity:0; pointer-events:none; transition:.18s; z-index:9999;
  padding:14px;
}
.imp-overlay.show{ opacity:1; pointer-events:auto; }
.imp-box.show{ opacity:1; pointer-events:auto; transform:translate(-50%,-50%) scale(1); }
.imp-title{ font-weight:1000; color:#01074A; font-size:16px; }
.imp-sub{ font-size:12px; color:rgba(0,0,0,.55); margin-top:4px; }
.imp-row{ margin-top:12px; display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
.imp-file{ flex:1; min-width:240px; padding:10px 12px; border-radius:12px; border:1px solid rgba(0,0,0,.14); }
.imp-actions{ display:flex; gap:10px; justify-content:flex-end; margin-top:12px; }
.imp-btn{ border:none; padding:10px 14px; border-radius:12px; font-weight:1000; cursor:pointer; }
.imp-ok{ background:#01074A; color:#fff; }
.imp-cancel{ background:rgba(0,0,0,.08); }
.imp-sample{ font-family:ui-monospace, SFMono-Regular, Menlo, monospace; background:#fafafa; border:1px solid rgba(0,0,0,.08);
  border-radius:12px; padding:10px; font-size:12px; margin-top:10px;
}
</style>

<div class="iout">

  <div class="iout-head">
    <div>
      <div class="iout-title">商品一覧</div>
      <div class="iout-sub">登録済みの商品を確認できます。（行をクリックすると詳細が表示されます）</div>

      <% if("ok".equals(imp)){ %>
        <div style="margin-top:8px; padding:10px 12px; border-radius:12px; background:rgba(227,251,167,.55); border:1px solid rgba(227,251,167,.95); font-weight:900;">
          CSV入力（販売）を反映しました：<%= (n==null?"":n) %> 件
        </div>
      <% } else if("err".equals(imp)){ %>
        <div style="margin-top:8px; padding:10px 12px; border-radius:12px; background:rgba(255,0,0,.06); border:1px solid rgba(255,0,0,.20); font-weight:900;">
          CSV入力に失敗しました。エラー内容を確認してください。
        </div>
      <% } %>

      <% if(importErrors != null && !importErrors.isEmpty()){ %>
        <div style="margin-top:8px; padding:10px 12px; border-radius:12px; background:#fff; border:1px dashed rgba(0,0,0,.18);">
          <div style="font-weight:1000; margin-bottom:6px;">CSVエラー</div>
          <ul style="margin:0; padding-left:18px;">
            <% for(String e : importErrors){ %>
              <li style="font-size:12px; color:#b00;"><%= e %></li>
            <% } %>
          </ul>
        </div>
      <% } %>

    </div>

    <div class="iout-tools">
      <% if(canExport){ %>
        <a class="iout-export" href="<%= request.getContextPath() %>/ExportItemsServlet">Excel出力</a>
      <% } %>

      <% if(canImport){ %>
        <button type="button" class="iout-export" style="cursor:pointer;" onclick="openImportModal()">
          CSV入力（販売）
        </button>
      <% } %>

      <input id="ioutSearch" class="iout-search" type="search"
             placeholder="検索（コード / 商品名 / グループ / カテゴリー / テーブル / 登録者）"
             oninput="filterItems()">
      <span class="iout-chip" id="ioutCount">件数：-</span>
    </div>
  </div>

  <div class="iout-card">
    <div class="iout-table-wrap">
      <table class="iout-table" id="ioutTable">
        <thead>
          <tr>
            <th style="width:140px;">商品コード</th>
            <th>商品名</th>
            <th style="width:160px;">グループ</th>
            <th style="width:180px;">カテゴリー</th>
            <th style="width:160px;">テーブル</th>
            <th style="width:120px;">在庫</th>
            <th style="width:120px;">価格</th>
            <th style="width:180px;">登録者</th>
            <th style="width:200px;">登録日</th>
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

            String sql =
              "SELECT " +
              " i.code, i.name, i.group_code, i.category_code, i.table_code, i.qty, i.price, i.note, i.created_by, i.created_at, i.photo, " +
              " g.name AS group_name, c.name AS category_name, t.name AS table_name " +
              "FROM items i " +
              "LEFT JOIN groups g ON i.group_code = g.code " +
              "LEFT JOIN categories c ON i.category_code = c.code " +
              "LEFT JOIN `tables` t ON i.table_code = t.code " +
              "ORDER BY i.created_at DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            boolean hasRow = false;

            while(rs.next()){
              hasRow = true;
              count++;

              String code = rs.getString("code");
              String name = rs.getString("name");

              String groupCode = rs.getString("group_code");
              String categoryCode = rs.getString("category_code");
              String tableCode = rs.getString("table_code");

              String groupName = rs.getString("group_name");
              String categoryName = rs.getString("category_name");
              String tableName = rs.getString("table_name");

              int qty = rs.getInt("qty");
              double price = rs.getDouble("price");

              String note = rs.getString("note");
              String by = rs.getString("created_by");
              Timestamp at = rs.getTimestamp("created_at");
              String photo = rs.getString("photo");

              String gDisp = (groupName == null ? "" : groupName) + (groupCode == null ? "" : " (" + groupCode + ")");
              String cDisp = (categoryName == null ? "" : categoryName) + (categoryCode == null ? "" : " (" + categoryCode + ")");
              String tDisp = (tableName == null ? "" : tableName) + (tableCode == null ? "" : " (" + tableCode + ")");

              String noteSafe = (note == null ? "" : note.replace("\"","&quot;"));
              String nameSafe = (name == null ? "" : name.replace("\"","&quot;"));
              String bySafe   = (by == null ? "" : by.replace("\"","&quot;"));
              String photoSafe= (photo == null ? "" : photo.replace("\"","&quot;"));
        %>
          <tr class="iout-row"
              onclick="openDetail(this)"
              data-code="<%= code %>"
              data-name="<%= nameSafe %>"

              data-group="<%= gDisp.replace("\"","&quot;") %>"
              data-groupcode="<%= groupCode == null ? "" : groupCode %>"

              data-category="<%= cDisp.replace("\"","&quot;") %>"
              data-categorycode="<%= categoryCode == null ? "" : categoryCode %>"

              data-tablecode="<%= tableCode == null ? "" : tableCode %>"
              data-tabledisp="<%= tDisp.replace("\"","&quot;") %>"

              data-qty="<%= qty %>"
              data-price="<%= (int)price %>"
              data-by="<%= bySafe %>"
              data-at="<%= at == null ? "" : at.toString() %>"
              data-note="<%= noteSafe %>"
              data-photo="<%= photoSafe %>"

              data-return="drawer.jsp?page=item_list">
            <td class="iout-code"><%= code %></td>
            <td><%= name %></td>
            <td><%= gDisp %></td>
            <td><%= cDisp %></td>
            <td><%= tDisp %></td>
            <td><%= qty %></td>
            <td>¥<%= (int)price %></td>
            <td><%= by == null ? "" : by %></td>
            <td><%= at == null ? "" : at.toString() %></td>
          </tr>
        <%
            }

            if(!hasRow){
        %>
          <tr><td colspan="9" class="iout-empty">まだデータがありません。</td></tr>
        <%
            }

          }catch(Exception e){
        %>
          <tr><td colspan="9" class="iout-empty">読み込みエラー：<%= e.getMessage() %></td></tr>
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

<!-- ===== Import Modal ===== -->
<div class="imp-overlay" id="impOverlay" onclick="closeImportModal()"></div>
<div class="imp-box" id="impBox">
  <div class="imp-title">CSV入力（販売）</div>
  <div class="imp-sub">CSV を取り込むと在庫が減算され、詳細画面で履歴を確認できます。</div>

  <form action="<%= request.getContextPath() %>/ImportSalesCsvServlet" method="post" enctype="multipart/form-data">
    <div class="imp-row">
      <input class="imp-file" type="file" name="csvFile" accept=".csv,text/csv" required>
    </div>

    <div class="imp-sample">
item_code,qty,note
1871991,2,POS販売
1871995,1,ขายไปแล้ว
    </div>

    <div class="imp-actions">
      <button type="button" class="imp-btn imp-cancel" onclick="closeImportModal()">キャンセル</button>
      <button type="submit" class="imp-btn imp-ok">取込</button>
    </div>
  </form>
</div>

<!-- ===== Detail overlay + panel ===== -->
<div class="detail-overlay" id="detailOverlay" onclick="closeDetail()"></div>

<aside class="detail-panel" id="detailPanel" aria-hidden="true">
  <div class="detail-head">
    <div class="detail-title">商品詳細</div>

    <div class="detail-actions">
      <% if(canEdit){ %>
        <button class="detail-btn detail-edit" type="button" onclick="askEdit()">編集</button>
        <button class="detail-btn detail-delete" type="button" onclick="askDelete()">削除</button>
      <% } %>
      <button class="detail-btn detail-close" type="button" onclick="closeDetail()">閉じる</button>
    </div>
  </div>

  <div class="detail-body">
    <div class="detail-image">
      <img id="dImage" src="images/noimage.png" alt="item">
    </div>

    <!-- View -->
    <div class="detail-card" id="viewCard">
      <div class="detail-row"><div class="detail-k">コード</div><div class="detail-v" id="dCode">-</div></div>
      <div class="detail-row"><div class="detail-k">商品名</div><div class="detail-v" id="dName">-</div></div>
      <div class="detail-row"><div class="detail-k">グループ</div><div class="detail-v" id="dGroup">-</div></div>
      <div class="detail-row"><div class="detail-k">カテゴリー</div><div class="detail-v" id="dCategory">-</div></div>
      <div class="detail-row"><div class="detail-k">テーブル</div><div class="detail-v" id="dTable">-</div></div>
      <div class="detail-row"><div class="detail-k">在庫</div><div class="detail-v" id="dQty">-</div></div>
      <div class="detail-row"><div class="detail-k">価格</div><div class="detail-v" id="dPrice">-</div></div>
      <div class="detail-row"><div class="detail-k">登録者</div><div class="detail-v" id="dBy">-</div></div>
      <div class="detail-row"><div class="detail-k">登録日</div><div class="detail-v" id="dAt">-</div></div>
      <div class="detail-row"><div class="detail-k">メモ</div><div class="detail-v" id="dNote">-</div></div>

      <div id="histBox" style="margin-top:12px; border-top:1px solid rgba(0,0,0,.08); padding-top:10px;">
        <div style="font-weight:1000; color:#01074A; margin-bottom:6px;">在庫履歴（最新10件）</div>
        <div id="histBody"></div>
      </div>
    </div>

    <!-- Edit -->
    <div class="detail-card hidden" id="editCard">
      <div class="detail-row"><div class="detail-k">コード</div><div class="detail-v"><span id="eCode">-</span></div></div>

      <div class="detail-row">
        <div class="detail-k">商品名</div>
        <div class="detail-v"><input id="eName" class="detail-input" type="text"></div>
      </div>

      <%
        // ✅ group options
        Connection conG = null;
        PreparedStatement psG = null;
        ResultSet rsG = null;
        List<String[]> groupOpts = new ArrayList<>();

        try{
          Class.forName("com.mysql.cj.jdbc.Driver");
          conG = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
            "root", ""
          );
          psG = conG.prepareStatement("SELECT code, name FROM groups ORDER BY code");
          rsG = psG.executeQuery();
          while(rsG.next()){
            String gc = rsG.getString("code");
            String gn = rsG.getString("name");
            if(gn==null) gn="";
            groupOpts.add(new String[]{gc, gn});
          }
        }catch(Exception e){
          // ignore
        }finally{
          try{ if(rsG!=null) rsG.close(); }catch(Exception e){}
          try{ if(psG!=null) psG.close(); }catch(Exception e){}
          try{ if(conG!=null) conG.close(); }catch(Exception e){}
        }
      %>

      <%
        // ✅ category options
        Connection conC = null;
        PreparedStatement psC = null;
        ResultSet rsC = null;
        List<String[]> categoryOpts = new ArrayList<>();

        try{
          Class.forName("com.mysql.cj.jdbc.Driver");
          conC = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
            "root", ""
          );
          psC = conC.prepareStatement(
            "SELECT c.code, c.name, c.group_code, g.name AS group_name " +
            "FROM categories c LEFT JOIN groups g ON c.group_code=g.code " +
            "ORDER BY c.group_code, c.code"
          );
          rsC = psC.executeQuery();
          while(rsC.next()){
            String cc = rsC.getString("code");
            String cn = rsC.getString("name");
            String gc = rsC.getString("group_code");
            String gn = rsC.getString("group_name");
            if(cn==null) cn="";
            if(gc==null) gc="";
            if(gn==null) gn="";
            categoryOpts.add(new String[]{cc, cn, gc, gn});
          }
        }catch(Exception e){
          // ignore
        }finally{
          try{ if(rsC!=null) rsC.close(); }catch(Exception e){}
          try{ if(psC!=null) psC.close(); }catch(Exception e){}
          try{ if(conC!=null) conC.close(); }catch(Exception e){}
        }
      %>

      <div class="detail-row">
        <div class="detail-k">グループ</div>
        <div class="detail-v">
          <select id="eGroup" class="detail-input">
            <option value="">-- 選択 --</option>
            <% for(String[] g : groupOpts){ %>
              <option value="<%= g[0] %>"><%= g[0] %> <%= g[1] %></option>
            <% } %>
          </select>
        </div>
      </div>

      <div class="detail-row">
        <div class="detail-k">カテゴリー</div>
        <div class="detail-v">
          <select id="eCategory" class="detail-input">
            <option value="">-- 選択 --</option>
            <% for(String[] c : categoryOpts){ %>
              <option value="<%= c[0] %>"><%= c[2] %> <%= c[3] %> / <%= c[0] %> <%= c[1] %></option>
            <% } %>
          </select>
        </div>
      </div>

      <!-- ✅ table options (existing) -->
      <%
        Connection conT = null;
        PreparedStatement psT = null;
        ResultSet rsT = null;
        List<String[]> tableOpts = new ArrayList<>();

        try{
          Class.forName("com.mysql.cj.jdbc.Driver");
          conT = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8",
            "root", ""
          );
          psT = conT.prepareStatement(
            "SELECT t.code, t.name, t.group_code, g.name AS group_name " +
            "FROM `tables` t LEFT JOIN groups g ON t.group_code=g.code " +
            "ORDER BY t.group_code, t.code"
          );
          rsT = psT.executeQuery();
          while(rsT.next()){
            String tc = rsT.getString("code");
            String tn = rsT.getString("name");
            String gc = rsT.getString("group_code");
            String gn = rsT.getString("group_name");
            if(gn==null) gn="";
            if(gc==null) gc="";
            tableOpts.add(new String[]{tc, tn, gc, gn});
          }
        }catch(Exception e){
          // ignore
        }finally{
          try{ if(rsT!=null) rsT.close(); }catch(Exception e){}
          try{ if(psT!=null) psT.close(); }catch(Exception e){}
          try{ if(conT!=null) conT.close(); }catch(Exception e){}
        }
      %>

      <div class="detail-row">
        <div class="detail-k">テーブル</div>
        <div class="detail-v">
          <select id="eTable" class="detail-input">
            <option value="">-- 選択 --</option>
            <% for(String[] t : tableOpts){ %>
              <option value="<%= t[0] %>"><%= t[2] %> <%= t[3] %> / <%= t[0] %> <%= t[1] %></option>
            <% } %>
          </select>
        </div>
      </div>

      <div class="detail-row">
        <div class="detail-k">在庫</div>
        <div class="detail-v"><input id="eQty" class="detail-input" type="number" min="0"></div>
      </div>

      <div class="detail-row">
        <div class="detail-k">価格</div>
        <div class="detail-v"><input id="ePrice" class="detail-input" type="number" min="0" step="1"></div>
      </div>

      <div class="detail-row">
        <div class="detail-k">メモ</div>
        <div class="detail-v"><input id="eNote" class="detail-input" type="text"></div>
      </div>

      <div class="detail-hint">※ グループ / カテゴリー / テーブル も編集できます。</div>
    </div>
  </div>

  <% if(canEdit){ %>
  <div class="detail-footer hidden" id="detailFooter">
    <button class="detail-save" type="button" onclick="askSave()">保存</button>
    <button class="detail-cancel" type="button" onclick="cancelEdit()">キャンセル</button>
  </div>
  <% } %>
</aside>

<!-- ===== Confirm dialog ===== -->
<div class="confirm-overlay" id="confirmOverlay" onclick="closeConfirm()"></div>
<div class="confirm-box" id="confirmBox" role="dialog" aria-modal="true">
  <div class="confirm-title" id="cTitle">確認</div>
  <div class="confirm-msg" id="cMsg">-</div>
  <div class="confirm-actions">
    <button class="confirm-yes" id="cYes" type="button">はい</button>
    <button class="confirm-no" type="button" onclick="closeConfirm()">キャンセル</button>
  </div>
</div>

<script>
(function(){
  var chip = document.getElementById("ioutCount");
  if(chip) chip.textContent = "件数：<%= count %>";
})();

function filterItems(){
  var input = document.getElementById("ioutSearch");
  var q = (input ? input.value : "").toLowerCase();
  var rows = document.querySelectorAll("#ioutTable tbody tr");
  var shown = 0;

  for(var i=0;i<rows.length;i++){
    var r = rows[i];
    if(!r.cells || r.cells.length < 9) continue;
    var text = (r.innerText || "").toLowerCase();
    var ok = text.indexOf(q) >= 0;
    r.style.display = ok ? "" : "none";
    if(ok) shown++;
  }
  var chip2 = document.getElementById("ioutCount");
  if(chip2) chip2.textContent = "表示：" + shown + " / <%= count %>";
}

window.__CAN_EDIT_ITEM__ = <%= canEdit ? "true" : "false" %>;

function openImportModal(){
  var o = document.getElementById("impOverlay");
  var b = document.getElementById("impBox");
  if(o) o.classList.add("show");
  if(b) b.classList.add("show");
}
function closeImportModal(){
  var o = document.getElementById("impOverlay");
  var b = document.getElementById("impBox");
  if(o) o.classList.remove("show");
  if(b) b.classList.remove("show");
}
document.addEventListener("keydown", function(e){
  if(e.key === "Escape"){
    closeImportModal();
  }
});
</script>

<script src="js/itemdetail.js?v=20260124_groupcat"></script>
