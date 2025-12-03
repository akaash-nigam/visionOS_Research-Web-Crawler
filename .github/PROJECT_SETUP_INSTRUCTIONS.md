# GitHub Project Board Setup Instructions

**Status:** ✅ Labels and Milestones created | ⏳ Project Board needs manual setup

Follow these step-by-step instructions to complete the GitHub Project board setup. This should take about 5-7 minutes.

---

## Prerequisites ✅ (Already Done)

- [x] Labels created (30+ labels)
- [x] Milestones created (8 milestones)
- [x] GitHub Actions workflows configured
- [x] Automation scripts ready

---

## Step 1: Create the Project Board (2 minutes)

### 1.1 Navigate to Projects

Click this link to open your repository's Projects page:
```
https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/projects
```

Or manually:
1. Go to: https://github.com/akaash-nigam/visionOS_Research-Web-Crawler
2. Click the **"Projects"** tab (between Pull requests and Wiki)

### 1.2 Create New Project

1. Click the green **"New project"** button (top right)
2. You'll see template options

### 1.3 Choose Template

1. Select **"Team backlog"** template
   - This gives you a pre-configured board with Status field
   - Has Board, Table, and Backlog views ready

### 1.4 Name Your Project

1. In the "Project name" field, enter:
   ```
   Research-Web-Crawler Development
   ```

2. (Optional) Add description:
   ```
   Project management board for Research-Web-Crawler visionOS app development
   ```

### 1.5 Create

1. Click the green **"Create project"** button
2. You'll be taken to your new project board

### 1.6 Note Your Project URL

**IMPORTANT:** Copy your project URL from the address bar. It will look like:
```
https://github.com/users/akaash-nigam/projects/[NUMBER]
```

Example: `https://github.com/users/akaash-nigam/projects/1`

**Save this URL - you'll need it in Step 3!**

---

## Step 2: Configure Custom Fields (3 minutes)

Custom fields let you track priority, effort, user type, etc.

### 2.1 Open Settings

1. In your project board, click the **⚙️ icon** (top right corner)
2. Or click the **"..."** menu → **Settings**

### 2.2 Add Priority Field

1. Scroll down to **"Custom fields"** section
2. Click **"+ New field"**
3. Fill in:
   - **Field name:** `Priority`
   - **Field type:** Select **"Single select"**
4. Click **"Save"**
5. Now add options (click "+ Add option" for each):
   - `🔴 Critical`
   - `🟠 High`
   - `🟡 Medium`
   - `🟢 Low`
6. Click **"Save"**

### 2.3 Add User Type Field

1. Click **"+ New field"** again
2. Fill in:
   - **Field name:** `User Type`
   - **Field type:** **"Single select"**
3. Add options:
   - `👷 Worker`
   - `🏗️ Data Scientist`
   - `📋 NREGA`
   - `👥 All Users`
4. Click **"Save"**

### 2.4 Add Feature Area Field

1. Click **"+ New field"**
2. Fill in:
   - **Field name:** `Feature Area`
   - **Field type:** **"Single select"**
3. Add options:
   - `🎨 UI`
   - `🗄️ Data`
   - `🌐 API`
   - `🔐 Auth`
   - `🧪 Testing`
   - `⚙️ CI/CD`
   - `🏛️ Architecture`
4. Click **"Save"**

### 2.5 Add Effort Field

1. Click **"+ New field"**
2. Fill in:
   - **Field name:** `Effort`
   - **Field type:** **"Single select"**
3. Add options:
   - `XS (< 1 hour)`
   - `S (1-3 hours)`
   - `M (3-8 hours)`
   - `L (1-3 days)`
   - `XL (> 3 days)`
4. Click **"Save"**

### 2.6 Add Sprint Field (Optional)

1. Click **"+ New field"**
2. Fill in:
   - **Field name:** `Sprint`
   - **Field type:** **"Text"**
3. Click **"Save"**

### 2.7 Enable Built-in Fields

Make sure these built-in fields are enabled:
- ✅ **Assignees** - Who's working on it
- ✅ **Labels** - GitHub labels
- ✅ **Milestone** - Release milestone
- ✅ **Repository** - Which repo (useful if you add more repos later)

---

## Step 3: Update Automation Workflow (1 minute)

Now that you have your project URL, update the automation workflow.

### 3.1 Open the Workflow File

Open this file in your editor:
```
.github/workflows/project-automation.yml
```

### 3.2 Find Line 20

Look for this line:
```yaml
project-url: https://github.com/users/akaash-nigam/projects/1
```

### 3.3 Replace with Your Project URL

Replace the URL with your actual project URL from Step 1.6:
```yaml
project-url: https://github.com/users/YOUR_USERNAME/projects/YOUR_PROJECT_NUMBER
```

Example:
```yaml
project-url: https://github.com/users/akaash-nigam/projects/3
```

### 3.4 Commit and Push

```bash
git add .github/workflows/project-automation.yml
git commit -m "Update project URL for automation"
git push origin main
```

---

## Step 4: Configure Views (2 minutes - Optional)

Create different views for different workflows.

### 4.1 Board View (Default)

This should already exist. Verify:
- Layout: **Board**
- Group by: **Status**
- Columns: Backlog, To Do, In Progress, In Review, Done

### 4.2 Create "By Priority" View

1. Click **"+ New view"** (next to current view tabs)
2. Choose **"Board"**
3. Name it: `By Priority`
4. Configure:
   - Group by: **Priority**
   - Show: Open items only
5. Save

### 4.3 Create "By Feature" View

1. Click **"+ New view"**
2. Choose **"Board"**
3. Name it: `By Feature Area`
4. Configure:
   - Group by: **Feature Area**
   - Show: Open items only
5. Save

### 4.4 Create "Roadmap" View

