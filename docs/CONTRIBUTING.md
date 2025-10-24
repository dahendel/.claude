# Contributing to Claude Environment Optimization

Thank you for your interest in contributing to the Claude Environment Optimization project! This guide will help you understand our development process and standards.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Pull Request Process](#pull-request-process)
5. [Documentation Standards](#documentation-standards)
6. [Commit Message Guidelines](#commit-message-guidelines)
7. [Testing Requirements](#testing-requirements)
8. [Branch Protection Rules](#branch-protection-rules)

---

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow:

- Be respectful and inclusive
- Focus on constructive feedback
- Assume good intentions
- Keep discussions professional
- Report inappropriate behavior

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

```bash
# Required tools
git --version           # Git 2.0+
python3 --version       # Python 3.10+
docker --version        # Docker 20.0+

# Optional but recommended
pre-commit --version    # For commit hooks
```

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork:**

```bash
git clone git@github.com:YOUR-USERNAME/local-claude.git
cd local-claude
```

3. **Add upstream remote:**

```bash
git remote add upstream git@github.com:dahendel/local-claude.git
git fetch upstream
```

4. **Create a feature branch:**

```bash
git checkout -b feature/your-feature-name
```

---

## Development Workflow

### 1. Sync with Upstream

Always start with the latest code:

```bash
git checkout main
git pull upstream main
git push origin main
```

### 2. Create Feature Branch

Use descriptive branch names:

```bash
# Good examples:
git checkout -b feature/add-docker-logging
git checkout -b fix/markdown-lint-errors
git checkout -b docs/update-quick-start

# Branch naming convention:
# - feature/ - New features
# - fix/ - Bug fixes
# - docs/ - Documentation only
# - refactor/ - Code refactoring
# - test/ - Test additions/changes
# - chore/ - Maintenance tasks
```

### 3. Make Changes

- Keep commits focused and atomic
- Test your changes locally
- Update documentation as needed
- Follow coding standards

### 4. Commit Changes

Use conventional commits:

```bash
git add .
git commit -m "feat: add Docker health check script

- Implement health check for all services
- Add retry logic with exponential backoff
- Update documentation with usage examples

Closes #123"
```

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Pull Request Process

### Before Submitting

**Checklist:**

- [ ] Code follows project style guidelines
- [ ] All tests pass locally
- [ ] Documentation is updated
- [ ] Commit messages follow conventions
- [ ] Branch is up-to-date with main
- [ ] No merge conflicts
- [ ] PR description is complete

### PR Template

Your PR should include:

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Related Issues
Fixes #123, Relates to #456

## Testing Done
- [ ] Tested locally
- [ ] Added new tests
- [ ] All existing tests pass

## Documentation Updated
- [ ] README.md
- [ ] CLAUDE.md
- [ ] Implementation guides
- [ ] API documentation

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where needed
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective
- [ ] New and existing tests pass locally
```

### Automated Checks

Your PR will automatically run:

1. **Documentation Validation**
   - Checks for broken links
   - Validates markdown formatting
   - Verifies code blocks are closed
   - Checks for TODO items
   - Validates internal references

2. **Markdown Linting**
   - Enforces consistent formatting
   - Checks heading structure
   - Validates list formatting
   - Ensures proper spacing

3. **Link Validation**
   - Verifies all external links
   - Checks internal document links
   - Reports broken references

4. **Size Check**
   - Monitors repository size
   - Flags large files
   - Tracks documentation growth

### Review Process

1. **Automated checks must pass** before review
2. **At least 1 reviewer approval** required
3. **Maintainer review** for significant changes
4. **All conversations resolved** before merge

### After Approval

Once approved:

- **Squash and merge** for feature branches
- **Rebase and merge** for bug fixes
- **Merge commit** for release branches

---

## Documentation Standards

### File Organization

```
project-root/
├── README.md                    # Project overview
├── CLAUDE.md                    # Claude-specific context
├── EXECUTIVE_SUMMARY.md         # High-level overview
├── IMPLEMENTATION_STATUS.md     # Current status
├── QUICK_START_IMPLEMENTATION_GUIDE.md
├── QUICK_REFERENCE_CARD.md
└── CONTRIBUTING.md              # This file
```

### Documentation Requirements

**Every PR with code changes must:**

1. Update relevant documentation files
2. Add examples for new features
3. Update IMPLEMENTATION_STATUS.md if needed
4. Include inline code comments

**Documentation should:**

- Be clear and concise
- Include code examples
- Provide context and rationale
- Use proper markdown formatting
- Include links to related docs

### Markdown Style Guide

**Headings:**
```markdown
# H1 - Document Title Only
## H2 - Major Sections
### H3 - Subsections
#### H4 - Details

Never skip heading levels!
```

**Code Blocks:**
```markdown
Use triple backticks with language:

```bash
# Shell commands
echo "Hello World"
```

```python
# Python code
def hello():
    print("Hello World")
```
```

**Lists:**
```markdown
Unordered lists:
- Item 1
- Item 2
  - Nested item (2 spaces indent)

Ordered lists:
1. First item
2. Second item
   1. Nested item (3 spaces indent)
```

**Links:**
```markdown
Internal: [See Quick Start](QUICK_START_IMPLEMENTATION_GUIDE.md)
External: [Anthropic Docs](https://docs.anthropic.com)
```

**Tables:**
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data     | Data     | Data     |
```

**Emphasis:**
```markdown
**Bold** for important terms
*Italic* for emphasis
`Code` for inline code
```

### Status Markers

Use consistent status markers:

```markdown
✅ Complete / Success / Passed
⚠️ Warning / In Progress / Attention
❌ Failed / Incomplete / Error
ℹ️ Information / Note
🔄 In Progress / Updating
📝 Documentation Required
🧪 Testing
```

### Code Examples

**Good Example:**
```bash
# Check system health
claude health

# Expected output:
# ╔══════════════════════════════════════╗
# ║  Claude Environment Health Report    ║
# ╚══════════════════════════════════════╝
# Status: ✅ Healthy
```

**Include:**
- Command being run
- Expected output
- Error handling
- Context/prerequisites

---

## Commit Message Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Formatting, missing semicolons, etc
- **refactor**: Code restructuring
- **perf**: Performance improvement
- **test**: Adding tests
- **chore**: Maintenance tasks
- **ci**: CI/CD changes

### Examples

**Feature:**
```
feat(docker): add health check for vector database

- Implement health check with retry logic
- Add timeout configuration
- Update docker-compose.yml
- Document health check usage

Closes #123
```

**Bug Fix:**
```
fix(git-sync): handle merge conflicts gracefully

- Add conflict detection before pull
- Implement automatic rebase strategy
- Log conflict details for debugging
- Update error messages

Fixes #456
```

**Documentation:**
```
docs(readme): update installation instructions

- Add prerequisites section
- Clarify Docker requirements
- Update command examples
- Fix broken links

Related to #789
```

### Best Practices

- Use imperative mood ("add" not "added")
- Capitalize first letter
- No period at end of subject
- Subject line ≤ 50 characters
- Body lines ≤ 72 characters
- Separate subject and body with blank line
- Explain *what* and *why*, not *how*

---

## Testing Requirements

### Documentation Testing

Before submitting PR:

```bash
# Check markdown formatting
markdownlint '**/*.md'

# Check links
markdown-link-check README.md

# Validate code blocks
# (Manual check that all ``` are closed)

# Check for TODO items
grep -r "TODO\|FIXME" *.md
```

### Script Testing

For script changes:

```bash
# Bash scripts
shellcheck script.sh
bash -n script.sh  # Syntax check

# Python scripts
python3 -m py_compile script.py
pylint script.py
```

### Integration Testing

Test complete workflows:

```bash
# Test backup workflow
claude backup "test backup"
claude restore

# Test git sync
claude git-sync test

# Test docker services
claude start
claude test
claude stop
```

### Manual Testing

Always test:

1. Happy path scenarios
2. Error conditions
3. Edge cases
4. Cross-platform compatibility (if applicable)

---

## Branch Protection Rules

### Main Branch

**Required:**
- ✅ Require pull request reviews (1 approval)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Require conversation resolution
- ✅ Do not allow bypassing the above settings

**Status Checks Required:**
- Documentation Validation
- Markdown Linting
- Link Validation
- Size Check

**Restrictions:**
- Dismiss stale pull request approvals
- Require review from Code Owners (if applicable)
- No force pushes
- No deletions

### Develop Branch (Optional)

If using develop branch:

- Same rules as main
- Can merge to main via PR only
- Use for integration testing

---

## Code Review Guidelines

### For Reviewers

**Review Checklist:**

- [ ] Code is readable and maintainable
- [ ] Documentation is clear and complete
- [ ] Tests are adequate
- [ ] No security vulnerabilities
- [ ] Performance is acceptable
- [ ] Error handling is robust
- [ ] Style guidelines followed

**Providing Feedback:**

- Be constructive and specific
- Explain the "why" behind suggestions
- Distinguish between:
  - 🔴 **Must fix**: Blocks approval
  - 🟡 **Should fix**: Strong recommendation
  - 🟢 **Consider**: Optional improvement
- Approve when satisfied (don't nitpick)

### For Authors

**Responding to Reviews:**

- Thank reviewers for their time
- Address all feedback
- Mark conversations as resolved
- Update PR description if scope changes
- Re-request review after changes

---

## Release Process

### Version Numbering

We use Semantic Versioning (SemVer):

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality, backwards compatible
- **PATCH**: Backwards compatible bug fixes

Example: `v1.2.3`

### Release Checklist

Before creating a release:

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers incremented
- [ ] Git tag created
- [ ] Release notes written

---

## Getting Help

### Resources

- **Documentation**: Read the guides in `~/.claude/docs/`
- **Issues**: Search existing issues on GitHub
- **Discussions**: Use GitHub Discussions for questions

### Asking Questions

When asking for help:

1. Search existing issues/discussions first
2. Provide context and details
3. Include error messages and logs
4. Describe what you've tried
5. Share relevant configuration

### Reporting Bugs

Use the bug report template:

```markdown
**Description**
Clear description of the bug

**Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- OS: Ubuntu 22.04
- Python: 3.11
- Docker: 20.10.21

**Logs**
```
Paste relevant logs here
```

**Additional Context**
Any other relevant information
```

---

## Recognition

Contributors will be recognized in:

- CHANGELOG.md (for each release)
- README.md (contributors section)
- Git commit history
- Release notes

Thank you for contributing! 🎉

---

**Questions?** Open a discussion on GitHub or contact the maintainers.

**Last Updated:** 2025-10-24
