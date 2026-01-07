#!/bin/bash
# Script to set up GitHub milestones for Research-Web-Crawler project
# Requires: gh CLI (GitHub CLI) installed and authenticated

set -e

REPO="akaash-nigam/visionOS_Research-Web-Crawler"

echo "🎯 Setting up GitHub milestones for $REPO"
echo ""

# Function to create milestone
create_milestone() {
  local title=$1
  local due_date=$2
  local description=$3

  # Check if milestone exists
  if gh api "repos/$REPO/milestones" --jq ".[] | select(.title == \"$title\")" | grep -q .; then
    echo "   Milestone '$title' already exists"
  else
    echo "   Creating: $title"
    if [ -n "$due_date" ]; then
      gh api "repos/$REPO/milestones" \
        -f title="$title" \
        -f description="$description" \
        -f due_on="$due_date" \
        -f state="open" > /dev/null
    else
      gh api "repos/$REPO/milestones" \
        -f title="$title" \
        -f description="$description" \
        -f state="open" > /dev/null
    fi
  fi
}

# Create milestones for different releases
echo "📦 Creating release milestones..."

create_milestone "v1.0 - MVP Launch" "2025-02-28T23:59:59Z" \
"Minimum Viable Product with core features:
- User authentication (OTP)
- Daily wage work discovery
- NREGA job card integration
- Data Scientist ratings
- Basic UI with Hindi localization
- Payment history tracking"

create_milestone "v1.1 - Enhanced Features" "2025-03-31T23:59:59Z" \
"Enhanced user experience and features:
- Offline mode support
- Push notifications
- Advanced search and filters
- Improved UI/UX
- Performance optimizations
- Additional safety features"

create_milestone "v1.2 - Stability & Performance" "2025-04-30T23:59:59Z" \
"Focus on stability and performance:
- Bug fixes from v1.0 and v1.1
- Performance improvements
- Memory optimization
- Battery usage optimization
- Comprehensive testing
- Analytics integration"

create_milestone "v2.0 - Scale & Integration" "2025-06-30T23:59:59Z" \
"Scaling and third-party integrations:
- Backend API integration
- Real-time updates
- Advanced analytics
- Social features
- Government portal integration
- Multi-language support beyond Hindi"

# Create feature-specific milestones
echo ""
echo "🎨 Creating feature milestones..."

create_milestone "Security Improvements" "" \
"Security-related enhancements:
- Security audit findings
- Penetration testing fixes
- Enhanced encryption
- Secure API integration
- Compliance requirements"

create_milestone "Testing & Quality" "" \
"Testing and quality improvements:
- Increase test coverage to 80%+
- Add integration tests
- UI/UX testing
- Performance testing
- Accessibility testing"

create_milestone "Documentation" "" \
"Documentation improvements:
- API documentation
- User guides (English & Hindi)
- Developer documentation
- Architecture documentation
- Deployment guides"

create_milestone "Technical Debt" "" \
"Addressing technical debt:
- Code refactoring
- Architecture improvements
- Dependency updates
- Legacy code removal
- Build optimization"

echo ""
echo "✅ All milestones created successfully!"
echo ""
echo "📋 To view all milestones:"
echo "   gh api repos/$REPO/milestones --jq '.[] | {title, due_on, open_issues, closed_issues}'"
echo ""
echo "🔗 Web view:"
echo "   https://github.com/$REPO/milestones"
