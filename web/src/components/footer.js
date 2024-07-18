import React from "react";

const footer = () => {
  return (
    <>
      <footer className="footer p-10 bg-base-200 text-base-content">
        <aside>
          <h1 className="text-4xl"
          style={{
            fontFamily: "Fredoka",
            color: "var(--text-secondary-color)",
            fontWeight: 800,
          }}
          >Navi<span className="text-5xl">X</span>plore</h1>
          <p>
            Making commute easy for everyone...
          </p>
        </aside>
        <nav>
          <header className="footer-title">For Xplorers</header>
          <a className="link link-hover">Explore Navi Mumbai</a>
          <a className="link link-hover">Navi Mumbai Travel Hacks</a>
          <a className="link link-hover">Live Announcements</a>
          <a className="link link-hover">Media Coverage</a>
        </nav>
        <nav>
          <header className="footer-title">Quick Links</header>
          <a className="link link-hover">About NaviXplore App</a>
          <a className="link link-hover">Blog</a>
          <a className="link link-hover">Advertise with us</a>
        </nav>
        <nav>
          <header className="footer-title">Legal</header>
          <a className="link link-hover">Terms of use</a>
          <a className="link link-hover">Privacy policy</a>
          <a className="link link-hover">Cookie policy</a>
        </nav>
      </footer>
      <footer className="footer footer-center p-4 bg-base-300 text-base-content">
        <aside>
          <p>Copyright © 2024 - All right reserved by NaviXplore</p>
        </aside>
      </footer>
    </>
  );
};

export default footer;
