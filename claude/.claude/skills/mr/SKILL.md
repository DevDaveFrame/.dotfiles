---
name: mr
description: Generate a merge request or pull request description in Industry Dive format. Trigger when the user asks to create a merge request, pull request, MR, or PR description. Reads the current git branch and diff to produce a formatted, copiable MR body.
---

## How to generate the MR description

1. Run `git branch --show-current` to get the branch name.
2. Extract the JIRA ticket ID from the branch prefix (e.g. `ENGA-1851` from `ENGA-1851-postgres-case-sensitivity-content-type-bug`).
3. Run `git diff main...HEAD` (or `git diff origin/main...HEAD` if needed) to get the full diff.
4. Check the diff for any migration files (files matching `*/migrations/*.py`). If any are present, include the migration checklist; if not, omit it.
5. If the user supplies non-technical context, use it. Otherwise, infer from the ticket ID, branch name, and diff — or ask before proceeding if the purpose is unclear.
6. Output the result as a **single copiable markdown code block**.

## Output format

The output must be a single fenced markdown code block containing exactly this structure. Replace `<id>` with the numeric ticket ID (e.g. `1851`). Replace instructional italics lines (shown below in `~tildes~`) with real content — do not include the tilde markers in output.

````
```
[ENGA-<id>](https://industrydive.atlassian.net/browse/ENGA-<id>)

### Non-technical Context
~The reason a stakeholder wants the work done. Supply this from user context, infer from the diff/branch, or ask before proceeding.~

### Technical Context
~Numbered, bolded headings per file or feature group. Use function names and variable names as `inline monospace`.~

1. **filename.py:** description of change using precise language and `inline_code`.

### Manual Testing Instructions
~Describe the user actions needed to test the feature if context is sufficient; otherwise leave blank.~

#### Developer

- [x] Ensure code complies with the [style guide](https://industrydive.atlassian.net/wiki/spaces/TECH/pages/639500407/Tech+Team+s+Style+Guides)
- [x] Devise edge cases to test the bug fix or feature being merged
- [x] Make sure the code is clean and understandable
- [x] Ensure code is not overly inefficient
- [ ] Ensure user permissions have been included (for new features) or updated (for revisions), if necessary
~Include the block below only if the diff contains migration files; otherwise remove it entirely:~
- [ ] Code changes include a migration
    - [ ] Migration modifies large table and has been run against full db to estimate completion time
    - [ ] Migration modifies a small table and has only been run against slim db
    - [ ] There are no conflicting migration leaf nodes
- [ ] Ensure documentation is understandable and accurate, including:
    - [ ] Code comments and doc strings
    - [ ] Technical documentation

#### Reviewer

- [ ] Ensure code complies with the [style guide](https://industrydive.atlassian.net/wiki/spaces/TECH/pages/639500407/Tech+Team+s+Style+Guides)
    - If there are few or minor issues, add inline comments
    - If there are many issues or it seems like the developer did not follow the style guide, leave a comment asking them to do so
- [ ] Devise edge cases to test the bug fix or feature being merged
- [ ] Make sure the code is clean and understandable
    - [ ] Ask for inline comments on unclear sections
- [ ] Ensure code is not overly inefficient
- [ ] Ensure user permissions have been included (for new features) or updated (for revisions), if necessary
- [ ] Ensure documentation is understandable and accurate, including:
    - [ ] Code comments and doc strings
    - [ ] Technical documentation
- [ ] There are no conflicting migration leaf nodes
```
````

## Notes

- The JIRA link format uses `https://` (not `mdc:https:/`).
- The Technical Context section is the most important — be specific and precise. Group by file or by feature as appropriate, but every entry must be a numbered bold heading.
- Do not include instructional comments (`~like this~`) in the output.
- If there are no migrations, remove the entire migration sub-checklist from the Developer section.
