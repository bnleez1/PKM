---
type: Page
title: Lesson Plan Tutorial Query
aliases:
description:
icon: ✴️
createdAt: 2026-07-23T15:57:18.719Z
lastUpdated: 2026-07-23T15:59:03.817Z
tags:
  - Capacities
coverImage: "[Untitled](../Images/Untitled%20(106).md)"
---

# Lesson Plan Tutorial Query

- Overall Query Instrutions

    At present, Capacities’ **bulk actions do not include changing an arbitrary property such as your Status label**. You can bulk-change object types, collections, and tags, but not a label property like `Status`. (Capacities Documentation)

    ### Best workaround inside Capacities

    Use a **tag as the bulk-editable workflow marker**:

    1. Open the **Modules** object type.

    2. Click the **…** menu and choose **Select multiple objects**.

        - On Linux, you can also use **Ctrl + Shift + click** to select objects.

    3. Select the lessons.

    4. Click the **tag** action.

    5. Add a tag such as `Planning`, `Ready`, `Taught`, or `Archived`.

    Tags can be added to or removed from multiple objects simultaneously. (Capacities Documentation)

    You could then filter the query by:

    > **Tagged with → Ready**

    or exclude archived lessons using:

    > **Exclude tag → Archived**

    ### My recommendation

    Keep your existing **Status** property for precise, single-object workflow management, but use an **Archived tag** for bulk archiving. This avoids redesigning your whole system and gives you an easy bulk action.

    For assigning many modules to `InBox`, `Planning`, or `Ready`, the alternative is to update each Status cell directly in the table. There currently does not appear to be a native “set Status for all selected objects” command. Labels are best for structured filtering within one object type, while tags provide broader and more bulk-friendly categorization. (Capacities Documentation)

    [1]: https://docs.capacities.io/reference/bulk-actions?utm_source=chatgpt.com "Bulk Actions - Capacities Documentation"

    [2]: https://docs.capacities.io/reference/organizational-structures?utm_source=chatgpt.com "Organizational structures - Capacities Documentation"

- Embedded Queries

    ## Embed both views in your Lesson Module Dashboard

    The easiest method is to create each query **directly inside the dashboard page**. Typing `/query` inside any object creates a query whose results are already embedded there. (Capacities Documentation)

    ### 1. Create “Lessons to Prepare”

    1. Open **Lesson Module Dashboard**.

    2. Click below the existing content to create a new block.

    3. Type:

        ```text
        ## 🛠️ Lessons to Prepare
        ```

    4. Press **Enter**, type `/query`, and select **Query**.

    5. Choose **Object Type Query**.

    6. Under **Return all**, select **Modules**.

    ### 2. Restrict it to the current semester

    Use whichever method matches your setup:

    - Click **Filter collections** and select your Aug–Dec 2026 module collections, such as:

        - Listening I Modules

        - Writing I Modules

        - Academic Writing Modules

        - Discourse Analysis Modules

        - Thesis Seminar Modules

    Or, when you add a Semester property:

    - Click **Filter by properties**

    - Select **Semester**

    - Choose **Aug–Dec 2026**

    Queries are intended for rule-based lists that update automatically as object properties change. (Capacities Documentation)

    ### 3. Add the preparation-status filter

    1. Click **+ Filter by properties**.

    2. Select **Status**.

    3. Choose the appropriate operator, such as **is**, **is any of**, or **contains any of**.

    4. Select:

        ```text
        InBox
        Planning
        ```

    This makes the query represent lessons that still require preparation.

    If Capacities permits only one status value in that filter, I recommend creating one status called **To Prepare** rather than adding two separate Status filters. Two separate filters may be treated as simultaneous conditions and return no results.

    ### 4. Sort and limit the results

    Add:

    - **Sort → Date → Oldest first**

    - Optionally, **Limit results → 10**

    This places the nearest lessons at the top. Close the editor when the results look correct.

    ---

    ## Create “Ready to Teach”

    Below the first embedded query:

    1. Add the heading:

        ```text
        ## ✅ Ready to Teach
        ```

    2. On the next line, type `/query`.

    3. Choose **Object Type Query**.

    4. Select **Modules**.

    5. Apply the same current-semester collection or Semester filter.

    6. Click **Filter by properties → Status**.

    7. Select:

        ```text
        Ready
        ```

    8. Add:

        - **Sort → Date → Oldest first**

        - Optionally, **Limit results → 8**

    9. Close the query editor.

    Your dashboard will now update automatically: changing a module from **Planning** to **Ready** will remove it from the first embedded query and place it in the second. Queries remain live and display newly matching objects automatically. (Capacities Documentation)

    ## Recommended dashboard layout

    ```text
    # Lesson Module Dashboard
    ## 🛠️ Lessons to Prepare
    [Embedded query: Status = InBox or Planning]
    ## ✅ Ready to Teach
    [Embedded query: Status = Ready]
    ## 📝 Recently Taught
    [Optional embedded query: Status = Taught]
    ```

    ### Embedding queries you created separately

    For an existing standalone query:

    1. Open the dashboard.

    2. Type `@` followed by the query name, such as `@Lessons to Prepare`.

    3. Select the query.

    4. Open the link block’s **…** menu.

    5. Choose **Change view → Embed**.

    Capacities specifically supports linking to a saved query by name and changing its link view to **Embed**. (Capacities Documentation)

    [1]: https://docs.capacities.io/reference/queries?utm_source=chatgpt.com "Queries - Capacities Documentation"
