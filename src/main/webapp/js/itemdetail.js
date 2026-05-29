// /webapp/js/itemdetail.js  (ItemList + Dashboard 共通)

let currentRow = null;

const UPDATE_URL = "edit_item.jsp";
const DELETE_URL = "delete_item.jsp";

function openDetail(tr){
  currentRow = tr;

  const overlay = document.getElementById("detailOverlay");
  const panel   = document.getElementById("detailPanel");
  if(!overlay || !panel) return;

  const code  = tr.dataset.code || "-";
  const name  = tr.dataset.name || "-";
  const g     = tr.dataset.group || "-";
  const c     = tr.dataset.category || "-";

  const tableDisp = tr.dataset.tabledisp || tr.dataset.table || "-";

  const qty   = tr.dataset.qty || "-";
  const price = tr.dataset.price || "-";
  const by    = tr.dataset.by || "-";
  const at    = tr.dataset.at || "-";
  const note  = tr.dataset.note || "-";
  const photo = tr.dataset.photo || "";

  setText("dCode", code);
  setText("dName", name);
  setText("dGroup", g);
  setText("dCategory", c);
  setText("dTable", tableDisp);
  setText("dQty", qty);
  setText("dPrice", (price !== "-" && price !== "") ? ("¥" + price) : "-");
  setText("dBy", by);
  setText("dAt", at);
  setText("dNote", (note === "" ? "-" : note));

  const img = document.getElementById("dImage");
  if(img){
    img.src = (photo && photo.trim().length > 0 && photo !== "null") ? photo : "images/noimage.png";
  }

  showViewMode();

  overlay.classList.add("show");
  panel.classList.add("open");
  panel.setAttribute("aria-hidden","false");
  document.body.style.overflow = "hidden";

  loadHistory(code);
}

function closeDetail(){
  const overlay = document.getElementById("detailOverlay");
  const panel   = document.getElementById("detailPanel");
  if(overlay) overlay.classList.remove("show");
  if(panel){
    panel.classList.remove("open");
    panel.setAttribute("aria-hidden","true");
  }
  closeConfirm();
  document.body.style.overflow = "";
}

function setText(id, v){
  const el = document.getElementById(id);
  if(el) el.textContent = (v == null || v === "") ? "-" : v;
}

function showViewMode(){
  const view   = document.getElementById("viewCard");
  const edit   = document.getElementById("editCard");
  const footer = document.getElementById("detailFooter");
  if(view) view.classList.remove("hidden");
  if(edit) edit.classList.add("hidden");
  if(footer) footer.classList.add("hidden");
}

function showEditMode(){
  const view   = document.getElementById("viewCard");
  const edit   = document.getElementById("editCard");
  const footer = document.getElementById("detailFooter");
  if(view) view.classList.add("hidden");
  if(edit) edit.classList.remove("hidden");
  if(footer) footer.classList.remove("hidden");
}

function askEdit(){
  if(!window.__CAN_EDIT_ITEM__) return;
  if(!currentRow) return;

  const code  = currentRow.dataset.code || "";
  const name  = currentRow.dataset.name || "";
  const qty   = currentRow.dataset.qty || "0";
  const price = currentRow.dataset.price || "0";
  const note  = currentRow.dataset.note || "";

  const tableCode    = currentRow.dataset.tablecode || "";
  const groupCode    = currentRow.dataset.groupcode || "";
  const categoryCode = currentRow.dataset.categorycode || "";

  const eCode  = document.getElementById("eCode");
  const eName  = document.getElementById("eName");
  const eQty   = document.getElementById("eQty");
  const ePrice = document.getElementById("ePrice");
  const eNote  = document.getElementById("eNote");
  const eTable = document.getElementById("eTable");
  const eGroup = document.getElementById("eGroup");
  const eCategory = document.getElementById("eCategory");

  if(eCode)  eCode.textContent = code;
  if(eName)  eName.value = name;
  if(eQty)   eQty.value = qty;
  if(ePrice) ePrice.value = price;
  if(eNote)  eNote.value = note;

  if(eTable) eTable.value = tableCode;
  if(eGroup) eGroup.value = groupCode;
  if(eCategory) eCategory.value = categoryCode;

  showEditMode();
}

function cancelEdit(){
  showViewMode();
}

function askSave(){
  if(!window.__CAN_EDIT_ITEM__) return;

  const code  = (document.getElementById("eCode")  || {}).textContent || "";
  const name  = (document.getElementById("eName")  || {}).value || "";
  const qty   = (document.getElementById("eQty")   || {}).value || "0";
  const price = (document.getElementById("ePrice") || {}).value || "0";
  const note  = (document.getElementById("eNote")  || {}).value || "";

  const tableCode    = (document.getElementById("eTable") || {}).value || "";
  const groupCode    = (document.getElementById("eGroup") || {}).value || "";
  const categoryCode = (document.getElementById("eCategory") || {}).value || "";

  // return url (optional)
  const ret = (currentRow && currentRow.dataset && currentRow.dataset.return) ? currentRow.dataset.return : "";

  if(!code){
    alert("code がありません");
    return;
  }
  if(!name.trim()){
    alert("商品名が必要です");
    return;
  }

  openConfirm("保存確認","この内容で保存しますか？", function(){
    const f = document.createElement("form");
    f.method = "post";
    f.action = UPDATE_URL;

    addHidden(f,"code",code);
    addHidden(f,"name",name);
    addHidden(f,"qty",qty);
    addHidden(f,"price",price);
    addHidden(f,"note",note);

    addHidden(f,"table_code",tableCode);
    addHidden(f,"group_code",groupCode);
    addHidden(f,"category_code",categoryCode);

    if(ret) addHidden(f,"return",ret);

    document.body.appendChild(f);
    f.submit();
  });
}