1. Click **"+ New view"**
2. Choose **"Roadmap"**
3. Name it: `Roadmap`
4. Configure:
   - Start date: **Created**
   - Target date: **Milestone due date**
   - Group by: **Milestone**
5. Save

### 4.5 Customize Table View

1. Switch to **"Table"** view
2. Click column headers to show/hide columns
3. Show these columns:
   - Title
   - Status
   - Priority
   - User Type
   - Feature Area
   - Effort
   - Assignees
   - Milestone
   - Labels
4. Arrange in order you prefer

---

## Step 5: Enable Project Workflows (1 minute)

Enable built-in automation for the project.

### 5.1 Open Workflows Settings

1. In project, click **⚙️** → **Workflows**
2. Or scroll down in Settings to **"Workflows"** section

### 5.2 Enable These Workflows

Turn on these built-in workflows:

**Item added to project:**
- [x] When: Item is added to project
- [x] Then: Set Status to "Backlog"

**Item closed:**
- [x] When: Item is closed
- [x] Then: Set Status to "Done"

**Pull request merged:**
- [x] When: Pull request is merged
- [x] Then: Set Status to "Done"

**Auto-archive:**
- [x] When: Item is closed
- [x] Then: Archive item (after 7 days)

---

## Step 6: Test the Setup (2 minutes)

Verify everything is working correctly.

### 6.1 Create a Test Issue

```bash
gh issue create \
  --title "[Test] Verify project automation" \
  --body "Testing automated workflows and project board integration" \
  --label "bug,priority: high,area: ui"
```

Or create via web:
1. Go to Issues → New issue
2. Title: `[Test] Verify project automation`
3. Add labels: `bug`, `priority: high`, `area: ui`
4. Submit

### 6.2 Verify Automation

Check that:
- ✅ Issue appears in your project board
- ✅ Issue is in the "Backlog" column
- ✅ Labels are applied correctly
- ✅ You can drag it between columns

### 6.3 Test PR Linking

1. Create a test branch and make a small change
2. Create a PR with description:
   ```markdown
   Fixes #[issue_number]
   ```
3. Verify:
   - ✅ Issue gets "has-pr" label
   - ✅ Comment added to issue linking to PR
   - ✅ PR shows in project board

### 6.4 Clean Up

Close the test issue and PR after verification.

---

## Step 7: Start Using It! (Ongoing)

### 7.1 Import Existing Work

If you have existing issues, add them to the project:

**Option 1: Manually**
1. Go to project board
2. Click **"+"** in any column
3. Search for existing issues
4. Add them

**Option 2: Bulk Add (via CLI)**
```bash
# Add all open bugs
gh issue list --label bug --json number | jq -r '.[].number' | \
  xargs -I {} gh project item-add 1 --owner akaash-nigam \
    --url "https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/issues/{}"
```

Replace `1` with your project number.

### 7.2 Organize Issues

For each issue, set:
- **Status** (Backlog/To Do/In Progress/etc.)
- **Priority** (Critical/High/Medium/Low)
- **User Type** (Worker/Data Scientist/NREGA/All)
- **Feature Area** (UI/Data/API/etc.)
- **Effort** (XS/S/M/L/XL)
- **Milestone** (v1.0, v1.1, etc.)

### 7.3 Start Planning

Use different views for different purposes:
- **Board view** - Daily work
- **By Priority view** - Triage and prioritization
- **By Feature view** - Feature-based planning
- **Roadmap view** - Release planning
- **Table view** - Detailed sprint planning

---

## Troubleshooting

### Issue not appearing in project

**Cause:** Project URL in workflow might be wrong

**Solution:**
1. Verify project URL in `.github/workflows/project-automation.yml`
2. Check Actions tab for workflow errors
3. Manually add the issue to test

### Custom fields not showing

**Cause:** May need to refresh or select different view

**Solution:**
1. Refresh the page
2. Try Table view (shows all fields)
3. Check Settings → Custom fields

### Automation not working

**Cause:** Workflow permissions or project settings

**Solution:**
1. Go to Settings → Actions → General
2. Workflow permissions → "Read and write permissions"
3. Check project is not private/restricted

### Can't add issues to project

**Cause:** Project settings or permissions

**Solution:**
1. Project Settings → Access
2. Make sure project is visible to repository
3. Check your GitHub permissions

---

## Quick Reference

**Project URL:**
```
https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/projects
```

**Labels:**
```
https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/labels
```

**Milestones:**
```
https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/milestones
```

**Create Issue:**
```bash
gh issue create --title "..." --label "bug,priority: high"
```

**Add Issue to Project:**
```bash
gh project item-add [PROJECT_NUM] --owner akaash-nigam \
  --url "https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/issues/[NUM]"
```

---

## Documentation

For more detailed information, see:
- **Complete Guide:** `.github/PROJECT_GUIDE.md`
- **Repository Setup:** `.github/REPOSITORY_SETUP.md`
- **Workflow Docs:** `.github/workflows/README.md`
- **Script Docs:** `.github/scripts/README.md`

---

## Checklist

Use this checklist to track your progress:

- [ ] Step 1: Created project board
- [ ] Step 2: Added custom fields (Priority, User Type, Feature Area, Effort, Sprint)
- [ ] Step 3: Updated workflow with project URL
- [ ] Step 4: Created additional views (By Priority, By Feature, Roadmap)
- [ ] Step 5: Enabled project workflows
- [ ] Step 6: Tested with sample issue
- [ ] Step 7: Added existing issues to board
- [ ] Organized issues with fields and milestones

---

**Estimated Time:** 5-10 minutes
**Last Updated:** 2025-12-02

Once complete, your GitHub Project board will be fully operational with automated issue management, priority tracking, and visual planning tools!
