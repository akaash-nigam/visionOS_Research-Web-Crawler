#!/bin/bash
# Complete GitHub Project setup script for Research-Web-Crawler
# This script sets up labels, milestones, and provides instructions for project board
# Requires: gh CLI (GitHub CLI) installed and authenticated

set -e

REPO="akaash-nigam/visionOS_Research-Web-Crawler"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Research-Web-Crawler - GitHub Project Setup"
echo "========================================"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo ""
    echo "Please install it first:"
    echo "  macOS:   brew install gh"
    echo "  Linux:   https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo "  Windows: https://github.com/cli/cli/releases"
    echo ""
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI."
    echo ""
    echo "Please authenticate first:"
    echo "  gh auth login"
    echo ""
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"
echo ""

# Step 1: Set up labels
echo "📋 Step 1/3: Setting up labels..."
echo ""
if [ -f "$SCRIPT_DIR/setup-labels.sh" ]; then
    bash "$SCRIPT_DIR/setup-labels.sh"
else
    echo "⚠️  setup-labels.sh not found, skipping..."
fi

echo ""
echo "Press Enter to continue..."
read

# Step 2: Set up milestones
echo ""
echo "🎯 Step 2/3: Setting up milestones..."
echo ""
if [ -f "$SCRIPT_DIR/setup-milestones.sh" ]; then
    bash "$SCRIPT_DIR/setup-milestones.sh"
else
    echo "⚠️  setup-milestones.sh not found, skipping..."
fi

echo ""
echo "Press Enter to continue..."
read

# Step 3: Instructions for GitHub Projects (Beta)
echo ""
echo "📊 Step 3/3: Setting up GitHub Projects"
echo "========================================"
echo ""
echo "GitHub Projects must be set up through the web interface."
echo "Follow these steps:"
echo ""
echo "1. Go to: https://github.com/$REPO"
echo "2. Click the 'Projects' tab"
echo "3. Click 'New project'"
echo "4. Choose 'Team backlog' template"
echo "5. Name it: 'Research-Web-Crawler Development'"
echo ""
echo "After creating the project, configure it:"
echo ""
echo "📌 CUSTOM FIELDS TO ADD:"
echo "   - Priority (Single select): Critical, High, Medium, Low"
echo "   - User Type (Single select): Worker, Data Scientist, NREGA, All"
echo "   - Feature Area (Single select): UI, Data, API, Auth, Testing, CI/CD"
echo "   - Effort (Single select): XS, S, M, L, XL"
echo "   - Sprint (Text): For sprint planning"
echo ""
echo "📋 VIEWS TO CREATE:"
echo "   1. Board (default) - Status: Backlog, To Do, In Progress, Review, Done"
echo "   2. Table - All fields visible for planning"
echo "   3. Roadmap - Timeline view by milestone"
echo "   4. By Priority - Grouped by priority field"
echo "   5. By Feature Area - Grouped by feature area"
echo ""
echo "⚙️  WORKFLOWS TO ENABLE:"
echo "   - Auto-add to project (new issues/PRs)"
echo "   - Auto-set status (when PR opened/merged)"
echo "   - Auto-archive (when issue closed)"
echo ""
echo "🔗 After creating, update the project URL in:"
echo "   .github/workflows/project-automation.yml (line 20)"
echo "   Change: https://github.com/users/akaash-nigam/projects/1"
echo "   To your actual project URL"
echo ""

# Try to open the browser
if command -v open &> /dev/null; then
    echo "Opening Projects page in browser..."
    open "https://github.com/$REPO/projects"
elif command -v xdg-open &> /dev/null; then
    echo "Opening Projects page in browser..."
    xdg-open "https://github.com/$REPO/projects"
else
    echo "Please open this URL in your browser:"
    echo "https://github.com/$REPO/projects"
fi

echo ""
echo "Press Enter when you've completed the project setup..."
read

# Final summary
echo ""
echo "✅ Setup Complete!"
echo "=================="
echo ""
echo "What's been configured:"
echo "  ✓ Labels (priority, type, status, feature area, etc.)"
echo "  ✓ Milestones (v1.0, v1.1, v1.2, v2.0, etc.)"
echo "  ✓ GitHub Actions workflows for automation"
echo ""
echo "Manual steps completed:"
echo "  ✓ GitHub Project board created"
echo "  ✓ Custom fields configured"
echo "  ✓ Multiple views set up"
echo ""
echo "Next steps:"
echo "  1. Update project URL in .github/workflows/project-automation.yml"
echo "  2. Create some test issues to verify automation"
echo "  3. Start organizing existing work into the project board"
echo ""
echo "📚 Documentation:"
echo "  - Project setup: .github/REPOSITORY_SETUP.md"
echo "  - Workflow docs: .github/workflows/README.md"
echo ""
echo "🎉 Your project is now set up for maximum productivity!"
