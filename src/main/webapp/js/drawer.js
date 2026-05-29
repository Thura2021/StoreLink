function toggleDrawer() {
  const d = document.getElementById("drawer");
  const o = document.getElementById("overlay");
  if (!d || !o) return;

  const willOpen = !d.classList.contains("open");
  d.classList.toggle("open");
  o.classList.toggle("show");

  // close FAB menu when opening drawer
  closeFabMenu();

  document.body.style.overflow = willOpen ? "hidden" : "";
}

function closeDrawer() {
  const d = document.getElementById("drawer");
  const o = document.getElementById("overlay");
  if (!d || !o) return;

  d.classList.remove("open");
  o.classList.remove("show");
  document.body.style.overflow = "";
}

function toggleFabMenu(){
  const m = document.getElementById("fabMenu");
  if(!m) return;

  // close drawer if opening FAB menu (mobile)
  closeDrawer();

  m.classList.toggle("show");
}

function closeFabMenu(){
  const m = document.getElementById("fabMenu");
  if(!m) return;
  m.classList.remove("show");
}

// ESC key closes everything
document.addEventListener("keydown", function(e){
  if (e.key === "Escape") {
    closeDrawer();
    closeFabMenu();
  }
});

// click outside FAB menu to close (except on fab button)
document.addEventListener("click", function(e){
  const menu = document.getElementById("fabMenu");
  if(!menu) return;

  const fab = document.querySelector(".fab");
  if(menu.classList.contains("show")){
    if(!menu.contains(e.target) && fab && !fab.contains(e.target)){
      closeFabMenu();
    }
  }
});
