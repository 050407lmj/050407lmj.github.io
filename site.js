const header = document.querySelector(".site-header");
let lastY = 0;

window.addEventListener(
  "scroll",
  () => {
    const currentY = window.scrollY;
    if (!header) return;
    header.style.transform = currentY > lastY && currentY > 120 ? "translateY(-100%)" : "translateY(0)";
    lastY = currentY;
  },
  { passive: true }
);
