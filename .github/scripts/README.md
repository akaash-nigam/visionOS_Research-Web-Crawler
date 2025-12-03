# GitHub Setup Scripts

Automated scripts for configuring the Research-Web-Crawler GitHub repository.

## Prerequisites

**Required:**
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated

**Install GitHub CLI:**

```bash
# macOS
brew install gh

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows
winget install --id GitHub.cli
# or download from: https://github.com/cli/cli/releases
```

**Authenticate:**
```bash
gh auth login
```

## Scripts

### 1. Complete Setup (Recommended)

**`setup-project.sh`** - Run all setup scripts in sequence

```bash
./.github/scripts/setup-project.sh
```

**What it does:**
- ✅ Creates all labels
- ✅ Creates all milestones
- ✅ Provides instructions for project board setup
- ✅ Opens browser to help you create the project

**Duration:** 5-10 minutes (including project board creation)

---

### 2. Individual Scripts

#### Labels Setup

**`setup-labels.sh`** - Create all repository labels

```bash
./.github/scripts/setup-labels.sh
```

**Creates:**
- Priority labels (critical, high, medium, low)
- Type labels (bug, enhancement, security, etc.)
- Status labels (triage, ready, in progress, etc.)
- Feature area labels (ui, data, api, auth, etc.)
- User type labels (worker, contractor, nrega, all)
- Effort labels (XS, S, M, L, XL)
- Special labels (good first issue, help wanted, etc.)

**Total:** 40+ labels

**View labels:**
```bash
gh label list --repo akaash-nigam/visionOS_Research-Web-Crawler
```

---

#### Milestones Setup

**`setup-milestones.sh`** - Create release and feature milestones

```bash
./.github/scripts/setup-milestones.sh
```

**Creates:**

**Release Milestones:**
- v1.0 - MVP Launch (Feb 2025)
- v1.1 - Enhanced Features (Mar 2025)
- v1.2 - Stability & Performance (Apr 2025)
- v2.0 - Scale & Integration (Jun 2025)

**Theme Milestones:**
- Security Improvements
- Testing & Quality
- Documentation
- Technical Debt

**View milestones:**
```bash
gh api repos/akaash-nigam/visionOS_Research-Web-Crawler/milestones --jq '.[] | {title, due_on, open_issues}'
```

---

## After Running Scripts

### 1. Create GitHub Project Board

The scripts will guide you, but here's a quick reference:

1. Go to: https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/projects
2. Click **New project** → **Team backlog** template
3. Name: "Research-Web-Crawler Development"
4. Configure custom fields (see PROJECT_GUIDE.md)
5. Set up multiple views (Board, Table, Roadmap)

### 2. Update Project URL

After creating the project, update the URL in:

**File:** `.github/workflows/project-automation.yml`
**Line:** 20

```yaml
project-url: https://github.com/users/akaash-nigam/projects/YOUR_PROJECT_NUMBER
```

### 3. Test the Setup

Create a test issue to verify automation:

```bash
gh issue create \
  --title "Test: Automation check" \
  --body "Testing automated workflows" \
  --label "bug,priority: high"
```

**Expected behavior:**
- Issue automatically added to project board
- Status set to "Backlog"
- Priority label applied

---

## Troubleshooting

### Script fails with "permission denied"

**Solution:**
```bash
chmod +x ./.github/scripts/*.sh
```

### "gh: command not found"

**Solution:** Install GitHub CLI (see Prerequisites above)

### "Not authenticated with GitHub"

**Solution:**
```bash
gh auth login
```

Follow the prompts to authenticate.

### Labels already exist

**Solution:** The scripts update existing labels, so it's safe to re-run.

### Milestones already exist

**Solution:** The scripts skip existing milestones. To update dates, delete and re-run, or edit manually.

---

## Manual Operations

### Delete all labels (start fresh)

```bash
gh label list --repo akaash-nigam/visionOS_Research-Web-Crawler --json name \
  | jq -r '.[].name' \
  | xargs -I {} gh label delete {} --repo akaash-nigam/visionOS_Research-Web-Crawler --yes
```

### Delete all milestones

```bash
gh api repos/akaash-nigam/visionOS_Research-Web-Crawler/milestones --jq '.[].number' \
  | xargs -I {} gh api -X DELETE repos/akaash-nigam/visionOS_Research-Web-Crawler/milestones/{}
```

### Export labels to JSON

```bash
gh label list --repo akaash-nigam/visionOS_Research-Web-Crawler --json name,color,description > labels.json
```

### Bulk add issues to project

```bash
# Get your project number from the URL
PROJECT_NUMBER=1

# Add all open bugs
gh issue list --label bug --json number \
  | jq -r '.[].number' \
  | xargs -I {} gh project item-add $PROJECT_NUMBER \
    --owner akaash-nigam \
    --url "https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/issues/{}"
```

---

## Files in This Directory

```
scripts/
├── README.md                  # This file
├── setup-project.sh           # Complete setup (runs all scripts)
├── setup-labels.sh            # Create repository labels
└── setup-milestones.sh        # Create milestones
```

---

## Related Documentation

- **Project Guide:** `.github/PROJECT_GUIDE.md` - Complete project board guide
- **Repository Setup:** `.github/REPOSITORY_SETUP.md` - GitHub settings
- **Workflows:** `.github/workflows/README.md` - CI/CD documentation

---

## Questions or Issues?

- Check the [PROJECT_GUIDE.md](../PROJECT_GUIDE.md) for detailed instructions
- Review [GitHub Projects documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- Create an issue with the `question` label

---

**Last Updated:** 2025-12-02
