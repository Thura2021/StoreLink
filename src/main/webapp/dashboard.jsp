<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<link rel="stylesheet" href="css/dashboard.css?v=20260123_unify1">
<link rel="stylesheet" href="css/itemoutput.css?v=20260123_unify1">

<%
  // ✅ permissions
  String role = (String)session.getAttribute("role");
  Map<String, Boolean> perms = (Map<String, Boolean>)session.getAttribute("perms");
  boolean isAdmin = (role != null && "admin".equalsIgnoreCase(role));
  boolean canEditItem = isAdmin || (perms!=null && Boolean.TRUE.equals(perms.get("EDIT_ITEM")));

  final String URL  = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  final String USER = "root";
  final String PASS = "";

  int groupCount = 0;
  int categoryCount = 0;
  int tableCount = 0;
  int itemCount = 0;

  int LOW_STOCK = 5;
  int lowStockCount = 0;

  String loadError = null;

  Connection con = null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  try{
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(URL, USER, PASS);

    ps = con.prepareStatement("SELECT COUNT(*) FROM groups");
    rs = ps.executeQuery(); if(rs.next()) groupCount = rs.getInt(1);
    rs.close(); ps.close();

    ps = con.prepareStatement("SELECT COUNT(*) FROM categories");
    rs = ps.executeQuery(); if(rs.next()) categoryCount = rs.getInt(1);
    rs.close(); ps.close();

    ps = con.prepareStatement("SELECT COUNT(*) FROM `tables`");
    rs = ps.executeQuery(); if(rs.next()) tableCount = rs.getInt(1);
    rs.close(); ps.close();

    ps = con.prepareStatement("SELECT COUNT(*) FROM items");
    rs = ps.executeQuery(); if(rs.next()) itemCount = rs.getInt(1);
    rs.close(); ps.close();

    ps = con.prepareStatement("SELECT COUNT(*) FROM items WHERE qty <= ?");
    ps.setInt(1, LOW_STOCK);
    rs = ps.executeQuery(); if(rs.next()) lowStockCount = rs.getInt(1);
    rs.close(); ps.close();

  }catch(Exception e){
    loadError = e.getMessage();
  }finally{
    try{ if(rs!=null) rs.close(); }catch(Exception e){}
    try{ if(ps!=null) ps.close(); }catch(Exception e){}
    try{ if(con!=null) con.close(); }catch(Exception e){}
  }

  // ✅ table options for detail edit (same as itemoutput)
  List<String[]> tableOpts = new ArrayList<>();
  Connection conT = null;
  PreparedStatement psT = null;
  ResultSet rsT = null;

  try{
    Class.forName("com.mysql.cj.jdbc.Driver");
    conT = DriverManager.getConnection(URL, USER, PASS);

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

<style>
/* ✅ dashboard panel table: show ALL rows inside panel with scroll */
.dash-table-wrap{
  max-height: 420px;      /* desktop */
  overflow: auto;
}
@media (max-width: 820px){
  .dash-table-wrap{ max-height: 52vh; }  /* phone */
}
</style>

<div class="dash">

  <div class="dash-head">
    <div>
      <div class="dash-title">ダッシュボード</div>
      <div class="dash-sub">全体の状況を一目で確認できます。</div>

      <% if(loadError != null){ %>
        <div class="dash-error">読み込みエラー：<%= loadError %></div>
      <% } %>
    </div>

    <div class="dash-actions">
      <a class="dash-link" href="drawer.jsp?page=item_list">商品管理へ</a>
      <a class="dash-link" href="drawer.jsp?page=group_list">マスタ管理へ</a>
    </div>
  </div>

  <!-- ===== Summary Cards ===== -->
  <div class="dash-grid5">
    <div class="dash-card">
      <div class="dash-card-top">
        <div class="dash-card-title">商品数</div>
        <div class="dash-badge">ITEMS</div>
      </div>
      <div class="dash-num"><%= itemCount %></div>
      <div class="dash-mini">登録済みの商品</div>
    </div>

    <div class="dash-card">
      <div class="dash-card-top">
        <div class="dash-card-title">カテゴリー</div>
        <div class="dash-badge">CATEGORY</div>
      </div>
      <div class="dash-num"><%= categoryCount %></div>
      <div class="dash-mini">分類の数</div>
    </div>

    <div class="dash-card">
      <div class="dash-card-top">
        <div class="dash-card-title">グループ</div>
        <div class="dash-badge">GROUP</div>
      </div>
      <div class="dash-num"><%= groupCount %></div>
      <div class="dash-mini">上位分類</div>
    </div>

    <div class="dash-card">
      <div class="dash-card-top">
        <div class="dash-card-title">テーブル</div>
        <div class="dash-badge">TABLE</div>
      </div>
      <div class="dash-num"><%= tableCount %></div>
      <div class="dash-mini">登録済みのテーブル</div>
    </div>

    <div class="dash-card warn">
      <div class="dash-card-top">
        <div class="dash-card-title">在庫不足</div>
        <div class="dash-badge warn">ALERT</div>
      </div>
      <div class="dash-num"><%= lowStockCount %></div>
      <div class="dash-mini">在庫 ≤ <%= LOW_STOCK %></div>
    </div>
  </div>

  <!-- ===== Panels ===== -->
  <div class="dash-grid2">

    <!-- Recent Items (ALL rows, sorted by created_at DESC, scroll in panel) -->
    <section class="dash-panel">
      <div class="dash-panel-head">
        <div class="dash-panel-title">最近登録された商品</div>
        <a class="dash-more" href="drawer.jsp?page=item_list">一覧</a>
      </div>

      <div class="dash-table-wrap">
        <table class="dash-table" id="recentTable">
          <thead>
            <tr>
              <th style="width:140px;">コード</th>
              <th>商品名</th>
              <th style="width:180px;">登録者</th>
              <th style="width:220px;">登録日</th>
            </tr>
          </thead>
          <tbody>
            <%
              Connection con2 = null;
              PreparedStatement ps2 = null;
              ResultSet rs2 = null;

              try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                con2 = DriverManager.getConnection(URL, USER, PASS);

                String sqlRecent =
                  "SELECT " +
                  " i.code, i.name, i.group_code, i.category_code, i.table_code, i.qty, i.price, i.note, i.created_by, i.created_at, i.photo, " +
                  " g.name AS group_name, c.name AS category_name, t.name AS table_name " +
                  "FROM items i " +
                  "LEFT JOIN groups g ON i.group_code = g.code " +
                  "LEFT JOIN categories c ON i.category_code = c.code " +
                  "LEFT JOIN `tables` t ON i.table_code = t.code " +
                  "ORDER BY i.created_at DESC";

                ps2 = con2.prepareStatement(sqlRecent);
                rs2 = ps2.executeQuery();

                boolean has = false;

                while(rs2.next()){
                  has = true;

                  String code = rs2.getString("code");
                  String name = rs2.getString("name");

                  String groupCode = rs2.getString("group_code");
                  String categoryCode = rs2.getString("category_code");
                  String tableCode = rs2.getString("table_code");

                  String groupName = rs2.getString("group_name");
                  String categoryName = rs2.getString("category_name");
                  String tableName = rs2.getString("table_name");

                  int qty = rs2.getInt("qty");
                  double price = rs2.getDouble("price");

                  String note = rs2.getString("note");
                  String by = rs2.getString("created_by");
                  Timestamp at = rs2.getTimestamp("created_at");
                  String photo = rs2.getString("photo");

                  String gDisp = (groupName == null ? "" : groupName) + (groupCode == null ? "" : " (" + groupCode + ")");
                  String cDisp = (categoryName == null ? "" : categoryName) + (categoryCode == null ? "" : " (" + categoryCode + ")");
                  String tDisp = (tableName == null ? "" : tableName) + (tableCode == null ? "" : " (" + tableCode + ")");

                  String noteSafe = (note == null ? "" : note.replace("\"","&quot;"));
                  String nameSafe = (name == null ? "" : name.replace("\"","&quot;"));
                  String bySafe = (by == null ? "" : by.replace("\"","&quot;"));
                  String photoSafe = (photo == null ? "" : photo.replace("\"","&quot;"));
            %>
              <tr class="dash-clickable"
                  onclick="openDetail(this)"
                  data-code="<%= code %>"
                  data-name="<%= nameSafe %>"
                  data-group="<%= gDisp.replace("\"","&quot;") %>"
                  data-category="<%= cDisp.replace("\"","&quot;") %>"
                  data-tablecode="<%= tableCode == null ? "" : tableCode %>"
                  data-tabledisp="<%= tDisp.replace("\"","&quot;") %>"
                  data-qty="<%= qty %>"
                  data-price="<%= (int)price %>"
                  data-by="<%= bySafe %>"
                  data-at="<%= at == null ? "" : at.toString() %>"
                  data-note="<%= noteSafe %>"
                  data-photo="<%= photoSafe %>">
                <td class="dash-strong"><%= code %></td>
                <td><%= name %></td>
                <td><%= by == null ? "" : by %></td>
                <td><%= at == null ? "" : at.toString() %></td>
              </tr>
            <%
                }

                if(!has){
            %>
              <tr><td colspan="4" class="dash-empty">まだデータがありません。</td></tr>
            <%
                }

              }catch(Exception e){
            %>
              <tr><td colspan="4" class="dash-empty">読み込みエラー：<%= e.getMessage() %></td></tr>
            <%
              }finally{
                try{ if(rs2!=null) rs2.close(); }catch(Exception e){}
                try{ if(ps2!=null) ps2.close(); }catch(Exception e){}
                try{ if(con2!=null) con2.close(); }catch(Exception e){}
              }
            %>
          </tbody>
        </table>
      </div>
    </section>

    <!-- Low Stock Items (ALL rows under LOW_STOCK, scroll in panel) -->
    <section class="dash-panel">
      <div class="dash-panel-head">
        <div class="dash-panel-title">在庫が少ない商品</div>
        <div class="dash-note">在庫 ≤ <%= LOW_STOCK %></div>
      </div>

      <div class="dash-table-wrap">
        <table class="dash-table" id="lowTable">
          <thead>
            <tr>
              <th style="width:140px;">コード</th>
              <th>商品名</th>
              <th style="width:120px;">在庫</th>
            </tr>
          </thead>
          <tbody>
            <%
              Connection con3 = null;
              PreparedStatement ps3 = null;
              ResultSet rs3 = null;

              try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                con3 = DriverManager.getConnection(URL, USER, PASS);

                String sqlLow =
                  "SELECT " +
                  " i.code, i.name, i.group_code, i.category_code, i.table_code, i.qty, i.price, i.note, i.created_by, i.created_at, i.photo, " +
                  " g.name AS group_name, c.name AS category_name, t.name AS table_name " +
                  "FROM items i " +
                  "LEFT JOIN groups g ON i.group_code = g.code " +
                  "LEFT JOIN categories c ON i.category_code = c.code " +
                  "LEFT JOIN `tables` t ON i.table_code = t.code " +
                  "WHERE i.qty <= ? " +
                  "ORDER BY i.qty ASC, i.created_at DESC";

                ps3 = con3.prepareStatement(sqlLow);
                ps3.setInt(1, LOW_STOCK);
                rs3 = ps3.executeQuery();

                boolean has2 = false;

                while(rs3.next()){
                  has2 = true;

                  String code = rs3.getString("code");
                  String name = rs3.getString("name");

                  String groupCode = rs3.getString("group_code");
                  String categoryCode = rs3.getString("category_code");
                  String tableCode = rs3.getString("table_code");

                  String groupName = rs3.getString("group_name");
                  String categoryName = rs3.getString("category_name");
                  String tableName = rs3.getString("table_name");

                  int qty = rs3.getInt("qty");
                  double price = rs3.getDouble("price");

                  String note = rs3.getString("note");
                  String by = rs3.getString("created_by");
                  Timestamp at = rs3.getTimestamp("created_at");
                  String photo = rs3.getString("photo");

                  String gDisp = (groupName == null ? "" : groupName) + (groupCode == null ? "" : " (" + groupCode + ")");
                  String cDisp = (categoryName == null ? "" : categoryName) + (categoryCode == null ? "" : " (" + categoryCode + ")");
                  String tDisp = (tableName == null ? "" : tableName) + (tableCode == null ? "" : " (" + tableCode + ")");

                  String noteSafe = (note == null ? "" : note.replace("\"","&quot;"));
                  String nameSafe = (name == null ? "" : name.replace("\"","&quot;"));
                  String bySafe = (by == null ? "" : by.replace("\"","&quot;"));
                  String photoSafe = (photo == null ? "" : photo.replace("\"","&quot;"));
            %>
              <tr class="dash-clickable"
                  onclick="openDetail(this)"
                  data-code="<%= code %>"
                  data-name="<%= nameSafe %>"
                  data-group="<%= gDisp.replace("\"","&quot;") %>"
                  data-category="<%= cDisp.replace("\"","&quot;") %>"
                  data-tablecode="<%= tableCode == null ? "" : tableCode %>"
                  data-tabledisp="<%= tDisp.replace("\"","&quot;") %>"
                  data-qty="<%= qty %>"
                  data-price="<%= (int)price %>"
                  data-by="<%= bySafe %>"
                  data-at="<%= at == null ? "" : at.toString() %>"
                  data-note="<%= noteSafe %>"
                  data-photo="<%= photoSafe %>">
                <td class="dash-strong"><%= code %></td>
                <td><%= name %></td>
                <td><span class="dash-stock"><%= qty %></span></td>
              </tr>
            <%
                }

                if(!has2){
            %>
              <tr><td colspan="3" class="dash-empty">在庫不足の商品はありません。</td></tr>
            <%
                }

              }catch(Exception e){
            %>
              <tr><td colspan="3" class="dash-empty">読み込みエラー：<%= e.getMessage() %></td></tr>
            <%
              }finally{
                try{ if(rs3!=null) rs3.close(); }catch(Exception e){}
                try{ if(ps3!=null) ps3.close(); }catch(Exception e){}
                try{ if(con3!=null) con3.close(); }catch(Exception e){}
              }
            %>
          </tbody>
        </table>
      </div>
    </section>

  </div>

  <div class="dash-foot">
    ※ 行をクリックすると詳細が表示されます。
  </div>

