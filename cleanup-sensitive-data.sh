#!/bin/bash

# Script to remove sensitive data from Git history
# This will rewrite ALL commits to replace sensitive data with placeholders

set -e

echo " Git History Cleanup - Removing Sensitive Data"
echo "================================================"
echo ""
echo "This will replace:"
echo "  - AWS Account ID: 123456789012 → 123456789012"
echo "  - S3 Bucket: YOUR-UNIQUE-BUCKET-NAME → YOUR-UNIQUE-BUCKET-NAME"
echo "  - Username: charlie → user"
echo ""
echo "WARNING:  WARNING: This rewrites Git history!"
echo "WARNING:  Make sure you have a backup of your .personal files"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Creating expressions file for git-filter-repo..."

cat > /tmp/git-filter-expressions.txt << 'EOF'
***REMOVED***
123456789012==>123456789012

***REMOVED***
YOUR-UNIQUE-BUCKET-NAME==>YOUR-UNIQUE-BUCKET-NAME

***REMOVED***
regex: -r--------\s+1\s+charlie\s+staff==>\-r--------  1 user  staff

***REMOVED***
regex:123456789012\.dkr\.ecr\.us-east-1\.amazonaws\.com==>123456789012.dkr.ecr.us-east-1.amazonaws.com
EOF

echo "SUCCESS: Expressions file created"
echo ""
echo "Step 2: Running git-filter-repo..."
echo "   (This may take a minute)"
echo ""

# Run git-filter-repo to replace all sensitive strings
git filter-repo --force --replace-text /tmp/git-filter-expressions.txt

echo ""
echo "SUCCESS: Git history rewritten successfully!"
echo ""
echo "Step 3: Verification"
echo "-------------------"

# Verify no sensitive data remains
echo "Searching for sensitive data in history..."
if git log --all --full-history -p | grep -q "123456789012"; then
    echo "ERROR: AWS Account ID still found!"
    exit 1
else
    echo "SUCCESS: AWS Account ID cleaned"
fi

if git log --all --full-history -p | grep -q "YOUR-UNIQUE-BUCKET-NAME"; then
    echo "ERROR: S3 bucket name still found!"
    exit 1
else
    echo "SUCCESS: S3 bucket name cleaned"
fi

echo ""
echo " Success! Git history is now clean."
echo ""
echo "Next steps:"
echo "1. Review changes: git log --oneline"
echo "2. Force push to GitHub: git push --force origin main"
echo ""
echo "WARNING:  IMPORTANT AFTER FORCE PUSH:"
echo "   - All collaborators must re-clone the repository"
echo "   - Old clones will have outdated history"
echo "   - Tell team members: git clone <repo-url> --force"
