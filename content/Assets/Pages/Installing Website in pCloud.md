---
type: 'Page'
title: Installing Website in pCloud
aliases: null
description: null
icon: null
createdAt: '2026-07-08T13:10:42.044Z'
lastUpdated: '2026-07-08T13:11:06.589Z'
tags: []
coverImage: null
---

# Installing Website in pCloud

- Notes

    ## Recommended setup

    Use pCloud’s **Public Folder as a simple static website host**, but put the actual website inside a subfolder such as `Public Folder/website`. pCloud supports static HTML websites, direct file/folder links, and embedded images/videos from the Public Folder. It does **not** run server-side code like WordPress, PHP, databases, logins, or forms. (help.pcloud.com)

    ## Recommended folder structure

    ```text
    Public Folder
    ├── website
    │   ├── index.html
    │   ├── about.html
    │   ├── resources.html
    │   ├── contact.html
    │   ├── teacher-training
    │   │   ├── index.html
    │   │   ├── cefr.html
    │   │   ├── clil-siop.html
    │   │   └── assessment-rubrics.html
    │   ├── student-resources
    │   │   ├── index.html
    │   │   ├── writing-i.html
    │   │   ├── listening-i.html
    │   │   ├── academic-writing.html
    │   │   └── discourse-analysis.html
    │   ├── open-downloads
    │   │   ├── index.html
    │   │   ├── worksheets
    │   │   ├── sample-lessons
    │   │   └── presentation-pdfs
    │   ├── media
    │   │   ├── audio
    │   │   ├── images
    │   │   └── short-videos
    │   ├── assets
    │   │   ├── css
    │   │   │   └── style.css
    │   │   ├── images
    │   │   └── documents
    │   └── archive
    │       └── index.html
    ```

    ## Why use a `website` subfolder?

    This keeps your **website** separate from other public files you may later place in Public Folder.

    Better:

    ```text
    Public Folder / website / index.html
    ```

    Less ideal:

    ```text
    Public Folder / index.html
    ```

    Using a subfolder gives you a cleaner publishing area and reduces the chance that random public files become part of your website.

    ## Homepage

    Your main homepage should be:

    ```text
    Public Folder/website/index.html
    ```

    Then create links from that page to your main sections:

    - Teacher Training

    - Student Resources

    - Open Downloads

    - Media

    - About

    - Contact

    In pCloud, a direct link to a folder can show a default directory listing unless the folder contains an appropriate HTML index page. For that reason, place an `index.html` file in every major folder you want visitors to enter. (help.pcloud.com)

    ## Basic `index.html` example

    ```html
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Benjamin Stewart | English Teacher Training Resources</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link rel="stylesheet" href="assets/css/style.css">
    </head>
    <body>
      <header>
        <h1>English Teacher Training Resources</h1>
        <p>Open materials for English language teachers, students, and teacher trainers.</p>
      </header>
      <main>
        <h2>Resource Areas</h2>
        <ul>
          <li><a href="teacher-training/index.html">Teacher Training</a></li>
          <li><a href="student-resources/index.html">Student Resources</a></li>
          <li><a href="open-downloads/index.html">Open Downloads</a></li>
          <li><a href="media/index.html">Media</a></li>
        </ul>
      </main>
      <footer>
        <p>© Benjamin Stewart</p>
      </footer>
    </body>
    </html>
    ```

    ## Basic `style.css` example

    Save this as:

    ```text
    Public Folder/website/assets/css/style.css
    ```

    ```css
    body {
      font-family: Arial, sans-serif;
      max-width: 900px;
      margin: 40px auto;
      padding: 0 20px;
      line-height: 1.6;
    }
    header {
      border-bottom: 1px solid #ddd;
      margin-bottom: 30px;
    }
    a {
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    ```

    ## How to publish it

    1. Open **my.pCloud**.

    2. Go to **My pCloud → Public Folder**.

    3. Create a folder named `website`.

    4. Upload your `index.html`, pages, folders, images, PDFs, and CSS files.

    5. Select the `website` folder.

    6. Click the **link / share / get link** option.

    7. Copy the direct link.

    8. Open that link in a browser to test the site.

    pCloud’s documentation says that to host a static HTML site, you place the HTML files and linked graphics in the Public Folder or a subfolder, then copy the link from the main directory where the site resources are located. (help.pcloud.com)

    ## Important security setting

    Add an `index.html` file to subfolders you do not want displayed as open directory listings. pCloud notes that an empty `index.html` can prevent access to parent-folder listings. (help.pcloud.com)

    For example:

    ```text
    Public Folder/website/archive/index.html
    Public Folder/website/assets/documents/index.html
    Public Folder/website/media/audio/index.html
    ```

    ## What to avoid

    Do not put these in the website folder:

    - Student grades

    - Attendance records

    - Student submissions

    - Private research data

    - Copyrighted scans or books

    - Drafts you may later retract

    - Your full pCloud Backup folder

    - Your full Seagate synced folder

    Also, Public Folder direct links cannot be password-protected. For temporary or restricted class materials, use pCloud **Shared Links** instead, because shared links can support password protection and expiration dates on Premium accounts. (help.pcloud.com)

    ## Best practical model for you

    Use pCloud Public Folder for the **file-hosted resource site**, but use another platform as the polished front door if needed.

    Best setup:

    - **pCloud Public Folder**: files, PDFs, audio, images, static HTML resource pages

    - **Moodle**: class-specific course delivery

    - **Substack or personal site**: public-facing writing/newsletter

    - **GitHub Pages**: better option for a more formal website with version control

    - **pCloud File Requests**: student uploads, not public folders

    For a simple public teaching-resource library, pCloud is enough. For a long-term professional website, I would use pCloud as the **download/media host** and GitHub Pages, Substack, or a proper website builder as the main public website.

    [1]: https://help.pcloud.com/article/public-folder?utm_source=chatgpt.com "Public Folder Functionality"