</div>

<!-- ✅ Detail overlay + panel (SAME IDs as itemoutput) -->
<div class="detail-overlay" id="detailOverlay" onclick="closeDetail()"></div>

<aside class="detail-panel" id="detailPanel" aria-hidden="true">
  <div class="detail-head">
    <div class="detail-title">商品詳細</div>

    <div class="detail-actions">
      <% if(canEditItem){ %>
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

      <!-- ✅ history (same IDs as itemoutput) -->
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

      <!-- ✅ table change (same as itemoutput) -->
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

      <div class="detail-hint">※ グループ / カテゴリーは今は編集しない（必要なら後で対応）</div>
    </div>
  </div>

  <% if(canEditItem){ %>
  <div class="detail-footer hidden" id="detailFooter">
    <button class="detail-save" type="button" onclick="askSave()">保存</button>
    <button class="detail-cancel" type="button" onclick="cancelEdit()">キャンセル</button>
  </div>
  <% } %>
</aside>

<!-- ✅ Confirm dialog (same IDs as itemoutput) -->
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
  // ✅ permission flag (itemdetail.js uses this)
  window.__CAN_EDIT_ITEM__ = <%= canEditItem ? "true" : "false" %>;
</script>

<!-- ✅ ONLY ONE detail JS (shared) -->
<script src="js/itemdetail.js?v=20260123_unify1"></script>
