# GitHub Repository Setup Guide

This guide covers GitHub settings that need to be configured via the GitHub web interface.

## Table of Contents
1. [Security Settings](#security-settings)
2. [Branch Protection Rules](#branch-protection-rules)
3. [GitHub Projects](#github-projects)
4. [Repository Settings](#repository-settings)
5. [Secrets Configuration](#secrets-configuration)
6. [Team & Collaborator Access](#team--collaborator-access)

---

## Security Settings

### Enable Security Features

**Path:** Settings → Security → Code security and analysis

#### ✅ Required Security Features:

1. **Dependency graph**
   - [x] Enable
   - Automatically enabled for public repos
   - Visualizes project dependencies

2. **Dependabot alerts**
   - [x] Enable
   - Receive alerts when dependencies have security vulnerabilities
   - Free for all repositories

3. **Dependabot security updates**
   - [x] Enable
   - Automatically creates PRs to update vulnerable dependencies
   - Works with `.github/dependabot.yml` config

4. **Dependabot version updates**
   - [x] Enable
   - Automatically creates PRs for dependency updates (not just security)
   - Configured via `.github/dependabot.yml`

5. **Code scanning (CodeQL)**
   - [x] Enable
   - Set up via `.github/workflows/codeql-analysis.yml` (already created)
   - Scans for security vulnerabilities in your code
   - Free for public repositories

6. **Secret scanning**
   - [x] Enable (automatic for public repos)
   - Detects secrets accidentally committed
   - Partner patterns automatically enabled
   - Consider enabling push protection (Settings → Code security → Secret scanning)

#### Push Protection (Recommended)

**Path:** Settings → Code security and analysis → Secret scanning → Push protection

- [x] Enable push protection
- Prevents commits containing secrets from being pushed
- Can bypass with justification if needed

---

## Branch Protection Rules

**Path:** Settings → Branches → Add branch protection rule

### Main Branch Protection

**Branch name pattern:** `main`

#### ✅ Recommended Rules:

**Protect matching branches:**
- [x] Require a pull request before merging
  - [x] Require approvals: 1
  - [x] Dismiss stale pull request approvals when new commits are pushed
  - [ ] Require review from Code Owners (enable if you have team)
  - [x] Restrict who can dismiss pull request reviews (optional)

- [x] Require status checks to pass before merging
  - [x] Require branches to be up to date before merging
  - **Select required status checks:**
    - `build` (from visionos-ci.yml)
    - `analyze / Analyze (java)` (from codeql-analysis.yml)

- [x] Require conversation resolution before merging
  - Ensures all review comments are addressed

- [ ] Require signed commits (optional, but recommended for security)
  - Requires contributors to sign commits with GPG

- [x] Require linear history
  - Prevents merge commits, keeps history clean
  - Only allow squash and merge or rebase

- [x] Include administrators
  - Apply rules to administrators too
  - Prevents accidental force pushes

- [ ] Restrict who can push to matching branches (optional)
  - Useful if you have a team

- [x] Allow force pushes: **Never**
  - Prevents history rewriting

- [x] Allow deletions: **Never**
  - Prevents accidental branch deletion

### Develop Branch Protection (If Using)

**Branch name pattern:** `develop`

Same rules as main, but potentially less strict:
- Require 1 approval
- Require status checks
- Allow squash merge

---

## GitHub Projects

**Path:** Projects tab → New project

### Option 1: Project Board (Classic)

Good for simple task tracking:

1. **Create board:** "Research-Web-Crawler Development"
2. **Columns:**
   - 📋 Backlog
   - 🔜 To Do
   - 🏗️ In Progress
   - 👀 In Review
   - ✅ Done
   - 🚫 Won't Fix / Blocked

3. **Automation:**
   - Auto-move issues to "In Progress" when linked PR is opened
   - Auto-move to "In Review" when PR is ready
   - Auto-move to "Done" when PR is merged

### Option 2: Projects (Beta) - Recommended

Modern project management with better features:

1. **Create project:** "Research-Web-Crawler Roadmap"
2. **Template:** Team backlog
3. **Views:**
   - **Board view** (default)
   - **Table view** for detailed planning
   - **Roadmap view** for timeline planning

4. **Custom fields:**
   - Priority (High, Medium, Low)
   - User Type (Worker, Data Scientist, Both)
   - Feature Area (UI, Backend, Security, etc.)
   - Effort (S, M, L, XL)
   - Sprint (if using sprints)

5. **Workflows:**
   - Auto-add issues to project
   - Auto-set status based on PR state
   - Auto-assign labels

### Suggested Project Structure

**Milestones:**
- v1.0 - MVP Launch
- v1.1 - Enhanced Features
- v2.0 - Scale & Performance

**Labels to create:**

**Priority:**
- 🔴 priority: critical
- 🟠 priority: high
- 🟡 priority: medium
- 🟢 priority: low

**Type:**
- 🐛 bug
- ✨ enhancement
- 📝 documentation
- 🔒 security
- ⚡ performance
- ♿ accessibility

**Status:**
- 🔍 triage
- 🎯 ready
- 🚧 in progress
- ⏸️ blocked
- ✅ done

**Feature Area:**
- 🎨 ui
- 🗄️ data
- 🌐 api
- 🧪 testing
- 📱 visionos
- 🏗️ architecture

**User Type:**
- 👷 worker
- 🏗️ contractor
- 📋 nrega

---

## Repository Settings

**Path:** Settings → General

### General Settings

**Repository name:** `visionOS_Research-Web-Crawler`

**Description:**
```
Research-Web-Crawler - visionOS app Research data collection and analysis platform
```

**Topics (tags):**
- visionos
- swift
- jetpack-compose
- india
- hilt
- room-database

**Features:**
- [x] Issues
- [x] Projects
- [ ] Wiki (optional - you have docs/ instead)
- [ ] Sponsorships (if accepting donations)
- [x] Discussions (recommended for community Q&A)
- [ ] Preserve this repository (for long-term archival)

### Pull Requests

**Allow merge commits:** [ ] No
**Allow squash merging:** [x] Yes (recommended)
- Default commit message: Pull request title and description

**Allow rebase merging:** [x] Yes
**Always suggest updating pull request branches:** [x] Yes
**Allow auto-merge:** [x] Yes
**Automatically delete head branches:** [x] Yes

### Archives

- [ ] Include Git LFS objects in archives (if using LFS)

---

## Secrets Configuration

**Path:** Settings → Secrets and variables → Actions

### Secrets for Release Builds

Required for signed release builds (see `.github/workflows/visionos-release.yml`):

1. **KEYSTORE_FILE**
   - Type: Actions secret
   - Value: Base64-encoded release keystore
   - Generation:
     ```bash
     base64 -i release-keystore.jks | pbcopy
     ```

2. **KEYSTORE_PASSWORD**
   - Type: Actions secret
   - Value: Your keystore password

3. **KEY_ALIAS**
   - Type: Actions secret
   - Value: Key alias (e.g., "visionos_research-web-crawler")

4. **KEY_PASSWORD**
   - Type: Actions secret
   - Value: Key password

### Environment Variables (Optional)

**Path:** Settings → Secrets and variables → Actions → Variables tab

Consider adding:
- `API_BASE_URL` - Backend API URL
- `SENTRY_DSN` - Error tracking (if using Sentry)
- `ANALYTICS_KEY` - Analytics key (if using Firebase Analytics)

---

## Team & Collaborator Access

**Path:** Settings → Collaborators and teams

### Access Levels

- **Read:** Can view and clone the repository
- **Triage:** Can manage issues and pull requests
- **Write:** Can push to the repository
- **Maintain:** Can manage the repository without access to sensitive actions
- **Admin:** Full access

### Recommended Structure

**For team growth:**

1. **Core Team** (Admin)
   - Project owner
   - Lead developers

2. **Developers** (Write)
   - Can create branches and PRs
   - Cannot merge to protected branches without approval

3. **Contributors** (Write)
   - Community contributors
   - Need approval to merge

4. **Reviewers** (Triage)
   - Can review and manage issues/PRs
   - Cannot merge

### Outside Collaborators

**Path:** Settings → Collaborators → Add people

Invite by GitHub username or email.

---

## Additional Recommendations

### Enable Discussions

**Path:** Settings → General → Features → Discussions

Create categories:
- 📣 Announcements
- 💡 Ideas & Feature Requests
- 🙏 Q&A
- 🌟 Show and Tell
- 💬 General

### Repository Insights

**Path:** Insights tab

Monitor:
- **Pulse:** Activity summary
- **Contributors:** Who's contributing
- **Traffic:** Views and clones
- **Commits:** Commit frequency
- **Code frequency:** Additions/deletions over time
- **Dependency graph:** Dependency tree
- **Network:** Fork network

### Notifications

**Path:** Personal Settings → Notifications

Recommended for team:
- Watch repository for all activity
- Custom: Watch releases, issues, PRs
- Enable email notifications for security alerts

---

## Verification Checklist

After setup, verify:

- [ ] Security features enabled (Dependabot, CodeQL, Secret scanning)
- [ ] Branch protection rules active on `main`
- [ ] Status checks configured (CI must pass)
- [ ] Issue templates working (create test issue)
- [ ] PR template appearing (create test PR)
- [ ] CODEOWNERS working (automatic reviewer assignment)
- [ ] GitHub Actions running successfully
- [ ] Dependabot creating update PRs
- [ ] Project board created and linked
- [ ] Labels created and applied
- [ ] Secrets configured for releases (when ready)
- [ ] Team access configured (if applicable)

---

## Next Steps

1. **Enable all security features** in Settings → Security
2. **Set up branch protection** for `main` branch
3. **Create a project board** for task tracking
4. **Review and merge Dependabot PRs** as they appear
5. **Test CI/CD** by creating a test PR
6. **Configure release secrets** when ready to deploy
7. **Invite team members** with appropriate access levels

---

## References

- [GitHub Security Features](https://docs.github.com/en/code-security)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Code Owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [Dependabot](https://docs.github.com/en/code-security/dependabot)

---

**Last Updated:** 2025-12-02
