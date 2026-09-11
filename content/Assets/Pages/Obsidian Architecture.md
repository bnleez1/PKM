---
title: Obsidian Architecture
tags:
  - Obsidian
subject: []
formalDefinition:
relatedTerms: []
pages:
notes: []
gh-publish: true
gh-path:
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/content/New Page Template
banner: https://wingedsheep.com/content/images/2023/04/wingedsheep_Nature_photograph_by_George_Lucas_and_Melissa_Groo__62f5a5b6-ba64-496f-8ff6-9d30fc57fca8.jpg
---
# Obsidian Architecture - Testing

As of [[Friday, September 11, 2026]], my current workflow—Obsidian → GitHub → Quartz—has the following filesystem:

```text
60 Public/
└── Website/
    ├── Current Courses/
    │   ├── Academic Writing/
    │   ├── Discourse Analysis/
    │   ├── Listening I/
    │   │   ├── Assignments/
    │   │   ├── Lectures/
    │   │   ├── Modules/
    │   │   ├── Resources/
    │   │   ├── Units/
    │   │   └── index.md
    │   └── Writing I/
    ├── 99 Course Archive/
    ├── Assets/
    └── index.md
```

### Using Bases in Obsidian

I'm considering the following:

**Folders = where the material lives.**  
**Properties = what the material is.**  
**Bases = how you view and manage the material.**  
**Quartz = how the public sees it.**

My assignment files are as follows:

```text
Listening I/
└── Assignments/
    ├── Listening CAADI Worksheet 1.md
    ├── Listening CAADI Worksheet 2.md
    ├── Listening CAADI Worksheet 3.md
    ├── Listening I Task Week 2.md
    └── Listening I Task Week 3.md
```

I am considering simplifying properties to the following:

```yaml
---
course: Listening I
type: assignment
week: 3
unit: 1
status: published
publish: true
due: 2026-09-18
semester: 2026-2
---
```

Considering a **Course Materials Base** that automatically gives me views such as:

|Title|Course|Type|Week|Status|Due|
|---|---|---|--:|---|---|
|Listening CAADI Worksheet 3|Listening I|Assignment|3|Published||
|Listening I Task Week 3|Listening I|Assignment|3|Published|Sep 18|
|Study Habits|Listening I|Module|4|Published||

The major advantage is that I no longer need to navigate through folders every time I want to answer questions like:

- What am I teaching this week?
- Which assignments are published?
- What materials belong to Week 5?
- Which courses have unpublished modules?
- What is due next week?
- Which resources are lectures versus assignments versus worksheets?

### One change to make to my current structure

I would slightly reduce how much information is encoded in filenames.

For example, inside:

```text
Listening I/Assignments/
```

you don't necessarily need:

```text
Listening I Task Week 2
Listening I Task Week 3
```

Something like:

```text
Week 02 - Listening Task
Week 03 - Listening Task
```

or a descriptive title:

```text
Week 02 - Campus Life Listening
Week 03 - Study Habits Listening
```

becomes easier to scan.

The course identity is already supplied by the folder and by the `course:` property.

I would also standardize the main categories across your courses where appropriate:

```text
Course/
├── Assignments/
├── Lectures/
├── Modules/
├── Resources/
├── Units/
└── index.md
```

Not every course needs material in every folder, but having the same conceptual architecture across Academic Writing, Discourse Analysis, Listening I, and Writing I will make the entire vault much easier to maintain.

### The architecture

My aim is this:

```text
                     OBSIDIAN
                        │
        ┌───────────────┴───────────────┐
        │                               │
   Folder structure                Properties
  "Where it lives"               "What it is"
        │                               │
        └───────────────┬───────────────┘
                        │
                      BASES
               "How I manage it"
                        │
                 ┌──────┴──────┐
                 │             │
             Obsidian        Quartz
            teacher view   student/public
                              view
                                │
                              GitHub
```

I will eventually have only a handful of important Bases:

1. **Current Courses** — everything grouped by course.
2. **Teaching This Week** — filtered by week/date.
3. **Assignments** — all assignments across courses.
4. **Course Materials** — modules, lectures, resources, etc.
5. **Publishing Dashboard** — draft/published/archive status.

Those Bases could even live outside `60 Public`, because they are primarily **your management interface** and do not need to be published.

<hr class="__chatgpt_plugin">

### role::assistant<span style="font-size: small;"> (openai@gpt-4.1-mini)</span>



<hr class="__chatgpt_plugin">

### role::user

Error (AI_NoOutputGeneratedError): No output generated. Check the stream for errors.