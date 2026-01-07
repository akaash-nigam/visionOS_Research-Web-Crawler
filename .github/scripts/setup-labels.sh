#!/bin/bash
# Script to set up GitHub labels for Research-Web-Crawler project
# Requires: gh CLI (GitHub CLI) installed and authenticated

set -e

REPO="akaash-nigam/visionOS_Research-Web-Crawler"

echo "🏷️  Setting up GitHub labels for $REPO"
echo ""

# Function to create or update a label
create_label() {
  local name=$1
  local color=$2
  local description=$3

  # Check if label exists
  if gh label list --repo "$REPO" --json name --jq ".[] | select(.name == \"$name\")" | grep -q .; then
    echo "   Updating: $name"
    gh label edit "$name" --repo "$REPO" --color "$color" --description "$description" 2>/dev/null || true
  else
    echo "   Creating: $name"
    gh label create "$name" --repo "$REPO" --color "$color" --description "$description" 2>/dev/null || true
  fi
}

# Priority Labels
echo "📌 Creating Priority labels..."
create_label "priority: critical" "d73a4a" "Critical priority - needs immediate attention"
create_label "priority: high" "d93f0b" "High priority - should be addressed soon"
create_label "priority: medium" "fbca04" "Medium priority - normal priority"
create_label "priority: low" "0e8a16" "Low priority - nice to have"

# Type Labels
echo "🏷️  Creating Type labels..."
create_label "bug" "d73a4a" "Something isn't working"
create_label "enhancement" "a2eeef" "New feature or request"
create_label "documentation" "0075ca" "Improvements or additions to documentation"
create_label "security" "e99695" "Security-related issue or enhancement"
create_label "performance" "f9d0c4" "Performance improvement"
create_label "accessibility" "c5def5" "Accessibility improvements"
create_label "refactoring" "d4c5f9" "Code refactoring"
create_label "testing" "bfd4f2" "Related to testing"

# Status Labels
echo "📊 Creating Status labels..."
create_label "triage" "ededed" "Needs triage and prioritization"
create_label "ready" "0e8a16" "Ready to be worked on"
create_label "in progress" "fbca04" "Currently being worked on"
create_label "blocked" "d73a4a" "Blocked by another issue or dependency"
create_label "needs review" "d876e3" "Needs code review"
create_label "has-pr" "7057ff" "Has an associated pull request"
create_label "stale" "eeeeee" "Inactive for extended period"

# Feature Area Labels
echo "🎨 Creating Feature Area labels..."
create_label "area: ui" "c2e0c6" "User interface related"
create_label "area: data" "fef2c0" "Data layer (database, repositories)"
create_label "area: api" "bfdadc" "API and network layer"
create_label "area: auth" "f9c0d1" "Authentication and authorization"
create_label "area: testing" "d4c5f9" "Testing infrastructure"
create_label "area: ci-cd" "1d76db" "CI/CD and build system"
create_label "area: architecture" "5319e7" "Architecture and design patterns"

# User Type Labels
echo "👥 Creating User Type labels..."
create_label "user: researcher" "c5f7c4" "Related to Researchers"
create_label "user: data scientist" "ffd8b1" "Related to Data Scientists"
create_label "user: analyst" "e3f2fd" "Related to Analysts"
create_label "user: all" "d4edda" "Affects all user types"

# Effort Labels
echo "⚡ Creating Effort labels..."
create_label "effort: XS" "e0f2f1" "Extra small effort (< 1 hour)"
create_label "effort: S" "b2dfdb" "Small effort (1-3 hours)"
create_label "effort: M" "80cbc4" "Medium effort (3-8 hours)"
create_label "effort: L" "4db6ac" "Large effort (1-3 days)"
create_label "effort: XL" "00897b" "Extra large effort (> 3 days)"

# Special Labels
echo "⭐ Creating Special labels..."
create_label "good first issue" "7057ff" "Good for newcomers"
create_label "help wanted" "008672" "Extra attention is needed"
create_label "question" "d876e3" "Further information is requested"
create_label "wontfix" "ffffff" "This will not be worked on"
create_label "duplicate" "cfd3d7" "This issue or pull request already exists"
create_label "dependencies" "0366d6" "Pull requests that update a dependency file"
create_label "pinned" "006b75" "Pinned issue - never mark as stale"
create_label "roadmap" "1d76db" "Part of the product roadmap"
create_label "breaking change" "d73a4a" "Introduces breaking changes"

# Platform Labels
echo "📱 Creating Platform labels..."
create_label "visionos" "3ddc84" "visionOS platform specific"
create_label "spm" "02303a" "Swift Package Manager build system"
create_label "swift" "7f52ff" "Swift language specific"
create_label "jetpack-compose" "4285f4" "Jetpack Compose related"

echo ""
echo "✅ All labels created successfully!"
echo ""
echo "📋 To view all labels:"
echo "   gh label list --repo $REPO"
echo ""
echo "🔗 Web view:"
echo "   https://github.com/$REPO/labels"
