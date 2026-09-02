---
type: 'Page'
collections: 'Public Pages'
title: Three-Tier RTI System
aliases: null
description: null
icon: 💯
createdAt: '2026-06-12T13:35:17.319Z'
lastUpdated: '2026-06-28T12:57:51.173Z'
tags: [Assessment]
coverImage: '[Untitled](../Images/Untitled%20(343).md)'
---

# Three-Tier RTI System

To make a three-tier Response to Instruction (RTI) system work seamlessly in Capacities, the best approach is to split the framework into two parts: **Properties** (for high-level filtering) and the **Template Body** (for detailed pedagogical tracking).

This allows you to quickly query which teacher trainees need immediate support while maintaining a chronological record of the interventions you've applied.

---

## 1. Object Properties (The Metadata)

If you are applying this to a "Student" or "Trainee" Object Type, add these custom properties before building the template canvas. This turns your Capacities database into an active monitoring tool.

| Property Name          | Capacities Type      | Purpose                                                                   |
| :--------------------- | :------------------- | :------------------------------------------------------------------------ |
| **Current Tier**       | Single Select        | Options: `Tier 1 (Core)`, `Tier 2 (Targeted)`, `Tier 3 (Intensive)`.      |
| **Intervention Focus** | Multi-Select         | E.g., `Academic Writing`, `Research Methodology`, `Language Proficiency`. |
| **Next Review**        | Date                 | When you will assess if the current intervention is working.              |
| **Cohort/Seminar**     | Web Link or Relation | To link the student to a specific class (e.g., 2026 Thesis Seminar).      |

## 2. The Template Canvas

In your Object Type settings, create a new template (e.g., "RTI Student Profile"). In the body of the template, set up these specific heading blocks to guide your documentation.

### 🟢 Tier 1: Core Instruction

*Document how the student responds to the baseline curriculum. Since Tier 1 aims to reach 80% of learners, use this space to track engagement with your foundational framework.*

- **UDL Alignment:** Are multiple means of representation and expression working for this trainee?

- **General Observations:** Notes from regular seminars and whole-group discussions.

### 🟡 Tier 2: Targeted Intervention

*Use this section when a student falls behind in a specific domain and requires small-group or specialized focus.*

- **Identified Gap:** (e.g., Struggling to synthesize qualitative research methods or draft a cohesive thesis statement).

- **Intervention Plan:** What specific small-group workshops or supplementary materials are being provided?

- **Progress Monitoring:** Dates and brief notes on whether the targeted instruction is closing the gap.

### 🔴 Tier 3: Intensive Support

*Reserved for significant hurdles requiring one-on-one coaching and high-frequency intervention.*

- **Individual Action Plan:** Specific, measurable goals for one-on-one sessions.

- **Meeting Logs:** A chronological bulleted list tracking direct consultations, feedback cycles, and exact next steps for the trainee.

---

> **Workflow Tip:** Once you tag trainees with their `Current Tier` property, you can create a dynamic **Query** in Capacities that automatically surfaces a dashboard of all your Tier 2 and Tier 3 students, ensuring nobody slips through the cracks during a busy semester.

