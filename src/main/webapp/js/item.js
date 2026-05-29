/**
 * 
 */

/*ကုတ်တူ၇င် အယ်ယာ*/
function showDetail(code){
  fetch("ItemDetailServlet?code=" + code)
    .then(r => r.text())
    .then(t => document.getElementById("detailBox").innerHTML = t);
}

/*Add ခလုပ်*/
function openAdd(){
  window.location.href = "itemAdd.jsp";
}