function askDelete(){
  if(!window.__CAN_EDIT_ITEM__) return;
  if(!currentRow) return;

  const code = currentRow.dataset.code || "";
  if(!code) return;

  openConfirm("削除確認","削除しますか？", function(){
    location.href = DELETE_URL + "?code=" + encodeURIComponent(code);
  });
}

function addHidden(form, name, value){
  const i = document.createElement("input");
  i.type="hidden";
  i.name=name;
  i.value=value;
  form.appendChild(i);
}

/* ===== history area (optional) ===== */
function loadHistory(code){
  const box  = document.getElementById("histBox");
  const body = document.getElementById("histBody");
  if(!box || !body) return;

  body.innerHTML =
    "<div style='padding:10px;border:1px solid rgba(0,0,0,.10);border-radius:12px;background:#fafafa;font-weight:900;'>読み込み中...</div>";

  if(!code || code === "-"){
    body.innerHTML =
      "<div style='padding:10px;border:1px solid rgba(0,0,0,.10);border-radius:12px;background:#fafafa;font-weight:900;'>履歴がありません。</div>";
    return;
  }

  fetch("ItemHistoryServlet?code=" + encodeURIComponent(code))
    .then(r => r.json())
    .then(data => {
      if(!data || !data.ok){
        const msg = (data && data.message) ? escapeHtml(data.message) : "履歴取得エラー";
        body.innerHTML =
          "<div style='padding:10px;border:1px solid rgba(255,0,0,.20);border-radius:12px;background:rgba(255,0,0,.06);font-weight:900;color:#7a0000;'>" +
          msg +
          "</div>";
        return;
      }

      const rows = data.rows || [];
      if(rows.length === 0){
        body.innerHTML =
          "<div style='padding:10px;border:1px solid rgba(0,0,0,.10);border-radius:12px;background:#fafafa;font-weight:900;'>履歴がありません。</div>";
        return;
      }

      let html = "<div style='display:flex;flex-direction:column;gap:8px;'>";
      for(let i=0;i<rows.length && i<10;i++){
        const diff = Number(rows[i].diff || 0);
        const note = rows[i].note || "";
        const at   = rows[i].at || "";

        const badgeStyle =
          (diff < 0)
            ? "background:rgba(255,0,0,.06);border-color:rgba(255,0,0,.20);color:#7a0000;"
            : "background:rgba(0,128,0,.08);border-color:rgba(0,128,0,.20);color:#075a2a;";

        const sign = (diff < 0) ? String(diff) : ("+" + diff);

        html +=
          "<div style='display:flex;justify-content:space-between;gap:10px;padding:10px;border:1px solid rgba(0,0,0,.10);border-radius:12px;background:#fff;'>" +
            "<div style='display:flex;align-items:center;gap:10px;'>" +
              "<span style='font-weight:1000;padding:4px 10px;border-radius:999px;border:1px solid rgba(0,0,0,.12);" + badgeStyle + "'>" +
                escapeHtml(sign) +
              "</span>" +
              "<span style='font-weight:900;color:#01074A;'>" + escapeHtml(note) + "</span>" +
            "</div>" +
            "<div style='font-size:12px;color:rgba(0,0,0,.55);font-weight:800;'>" + escapeHtml(at) + "</div>" +
          "</div>";
      }
      html += "</div>";
      body.innerHTML = html;
    })
    .catch(() => {
      body.innerHTML =
        "<div style='padding:10px;border:1px solid rgba(255,0,0,.20);border-radius:12px;background:rgba(255,0,0,.06);font-weight:900;color:#7a0000;'>履歴取得エラー</div>";
    });
}

function escapeHtml(s){
  if(s==null) return "";
  return String(s)
    .replace(/&/g,"&amp;")
    .replace(/</g,"&lt;")
    .replace(/>/g,"&gt;")
    .replace(/"/g,"&quot;");
}

/* ===== confirm dialog ===== */
function openConfirm(title,msg,onYes){
  const o = document.getElementById("confirmOverlay");
  const b = document.getElementById("confirmBox");
  const t = document.getElementById("cTitle");
  const m = document.getElementById("cMsg");
  const y = document.getElementById("cYes");

  if(t) t.textContent = title || "確認";
  if(m) m.textContent = msg || "";
  if(y){
    y.onclick = function(){
      closeConfirm();
      if(typeof onYes === "function") onYes();
    };
  }

  if(o) o.classList.add("show");
  if(b) b.classList.add("show");
}

function closeConfirm(){
  const o = document.getElementById("confirmOverlay");
  const b = document.getElementById("confirmBox");
  if(o) o.classList.remove("show");
  if(b) b.classList.remove("show");
}

document.addEventListener("keydown", function(e){
  if(e.key === "Escape"){
    closeConfirm();
    const panel = document.getElementById("detailPanel");
    if(panel && panel.classList.contains("open")){
      closeDetail();
    }
  }
});
