import type {
  QuartzComponent,
  QuartzComponentConstructor,
  QuartzComponentProps,
} from "@quartz-community/types"

export default (() => {
  const PageBanner: QuartzComponent = ({ fileData }: QuartzComponentProps) => {
    const frontmatter = fileData.frontmatter as
      | { banner?: unknown }
      | undefined

    const banner = frontmatter?.banner

    if (typeof banner !== "string" || banner.trim().length === 0) {
      return null
    }

    return (
      <div class="page-banner">
        <img src={banner} alt="" />
      </div>
    )
  }

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
  `

  return PageBanner
}) satisfies QuartzComponentConstructor
