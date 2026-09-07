function setupCollapsibleHeadings() {
  const headings = [
    ...document.querySelectorAll<HTMLElement>(
      ".collapsible-headings article h2, article.collapsible-headings h2",
    ),
  ]

  for (const heading of headings) {
    // Prevent duplicate listeners after Quartz SPA navigation
    if (heading.dataset.collapsibleReady === "true") {
      continue
    }

    heading.dataset.collapsibleReady = "true"
    heading.setAttribute("role", "button")
    heading.setAttribute("tabindex", "0")
    heading.setAttribute("aria-expanded", "true")

    const toggleSection = () => {
      const currentlyExpanded = heading.getAttribute("aria-expanded") === "true"
      const collapse = currentlyExpanded

      heading.setAttribute("aria-expanded", String(!collapse))
      heading.classList.toggle("collapsed", collapse)

      let element = heading.nextElementSibling

      while (element && element.tagName !== "H2") {
        element.classList.toggle("collapsible-heading-hidden", collapse)
        element = element.nextElementSibling
      }
    }

    const clickHandler = () => {
      toggleSection()
    }

    const keyboardHandler = (event: KeyboardEvent) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault()
        toggleSection()
      }
    }

    heading.addEventListener("click", clickHandler)
    heading.addEventListener("keydown", keyboardHandler)

    window.addCleanup(() => {
      heading.removeEventListener("click", clickHandler)
      heading.removeEventListener("keydown", keyboardHandler)
    })
  }
}

document.addEventListener("nav", setupCollapsibleHeadings)
document.addEventListener("render", setupCollapsibleHeadings)

// Also initialize immediately on the first page load
setupCollapsibleHeadings()
