# Repository Setup Guide
## GitHub Configuration for local-claude Project

**Purpose:** Complete guide for setting up GitHub repository with branch protection, workflows, and best practices.

**Date:** 2025-10-24

---

## Table of Contents

1. [Initial Repository Setup](#initial-repository-setup)
2. [GitHub Actions Configuration](#github-actions-configuration)
3. [Repository Rulesets](#repository-rulesets)
4. [Security Settings](#security-settings)
5. [Repository Settings](#repository-settings)
6. [Collaboration Setup](#collaboration-setup)
7. [Verification & Testing](#verification--testing)

---

## Initial Repository Setup

### Step 1: Create Repository on GitHub

**Option A: Via GitHub Web Interface**

1. Go to https://github.com/new
2. Set repository name: `local-claude`
3. Add description: "Claude environment optimization with context persistence"
4. Choose visibility: Private or Public
5. ✅ Initialize with README (optional, we have one)
6. ❌ Do NOT add .gitignore (we have one)
7. ❌ Do NOT choose a license yet
8. Click "Create repository"

**Option B: Via GitHub CLI**

```bash
cd ~/projects/local-claude

# Create repository
gh repo create dahendel/local-claude \
  --private \
  --description "Claude environment optimization with context persistence" \
  --source=. \
  --remote=origin

# Or public:
gh repo create dahendel/local-claude \
  --public \
  --description "Claude environment optimization with context persistence" \
  --source=. \
  --remote=origin
```

### Step 2: Initialize Local Git Repository

```bash
cd ~/projects/local-claude

# Initialize git if not already done
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Claude environment optimization

- Complete documentation suite
- GitHub Actions workflows
- Branch protection configuration
- Contributing guidelines

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Add remote (if not already added)
git remote add origin git@github.com:dahendel/local-claude.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Verify Repository Structure

```bash
# Check remote
git remote -v

# Verify all files tracked
git ls-files

# Check status
git status
```

**Expected structure:**
```
local-claude/
├── .github/
│   ├── workflows/
│   │   └── pr-validation.yml
│   ├── scripts/
│   │   └── setup-branch-protection.sh
│   └── CODEOWNERS
├── *.md (documentation files)
├── .gitignore
├── .markdownlint.json
└── .markdown-link-check.json
```

---

## GitHub Actions Configuration

### Workflows Included

**1. PR Validation Workflow** (`pr-validation.yml`)

Automatically runs on pull requests to `main` or `develop` branches.

**Jobs:**
- Documentation Validation
- Markdown Linting
- Link Validation
- Size Check
- PR Summary

**Triggers:**
- Pull requests to main/develop
- Changes to `*.md` files
- Changes to workflow files
- Manual dispatch

### Verify Workflow Setup

```bash
# Check workflow file exists
ls -la .github/workflows/

# Validate workflow syntax (requires act or GitHub CLI)
gh workflow list

# View workflow in GitHub
# Go to: https://github.com/dahendel/local-claude/actions
```

### Test Workflow

**Create a test PR:**

```bash
# Create test branch
git checkout -b test/workflow-validation

# Make a small change
echo "Testing workflow" >> README.md

# Commit and push
git add README.md
git commit -m "test: verify GitHub Actions workflow"
git push origin test/workflow-validation

# Create PR via CLI
gh pr create \
  --title "Test: GitHub Actions Workflow" \
  --body "Testing automated PR validation" \
  --base main
```

**What to expect:**
1. Workflow triggers automatically
2. All jobs run in parallel
3. Comments posted to PR with results
4. Status checks appear at bottom of PR
5. Merge button enabled only if checks pass

---

## Repository Rulesets

### Why Rulesets Instead of Branch Protection?

GitHub Rulesets are the modern replacement for branch protection rules, offering:
- **Broader scope:** Apply to branches, tags, and more
- **Better organization:** Multiple rulesets with clear naming
- **Flexible targeting:** Use patterns to target multiple branches
- **Bypass controls:** Granular control over who can bypass rules
- **Improved UX:** Better management interface

### Automated Setup

Use the provided script:

```bash
# Run with GitHub CLI (recommended)
.github/scripts/setup-repository-ruleset.sh dahendel local-claude

# Or with GITHUB_TOKEN
export GITHUB_TOKEN="your-token-here"
.github/scripts/setup-repository-ruleset.sh dahendel local-claude
```

### What the Ruleset Includes

**Ruleset Name:** Main Branch Protection
**Enforcement:** Active
**Target Branches:** `main`, `develop`

**Pull Request Rules:**
- ✅ Require 1 approving review
- ✅ Dismiss stale reviews on push
- ✅ Require code owner review
- ✅ Require conversation resolution

**Status Check Rules:**
- ✅ Require branches to be up to date
- ✅ Required checks:
  - Documentation Validation
  - Markdown Linting
  - Link Validation
  - Repository Size Check

**Protection Rules:**
- ✅ Block force pushes (non-fast-forward)
- ✅ Block branch deletion
- ✅ Require linear history

### Manual Setup

If you prefer manual configuration:

**Navigate to:**
```
https://github.com/dahendel/local-claude/settings/rules
```

**Click:** "New ruleset" → "New branch ruleset"

**Configure:**

1. **Ruleset name:** `Main Branch Protection`
2. **Enforcement status:** Active
3. **Bypass list:** (leave empty for now)
4. **Target branches:**
   - Click "Add target"
   - Select "Include by pattern"
   - Add: `main`
   - Add: `develop`

5. **Rules:**
   - ✅ Require a pull request before merging
     - Required approvals: 1
     - Dismiss stale pull request approvals
     - Require review from Code Owners
     - Require conversation resolution before merging

   - ✅ Require status checks to pass
     - Require branches to be up to date before merging
     - Add status checks:
       - Documentation Validation
       - Markdown Linting
       - Link Validation
       - Repository Size Check

   - ✅ Block force pushes
   - ✅ Require linear history
   - ✅ Block branch deletion

**Click:** "Create"

### Ruleset Summary

| Rule | Enabled | Purpose |
|------|---------|---------|
| Pull request required | ✅ | No direct commits to main/develop |
| Reviews required (1) | ✅ | At least 1 approval needed |
| Status checks required | ✅ | All CI must pass |
| Conversation resolution | ✅ | All feedback addressed |
| Up-to-date branches | ✅ | Prevents merge conflicts |
| Force pushes blocked | ✅ | Protect history |
| Deletions blocked | ✅ | Prevent accidents |
| Code owner review | ✅ | Domain experts review |
| Linear history | ✅ | Clean commit history |

---

## Security Settings

### Enable Security Features

Navigate to: `Settings > Security > Code security and analysis`

**Recommended settings:**

✅ **Private vulnerability reporting**
- Allows security researchers to privately report vulnerabilities

✅ **Dependency graph**
- Automatically enabled for public repos
- Shows project dependencies

✅ **Dependabot alerts**
- Get notified about vulnerabilities in dependencies

✅ **Dependabot security updates**
- Automatically create PRs to update vulnerable dependencies

✅ **Dependabot version updates** (optional)
- Keep dependencies up to date automatically

✅ **Secret scanning**
- Detects accidentally committed secrets
- Available for public repos and GitHub Advanced Security

✅ **Code scanning** (if available)
- Automated code security analysis

### Configure Dependabot

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "github-actions"

  # Python dependencies (if applicable)
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "python"
```

### Secrets Management

**Never commit:**
- API keys
- Passwords
- Tokens
- Private keys
- Environment variables with sensitive data

**Use GitHub Secrets instead:**

```bash
# Add secret via CLI
gh secret set API_KEY

# Or via web interface:
# Settings > Secrets and variables > Actions > New repository secret
```

**In workflows, reference secrets:**
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

---

## Repository Settings

### General Settings

Navigate to: `Settings > General`

**Features:**
- ✅ Wikis (optional, for additional documentation)
- ✅ Issues (for bug tracking and feature requests)
- ✅ Discussions (for Q&A and community)
- ❌ Projects (optional, enable if using GitHub Projects)

**Pull Requests:**
- ✅ Allow squash merging
- ✅ Allow rebase merging
- ❌ Allow merge commits (or enable if preferred)
- ✅ Always suggest updating pull request branches
- ✅ Automatically delete head branches

**Archives:**
- ❌ Do not include Git LFS objects (unless using LFS)

### Topics and Description

Add repository topics for discoverability:

```bash
gh repo edit --add-topic claude
gh repo edit --add-topic ai
gh repo edit --add-topic vector-database
gh repo edit --add-topic documentation
gh repo edit --add-topic context-management
gh repo edit --add-topic optimization
```

Or via web interface: Settings > Topics

### About Section

Update repository description:
- **Description:** Claude environment optimization with context persistence and vector database integration
- **Website:** (if applicable)
- **Topics:** claude, ai, vector-database, documentation, optimization

---

## Collaboration Setup

### Team Permissions

If collaborating with a team:

**Navigate to:** `Settings > Collaborators and teams`

**Add collaborators:**
```bash
# Via CLI
gh api repos/dahendel/local-claude/collaborators/USERNAME -X PUT \
  -f permission=push

# Permission levels:
# - read: Pull only
# - triage: Pull + manage issues
# - write: Pull, push, manage issues/PRs
# - maintain: Write + manage settings
# - admin: Full access
```

**Recommended structure:**
- **Admins:** Repository owner
- **Maintainers:** Core contributors
- **Writers:** Regular contributors
- **Readers:** External reviewers

### Issue Templates

Create issue templates for consistency:

**.github/ISSUE_TEMPLATE/bug_report.md:**
```markdown
---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Description**
A clear description of the bug.

**Steps to Reproduce**
1. ...
2. ...

**Expected Behavior**
What should happen.

**Actual Behavior**
What actually happens.

**Environment**
- OS: [e.g., Ubuntu 22.04]
- Python: [e.g., 3.11]
- Docker: [e.g., 20.10]

**Logs**
```
Paste relevant logs
```
```

**.github/ISSUE_TEMPLATE/feature_request.md:**
```markdown
---
name: Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

**Problem Statement**
What problem does this solve?

**Proposed Solution**
How should it work?

**Alternatives Considered**
What other approaches did you consider?

**Additional Context**
Any other relevant information.
```

### Pull Request Template

**.github/pull_request_template.md:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Related Issues
Fixes #, Relates to #

## Testing
- [ ] All tests pass
- [ ] Added new tests
- [ ] Tested locally

## Documentation
- [ ] README updated
- [ ] CLAUDE.md updated
- [ ] Other docs updated

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
```

---

## Verification & Testing

### Pre-Launch Checklist

Before making repository public or starting collaboration:

**Repository Setup:**
- [ ] Repository created and initialized
- [ ] All files committed and pushed
- [ ] .gitignore properly configured
- [ ] README.md is clear and complete
- [ ] LICENSE file added (if open source)

**GitHub Actions:**
- [ ] Workflows committed
- [ ] Configuration files in place
- [ ] Test workflow executed successfully
- [ ] Status checks appear in PRs

**Branch Protection:**
- [ ] Main branch protected
- [ ] Required checks configured
- [ ] PR reviews required
- [ ] Force pushes blocked

**Security:**
- [ ] Dependabot enabled
- [ ] Secret scanning enabled
- [ ] No secrets committed
- [ ] .env files in .gitignore

**Documentation:**
- [ ] README.md complete
- [ ] CONTRIBUTING.md in place
- [ ] CODEOWNERS configured
- [ ] Issue templates created
- [ ] PR template created

**Settings:**
- [ ] Repository description set
- [ ] Topics added
- [ ] Features configured
- [ ] Merge settings configured

### Testing Workflow

**1. Create Test PR:**

```bash
git checkout -b test/complete-validation
echo "# Test" >> TEST.md
git add TEST.md
git commit -m "test: validate complete setup"
git push origin test/complete-validation
gh pr create --fill
```

**2. Verify Checks Run:**
- Check Actions tab
- Verify all 4 jobs execute
- Confirm comments posted to PR
- Check status indicators

**3. Test Protection Rules:**
```bash
# Try to push directly to main (should fail)
git checkout main
echo "test" >> README.md
git add README.md
git commit -m "test: should fail"
git push origin main
# Expected: Error - protected branch

# Try to merge PR without approval (should fail)
# Expected: Merge button disabled
```

**4. Verify CODEOWNERS:**
- Make PR changing CLAUDE.md
- Verify code owner automatically requested for review

**5. Test Documentation Validation:**
- Make PR with broken markdown
- Make PR with broken links
- Verify validation catches issues

### Post-Launch Monitoring

**Weekly:**
- Review open PRs
- Check Actions usage/costs
- Review Dependabot alerts
- Update documentation as needed

**Monthly:**
- Review branch protection effectiveness
- Check repository insights
- Update workflows if needed
- Review security alerts

---

## Troubleshooting

### Workflow Not Running

**Problem:** PR created but no workflows trigger

**Solutions:**
```bash
# 1. Check workflow file location
ls -la .github/workflows/

# 2. Validate YAML syntax
yamllint .github/workflows/pr-validation.yml

# 3. Check workflow is enabled
gh workflow list

# 4. View workflow runs
gh run list

# 5. Check repository settings
# Settings > Actions > General > Workflow permissions
```

### Status Checks Not Required

**Problem:** Can merge PR without status checks passing

**Solution:**
1. Go to: Settings > Branches > main
2. Edit branch protection rule
3. Under "Require status checks to pass"
4. Search for and add each check:
   - Documentation Validation
   - Markdown Linting
   - Link Validation
   - Repository Size Check
5. Save changes

### Branch Protection Not Working

**Problem:** Can push directly to main

**Solutions:**
```bash
# 1. Verify protection is enabled
gh api repos/dahendel/local-claude/branches/main/protection

# 2. Check your permissions
gh api repos/dahendel/local-claude/collaborators/YOUR-USERNAME/permission

# 3. Verify "Do not allow bypassing" is enabled
# Settings > Branches > main > check this option
```

### CODEOWNERS Not Working

**Problem:** Code owners not automatically requested for review

**Solutions:**
```bash
# 1. Check file location and name
ls -la .github/CODEOWNERS

# 2. Verify syntax
cat .github/CODEOWNERS

# 3. Ensure CODEOWNERS review is required
# Settings > Branches > main > "Require review from Code Owners"
```

---

## Maintenance

### Regular Tasks

**Daily (if actively developed):**
- Review new PRs
- Respond to issues
- Monitor Actions runs

**Weekly:**
- Review Dependabot PRs
- Check security alerts
- Update documentation
- Review open issues

**Monthly:**
- Review branch protection rules
- Check Actions usage/costs
- Update workflows if needed
- Archive old issues

**Quarterly:**
- Review overall repository health
- Update CONTRIBUTING.md
- Refresh documentation
- Review and update security settings

### Updating Workflows

When modifying workflows:

```bash
# 1. Create feature branch
git checkout -b update/workflow-improvements

# 2. Edit workflow
nano .github/workflows/pr-validation.yml

# 3. Test locally if possible (using act)
act pull_request

# 4. Commit and push
git add .github/workflows/
git commit -m "ci: improve documentation validation"
git push origin update/workflow-improvements

# 5. Create PR and test
gh pr create --fill
```

### Updating Branch Protection

```bash
# Re-run setup script to update rules
.github/scripts/setup-branch-protection.sh dahendel local-claude main

# Or update manually via web interface
```

---

## Best Practices

### Repository Management

1. **Keep main stable** - All changes via PRs
2. **Document everything** - Clear commit messages and docs
3. **Review thoroughly** - Don't rush reviews
4. **Test before merging** - Run all checks locally
5. **Communicate clearly** - Use issues and discussions

### Workflow Management

1. **Keep workflows fast** - Optimize job execution
2. **Cache dependencies** - Use caching actions
3. **Fail fast** - Stop on first error
4. **Provide clear feedback** - Good error messages
5. **Monitor costs** - GitHub Actions has usage limits

### Security

1. **Never commit secrets** - Use GitHub Secrets
2. **Keep dependencies updated** - Enable Dependabot
3. **Review security alerts** - Act quickly
4. **Limit permissions** - Principle of least privilege
5. **Enable 2FA** - For all collaborators

---

## Resources

### GitHub Documentation

- [Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions](https://docs.github.com/en/actions)
- [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [Security Features](https://docs.github.com/en/code-security)

### Tools

- [GitHub CLI](https://cli.github.com/)
- [act](https://github.com/nektos/act) - Run GitHub Actions locally
- [pre-commit](https://pre-commit.com/) - Git hooks framework

### Related Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [README.md](README.md) - Project overview
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Implementation status

---

## Summary

**Repository setup includes:**

- ✅ GitHub Actions for automated validation
- ✅ Branch protection rules on main
- ✅ Code owners for review automation
- ✅ Security features enabled
- ✅ Issue and PR templates
- ✅ Comprehensive documentation
- ✅ Automated dependency updates
- ✅ Clear contribution guidelines

**Next steps:**

1. Initialize local git repository
2. Push to GitHub
3. Run branch protection setup script
4. Enable security features
5. Create test PR to verify workflows
6. Start collaborating!

---

**Questions?** See [CONTRIBUTING.md](CONTRIBUTING.md) or open a discussion on GitHub.

**Last Updated:** 2025-10-24
