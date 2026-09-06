---
title:
tags:
subject: []
formalDefinition:
relatedTerms: []
pages:
notes: []
---

A plugin literally called **Toggle** now exists and gives Notion-style `|> ... <|` toggles inside Obsidian. ([Obsidian Community](https://community.obsidian.md/plugins/toggle-premium?utm_source=chatgpt.com "Toggle - Obsidian Plugin")) The problem is that Quartz does not natively understand that custom syntax, so I would **not** choose it for content you expect to work on your public website.

For your setup, the safest options are:

1. **Quartz collapsible callouts — best compatibility.** Quartz v5 explicitly supports Obsidian callouts, including collapsible and nested variants. ([GitHub](https://github.com/quartz-themes/its-theme/blob/v5/docs/features/Obsidian%20compatibility.md?utm_source=chatgpt.com "its-theme/docs/features/Obsidian compatibility.md at v5 · quartz-themes/its-theme · GitHub")) Example:
    

```markdown
> [!note]- Click to expand
> This content starts collapsed.
>
> You can put several paragraphs here.
```

Use `-` for collapsed by default and `+` for expanded by default.

2. **Details Markdown plugin — closest to a real Notion-style toggle.** The **Details Markdown** Obsidian plugin lets you author native HTML `<details>` / `<summary>` blocks while rendering Markdown inside them in Obsidian Reading View. ([Obsidian Community](https://community.obsidian.md/plugins/details-markdown?utm_source=chatgpt.com "Details Markdown - Obsidian Plugin")) For example:
    

```html
<details>
<summary>Click to expand</summary>

### Additional information

This can contain paragraphs, lists, links, and other Markdown.

</details>
```

This approach is attractive because `<details>` and `<summary>` are native web elements rather than proprietary plugin syntax. Quartz's Obsidian-flavored Markdown transformer also has an option for processing content inside HTML embeds (`enableInHtmlEmbed`). ([GitHub](https://github.com/jackyzha0/quartz/blob/v5/docs/plugins/ObsidianFlavoredMarkdown.md?utm_source=chatgpt.com "quartz/docs/plugins/ObsidianFlavoredMarkdown.md at v5 · jackyzha0/quartz · GitHub"))

### What I would choose for you

Because you've already found collapsible callouts cumbersome for **nested toggles and large blocks of pasted material**, I would try **Details Markdown** next.

It gives you a much more Notion-like structure:

```html
<details>
<summary>Week 4 Activities</summary>

Content here...

<details>
<summary>Activity 1</summary>

Details for Activity 1...

</details>

<details>
<summary>Activity 2</summary>

Details for Activity 2...

</details>

</details>
```

That is much easier to reason about for **toggle-inside-toggle** layouts than deeply nested callout blockquotes.

One caveat: Details Markdown currently targets **Reading View**; its documentation says Live Preview support is not yet available. ([GitHub](https://github.com/nickolay-kondratyev/obsidian-plugin-collapsible-details?utm_source=chatgpt.com "GitHub - nickolay-kondratyev/obsidian-plugin-collapsible-details: Plugin to make https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/details work in obsidian · GitHub"))

So my recommendation is: **install Details Markdown, test one small toggle page, publish it to Quartz, and verify the website rendering before converting your modules.** If Quartz needs one configuration adjustment for Markdown inside `<details>`, we can make that once and then you'll have a reusable Notion-like toggle system across your site.

## Adding headings

**Details Markdown does not parse Markdown inside the `<summary>` itself**. So this will not give you a heading:

```html
<summary>## Week 4 Activities</summary>
```

The plugin documentation explicitly says Markdown rendering inside the summary is out of scope. ([GitHub](https://github.com/nickolay-kondratyev/obsidian-plugin-collapsible-details?utm_source=chatgpt.com "GitHub - nickolay-kondratyev/obsidian-plugin-collapsible-details: Plugin to make https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/details work in obsidian · GitHub"))

You can, however, use an actual HTML heading inside the summary:

```html
<details>
<summary><h2>Week 4 — From Draft to Final Paragraph</h2></summary>

Your content goes here.

</details>
```

Or a smaller heading:

```html
<details>
<summary><h3>Activity 1 — Review</h3></summary>

Review the concepts from this week's module.

</details>
```

For your course modules, I would probably use **`<h2>` for the main outer toggle** and ordinary summary text for nested toggles:

```html
<details>
<summary><h2>Week 4 — From Draft to Final Paragraph</h2></summary>

<details>
<summary>Activity 1 — Review</summary>

Activity content...

</details>

<details>
<summary>Activity 2 — Practice</summary>

Activity content...

</details>

</details>
```

That is valid HTML, and the plugin preserves the native `<summary>` element while rendering the body as Markdown. ([GitHub](https://github.com/nickolay-kondratyev/obsidian-plugin-collapsible-details?utm_source=chatgpt.com "GitHub - nickolay-kondratyev/obsidian-plugin-collapsible-details: Plugin to make https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/details work in obsidian · GitHub"))

One caveat: depending on Obsidian/Quartz CSS, putting an actual `<h2>` inside `<summary>` can make the disclosure triangle alignment or spacing look a little unusual. If that happens, the cleaner long-term option is to leave the summary as:

```html
<summary>Week 4 — From Draft to Final Paragraph</summary>
```

and style the **first-level summary to look like an H2** with CSS. That usually produces a more polished Notion-like result on both Obsidian and your Quartz website.

If you want, I can show you the CSS for making the **outer summary look like an H2 while nested summaries stay smaller**.
