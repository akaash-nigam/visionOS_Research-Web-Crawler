# GitHub Projects - Complete Setup Guide

This guide provides comprehensive instructions for setting up and using GitHub Projects for Research-Web-Crawler development.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Automated Setup](#automated-setup)
3. [Manual Project Board Setup](#manual-project-board-setup)
4. [Custom Fields Configuration](#custom-fields-configuration)
5. [View Configurations](#view-configurations)
6. [Automation Workflows](#automation-workflows)
7. [Daily Usage](#daily-usage)
8. [Best Practices](#best-practices)

---

## Quick Start

### One-Command Setup

Run this script to set up labels, milestones, and get instructions:

```bash
./.github/scripts/setup-project.sh
```

This will:
- ✅ Create all labels (priority, type, status, etc.)
- ✅ Create milestones (v1.0, v1.1, v1.2, v2.0)
- ✅ Provide step-by-step instructions for project board

---

## Automated Setup

### Step 1: Labels

Run the labels setup script:

```bash
./.github/scripts/setup-labels.sh
```

**Labels created:**

**Priority** (for importance)
- 🔴 `priority: critical` - Critical bugs, security issues
- 🟠 `priority: high` - Important features, significant bugs
- 🟡 `priority: medium` - Normal priority work
- 🟢 `priority: low` - Nice-to-have features

**Type** (what kind of work)
- 🐛 `bug` - Something broken
- ✨ `enhancement` - New feature
- 📝 `documentation` - Docs work
- 🔒 `security` - Security-related
- ⚡ `performance` - Performance work
- ♿ `accessibility` - Accessibility improvements

**Status** (current state)
- 🔍 `triage` - Needs review
- ✅ `ready` - Ready to start
- 🚧 `in progress` - Being worked on
- 🚫 `blocked` - Blocked by dependency
- 👀 `needs review` - Needs code review
- 🔗 `has-pr` - Has linked PR

**Feature Area** (which part of app)
- 🎨 `area: ui` - User interface
- 🗄️ `area: data` - Database/storage
- 🌐 `area: api` - Network/API
- 🔐 `area: auth` - Authentication
- 🧪 `area: testing` - Tests
- 🏗️ `area: ci-cd` - Build system

**User Type** (who it affects)
- 👷 `user: researcher` - Daily wage workers
- 🏗️ `user: data scientist` - Data Scientists
- 📋 `user: analyst` - NREGA workers
- 👥 `user: all` - All users

**Effort** (size of work)
- `effort: XS` - < 1 hour
- `effort: S` - 1-3 hours
- `effort: M` - 3-8 hours (half day to full day)
- `effort: L` - 1-3 days
- `effort: XL` - > 3 days

### Step 2: Milestones

Run the milestones setup script:

```bash
./.github/scripts/setup-milestones.sh
```

**Milestones created:**

**Release Milestones:**
- **v1.0 - MVP Launch** (Due: Feb 2025)
  - Core authentication, work discovery, NREGA integration
- **v1.1 - Enhanced Features** (Due: Mar 2025)
  - Offline mode, push notifications, advanced search
- **v1.2 - Stability & Performance** (Due: Apr 2025)
  - Bug fixes, optimizations, comprehensive testing
- **v2.0 - Scale & Integration** (Due: Jun 2025)
  - Backend integration, real-time updates, advanced features

**Theme Milestones:**
- **Security Improvements** - Security audit, penetration testing
- **Testing & Quality** - Test coverage, integration tests
- **Documentation** - User guides, API docs
- **Technical Debt** - Refactoring, architecture improvements

---

## Manual Project Board Setup

GitHub Projects (Beta) must be created through the web interface.

### 1. Create New Project

1. Go to: https://github.com/akaash-nigam/visionOS_Research-Web-Crawler
2. Click **Projects** tab
3. Click **New project** (green button)
4. Choose **Team backlog** template
5. Name: `Research-Web-Crawler Development`
6. Click **Create**

### 2. Get Project URL

After creation, note your project URL:
```
https://github.com/users/akaash-nigam/projects/[NUMBER]
```

Update this URL in `.github/workflows/project-automation.yml` at line 20.

---

## Custom Fields Configuration

Add these custom fields to your project for better organization.

### How to Add Custom Fields

1. In your project, click **⚙️ Settings** (top right)
2. Scroll to **Custom fields**
3. Click **+ New field**

### Fields to Add

#### 1. Priority
- **Type:** Single select
- **Options:**
  - 🔴 Critical
  - 🟠 High
  - 🟡 Medium
  - 🟢 Low

#### 2. User Type
- **Type:** Single select
- **Options:**
  - 👷 Worker
  - 🏗️ Data Scientist
  - 📋 NREGA
  - 👥 All Users

#### 3. Feature Area
- **Type:** Single select
- **Options:**
  - 🎨 UI
  - 🗄️ Data
  - 🌐 API
  - 🔐 Auth
  - 🧪 Testing
  - ⚙️ CI/CD
  - 🏛️ Architecture

#### 4. Effort
- **Type:** Single select
- **Options:**
  - XS (< 1 hour)
  - S (1-3 hours)
  - M (3-8 hours)
  - L (1-3 days)
  - XL (> 3 days)

#### 5. Sprint (Optional)
- **Type:** Text
- **Description:** Sprint identifier (e.g., "Sprint 1", "2025-W01")

#### 6. Assignee
- **Type:** Assignees
- (Built-in field, just enable it)

#### 7. Milestone
- **Type:** Milestone
- (Built-in field, just enable it)

---

## View Configurations

Create multiple views for different workflows.

### Default Views

#### 1. Board View (Kanban)
- **Name:** Board
- **Layout:** Board
- **Group by:** Status
- **Columns:**
  - 📋 Backlog
  - 🔜 To Do
  - 🚧 In Progress
  - 👀 In Review
  - ✅ Done
  - 🚫 Blocked (optional)

**Filters:**
- Show: Open items only
- Exclude: Stale issues

#### 2. Table View (Detailed)
- **Name:** All Items
- **Layout:** Table
- **Columns to show:**
  - Title
  - Status
  - Priority
  - User Type
  - Feature Area
  - Effort
  - Assignee
  - Milestone
  - Labels
  - Last updated

**Sort:** Priority (Critical → Low), then Updated (newest first)

#### 3. Roadmap View (Timeline)
- **Name:** Roadmap
- **Layout:** Roadmap
- **Start date:** Created date
- **Target date:** Milestone due date
- **Group by:** Milestone

**Filters:**
- Show: Items with milestones

#### 4. Priority View
- **Name:** By Priority
- **Layout:** Board
- **Group by:** Priority field
- **Columns:** Critical, High, Medium, Low

**Sort:** By effort (XL → XS)

#### 5. Feature Areas View
- **Name:** By Feature
- **Layout:** Board
- **Group by:** Feature Area
- **Columns:** UI, Data, API, Auth, Testing, CI/CD

#### 6. Sprint View (Optional)
- **Name:** Current Sprint
- **Layout:** Board
- **Group by:** Status
- **Filter:** Sprint = "Current Sprint Name"

---

## Automation Workflows

### Built-in Automations (Enable in Project Settings)

1. **Auto-add to project**
   - When: Item created
   - Then: Add to project
   - Set status: Backlog

2. **Auto-archive on close**
   - When: Item closed
   - Then: Archive item

3. **Auto-move on PR**
   - When: Pull request opened
   - Then: Set status to "In Review"

   - When: Pull request merged
   - Then: Set status to "Done"

### GitHub Actions Automations (Already Configured)

File: `.github/workflows/project-automation.yml`

**Automatic actions:**
- ✅ New issues → automatically added to project
- ✅ Priority labels → auto-assigned based on keywords
- ✅ PR opened → linked issues labeled with "has-pr"
- ✅ PR merged → linked issues auto-closed
- ✅ Stale issues → marked after 60 days of inactivity

---

## Daily Usage

### For Issue Creation

**1. Create via GitHub Issues:**
```bash
# Create issue with labels
gh issue create \
  --title "Fix login crash on visionOS 11" \
  --body "Description..." \
  --label "bug,priority: high,area: auth" \
  --milestone "v1.0 - MVP Launch"
```

**2. Create directly from project board:**
- Click **+** in any column
- Fill in title
- Add description, labels, custom fields
- Assign to yourself

### For Issue Management

**Moving items:**
- Drag and drop between columns
- Or use keyboard: `Cmd/Ctrl + arrow keys`

**Bulk operations:**
- Select multiple items (Cmd/Ctrl + click)
- Right-click → Set priority / Set status / etc.

**Filtering:**
- Click filter icon
- Add filters: `priority:high label:bug`
- Save as custom view

### For Sprint Planning

**Planning a sprint:**

1. Go to **Table** view
2. Filter: `status:ready priority:high,medium`
3. Add effort estimates
4. Select items totaling your sprint capacity
5. Set `Sprint` field to current sprint name
6. Move to "To Do" column

**During sprint:**

1. Switch to **Board** view
2. Filter by current sprint: `sprint:"Sprint 1"`
3. Move items as you work on them

**Sprint retrospective:**

1. Go to **Table** view
2. Filter: `sprint:"Sprint 1" is:closed`
3. Review completed items
4. Calculate velocity (total effort completed)

---

## Best Practices

### Issue Management

**1. Always set these fields:**
- Priority (for triage)
- User Type (who it helps)
- Feature Area (which team)
- Effort (for planning)

**2. Use milestones:**
- Group related work
- Track release progress
- Set realistic due dates

**3. Link PRs to issues:**
```markdown
In PR description:
Fixes #123
Closes #456
```

**4. Keep issues small:**
- Break large features into smaller tasks
- Prefer effort: S or M
- Epic issues can link to smaller ones

### Labels Strategy

**Apply multiple labels:**
```
✅ Good: bug, priority: high, area: auth, user: researcher
❌ Bad: bug (too vague)
```

**Use status labels sparingly:**
- The Status field (in project) is preferred
- Labels are for cross-project status

### Project Board Hygiene

**Daily:**
- [ ] Move items you're working on to "In Progress"
- [ ] Update items when blocked
- [ ] Move completed items to "Done"

**Weekly:**
- [ ] Triage new issues (set priority, effort)
- [ ] Review "Blocked" column
- [ ] Archive completed items
- [ ] Plan next sprint

**Monthly:**
- [ ] Review and update milestones
- [ ] Clean up stale issues
- [ ] Update roadmap view
- [ ] Retrospective on closed items

---

## Advanced Features

### Saved Filters

Create saved filters for common views:

**My Work:**
```
assignee:@me is:open
```

**High Priority Bugs:**
```
label:bug priority:high is:open
```

**Ready for Development:**
```
status:ready -label:blocked
```

### Keyboard Shortcuts

- `C` - Create new item
- `CMD/CTRL + K` - Command palette
- `CMD/CTRL + F` - Search/filter
- `E` - Edit item
- Arrow keys - Navigate
- `Enter` - Open item

### API & Automation

Export project data:
```bash
# Get all items in project
gh project item-list [PROJECT_NUMBER] --owner akaash-nigam
```

Bulk add issues:
```bash
# Add all bugs to project
gh issue list --label bug --json number \
  | jq '.[].number' \
  | xargs -I {} gh project item-add [PROJECT_NUMBER] --owner akaash-nigam --url "https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/issues/{}"
```

---

## Troubleshooting

### Issues not auto-adding to project

**Solution:**
1. Check project URL in `.github/workflows/project-automation.yml`
2. Ensure workflow has permissions (Settings → Actions → Workflow permissions)
3. Verify project is public or accessible

### Custom fields not showing

**Solution:**
1. Go to project Settings
2. Check field is enabled
3. Refresh page
4. Try different view (table view shows all fields)

### Automation not working

**Solution:**
1. Check Actions tab for workflow errors
2. Verify GITHUB_TOKEN has correct permissions
3. Check if workflow is enabled (not disabled)

---

## Resources

**GitHub Docs:**
- [Projects overview](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Custom fields](https://docs.github.com/en/issues/planning-and-tracking-with-projects/understanding-fields)
- [Automating projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project)

**Our Docs:**
- Repository setup: `.github/REPOSITORY_SETUP.md`
- Workflow automation: `.github/workflows/README.md`
- Security policy: `SECURITY.md`

---

## Quick Reference Card

```
📋 CREATE ISSUE
  gh issue create --title "..." --label "bug,priority:high"

🏷️ ADD LABELS
  gh issue edit [NUMBER] --add-label "area:ui,effort:M"

🎯 SET MILESTONE
  gh issue edit [NUMBER] --milestone "v1.0"

📊 VIEW PROJECT
  https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/projects

🔍 SEARCH ISSUES
  is:open label:bug priority:high assignee:@me

⚡ KEYBOARD SHORTCUTS
  C = Create, E = Edit, Cmd+K = Command palette
```

---

**Last Updated:** 2025-12-02
**Maintainer:** @akaash-nigam
