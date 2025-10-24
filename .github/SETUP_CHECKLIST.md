# GitHub Repository Setup Checklist

Quick reference checklist for setting up the local-claude repository on GitHub.

---

## Initial Setup

### 1. Repository Creation

- [ ] Create repository on GitHub (public/private)
- [ ] Clone repository locally or add remote
- [ ] Initialize git repository if needed
- [ ] Push initial commit to main branch

```bash
cd ~/projects/local-claude
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:dahendel/local-claude.git
git push -u origin main
```

---

## GitHub Actions Setup

### 2. Workflow Verification

- [ ] Verify workflow files in `.github/workflows/`
- [ ] Check workflow syntax is valid
- [ ] Confirm workflow triggers are correct
- [ ] Test workflow with a test PR

```bash
# Check files
ls -la .github/workflows/

# Create test PR
git checkout -b test/github-actions
echo "Test" >> TEST.md
git add TEST.md
git commit -m "test: verify GitHub Actions"
git push origin test/github-actions
gh pr create --fill
```

Expected workflows:
- `pr-validation.yml` - Main PR validation workflow

---

## Repository Rulesets

### 3. Enable Repository Rulesets

**Option A: Automated Setup (Recommended)**

```bash
.github/scripts/setup-repository-ruleset.sh dahendel local-claude
```

**Option B: Manual Setup**

- [ ] Go to Settings > Rules
- [ ] Click "New ruleset" → "New branch ruleset"
- [ ] Ruleset name: `Main Branch Protection`
- [ ] Enforcement status: Active
- [ ] Target branches: `main`, `develop`
- [ ] Enable required rules (see checklist below)

#### Ruleset Rules Checklist

- [ ] ✅ Require pull request before merging (1 approval)
- [ ] ✅ Dismiss stale pull request approvals
- [ ] ✅ Require review from Code Owners
- [ ] ✅ Require conversation resolution before merging
- [ ] ✅ Require status checks to pass
- [ ] ✅ Require branches to be up to date
- [ ] ✅ Block force pushes
- [ ] ✅ Block branch deletion
- [ ] ✅ Require linear history

#### Required Status Checks

- [ ] Documentation Validation
- [ ] Markdown Linting
- [ ] Link Validation
- [ ] Repository Size Check

---

## Security Configuration

### 4. Enable Security Features

Navigate to: Settings > Security > Code security and analysis

- [ ] ✅ Private vulnerability reporting
- [ ] ✅ Dependency graph
- [ ] ✅ Dependabot alerts
- [ ] ✅ Dependabot security updates
- [ ] ✅ Secret scanning (if available)
- [ ] ✅ Code scanning (if available)

### 5. Create Dependabot Configuration

- [ ] Create `.github/dependabot.yml`
- [ ] Configure update schedule
- [ ] Test Dependabot is working

---

## Repository Settings

### 6. General Settings

Navigate to: Settings > General

#### Features
- [ ] ✅ Wikis (optional)
- [ ] ✅ Issues
- [ ] ✅ Discussions
- [ ] ⚙️ Projects (optional)

#### Pull Requests
- [ ] ✅ Allow squash merging
- [ ] ✅ Allow rebase merging
- [ ] ✅ Automatically delete head branches

### 7. About Section

- [ ] Add description
- [ ] Add website URL (if applicable)
- [ ] Add topics: `claude`, `ai`, `vector-database`, `documentation`, `optimization`

```bash
gh repo edit --add-topic claude
gh repo edit --add-topic ai
gh repo edit --add-topic vector-database
gh repo edit --add-topic documentation
gh repo edit --add-topic optimization
```

---

## Collaboration Setup

### 8. Configure Code Owners

- [ ] Verify `.github/CODEOWNERS` exists
- [ ] Update with correct GitHub usernames
- [ ] Test code owner review requests

### 9. Issue Templates

- [ ] Create bug report template
- [ ] Create feature request template
- [ ] Test template appears when creating issue

### 10. Pull Request Template

- [ ] Verify `.github/pull_request_template.md` exists
- [ ] Test template appears when creating PR

---

## Testing & Verification

### 11. Test Complete Setup

#### Create Test PR

```bash
# 1. Create test branch
git checkout -b test/complete-setup

# 2. Make small change
echo "# Test Complete Setup" >> TEST_SETUP.md
git add TEST_SETUP.md
git commit -m "test: verify complete GitHub setup"

# 3. Push and create PR
git push origin test/complete-setup
gh pr create \
  --title "Test: Complete GitHub Setup Verification" \
  --body "Testing all GitHub configurations"
```

