// src/components/PageBanner.tsx
import { jsx } from "preact/jsx-runtime";
var PageBanner_default = (() => {
  const PageBanner = ({ fileData }) => {
    const frontmatter = fileData.frontmatter;
    const banner = frontmatter?.banner;
    if (typeof banner !== "string" || banner.trim().length === 0) {
      return null;
    }
    return /* @__PURE__ */ jsx("div", { class: "page-banner", children: /* @__PURE__ */ jsx("img", { src: banner, alt: "" }) });
  };
  PageBanner.css = `
    .page-banner {
      width: 100%;
      margin: 0 0 2rem 0;
      overflow: hidden;
      border-radius: 8px;
    }

    .page-banner img {
      display: block;
      width: 100%;
      height: 280px;
      object-fit: cover;
    }

    @media (max-width: 800px) {
      .page-banner img {
        height: 180px;
      }
    }
  `;
  return PageBanner;
});
export {
  PageBanner_default as PageBanner
};