#### Verify Checklist

- [ ] GitHub Actions workflow triggers automatically
- [ ] All 4 jobs run (Documentation, Lint, Links, Size)
- [ ] Status checks appear in PR
- [ ] Bot comments appear with validation results
- [ ] Merge button is disabled until checks pass
- [ ] Code owner automatically requested for review

#### Test Branch Protection

```bash
# Try to push directly to main (should fail)
git checkout main
echo "test" >> README.md
git add README.md
git commit -m "test: should fail"
git push origin main
# Expected: remote: error: GH006: Protected branch update failed
```

- [ ] Direct push to main blocked
- [ ] Cannot merge PR without review
- [ ] Cannot merge PR with failing checks
- [ ] Cannot merge with unresolved conversations

---

## Documentation

### 12. Verify Documentation Complete

- [ ] README.md is clear and complete
- [ ] CONTRIBUTING.md has all guidelines
- [ ] REPOSITORY_SETUP.md has setup instructions
- [ ] IMPLEMENTATION_STATUS.md is up to date
- [ ] All links in documentation work

---

## Post-Setup Tasks

### 13. Initial Configuration

- [ ] Create first release (optional)
- [ ] Setup GitHub Discussions (optional)
- [ ] Add collaborators (if applicable)
- [ ] Configure notifications

### 14. Maintenance Setup

- [ ] Set up issue labels
- [ ] Create milestone for next release
- [ ] Plan first few issues
- [ ] Document workflow in team wiki

---

## Troubleshooting

### Common Issues

**Workflow not triggering:**
- Check workflow file is in `.github/workflows/`
- Verify YAML syntax is valid
- Check repository Actions settings are enabled

**Ruleset not working:**
- Verify ruleset enforcement is "Active"
- Check target branches include your branch
- Confirm you're testing with non-admin account
- Review bypass actors list (should be empty for strict enforcement)

**Status checks not required:**
- Go to ruleset settings
- Edit "Require status checks to pass" rule
- Add status checks by name (must match workflow job names)
- Save ruleset

**CODEOWNERS not working:**
- Check file is in `.github/CODEOWNERS`
- Verify usernames are correct (with @)
- Enable "Require review from Code Owners" in protection

---

## Quick Reference Commands

### Repository Management

```bash
# View repository info
gh repo view

# Edit repository settings
gh repo edit

# Check Actions workflows
gh workflow list

# View recent runs
gh run list

# View repository rulesets
gh api repos/OWNER/REPO/rulesets
```

### Common Operations

```bash
# Create feature branch
git checkout -b feature/name

# Create PR
gh pr create --fill

# View PR checks
gh pr checks

# Merge PR
gh pr merge

# Close and delete branch
gh pr close --delete-branch
```

---

## Completion Checklist

### Phase 1: Basic Setup ✅
- [x] Repository created
- [x] Initial files committed
- [x] Workflows configured
- [x] Documentation created

### Phase 2: Protection & Security ⏳
- [ ] Repository ruleset enabled
- [ ] Security features activated
- [ ] CODEOWNERS configured
- [ ] Templates created

### Phase 3: Testing ⏳
- [ ] Test PR created
- [ ] All checks verified
- [ ] Protection rules tested
- [ ] Documentation reviewed

### Phase 4: Launch 🚀
- [ ] All items above completed
- [ ] First real PR merged
- [ ] Team onboarded (if applicable)
- [ ] Monitoring in place

---

## Success Criteria

Your setup is complete when:

✅ Test PR passes all automated checks
✅ Direct push to main is blocked
✅ Merge requires 1 approval
✅ Status checks are required
✅ Code owners are automatically requested
✅ Security features are enabled
✅ Documentation is complete and accurate

---

## Next Steps

After completing this checklist:

1. **Start Development**
   - Create issues for planned features
   - Begin working on improvements
   - Follow CONTRIBUTING.md guidelines

2. **Invite Collaborators**
   - Share repository link
   - Grant appropriate permissions
   - Orient team on processes

3. **Monitor & Maintain**
   - Review Dependabot PRs weekly
   - Respond to security alerts promptly
   - Update documentation as needed

---

**Need Help?** See [REPOSITORY_SETUP.md](../REPOSITORY_SETUP.md) for detailed instructions.

**Last Updated:** 2025-10-24
