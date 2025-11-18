<!--
AI / Copilot Operational Instructions
This document defines the authoritative workflow and guardrails for AI-assisted contributions to this repository.
It MUST remain stable, additive, and non-destructive. Do not remove required sections without explicit maintainer approval.
-->

# AI-Assisted Contribution & Workflow Guide

## 1. Purpose

Provide a precise, enforceable, repeatable, and auditable process for AI-assisted or human+AI contributions to `mixlib-authentication`. This includes:

- Structured Jira-driven development (when a Jira ID is provided)
- Branching, testing, coverage expectations (>80%)
- Expeditor + CI integration awareness
- DCO compliance (every commit signed off)
- Safe, incremental, prompt-driven execution with explicit user confirmation
- Guardrails to prevent modification of protected assets or secrets

## 2. Repository Structure (Concise Tree)

```
mixlib-authentication/
  Gemfile                # Ruby gem dependencies (rspec, rake, etc.)
  Rakefile               # RSpec + style tasks (default: spec + style)
  VERSION                # Gem version (bumped by Expeditor)
  mixlib-authentication.gemspec  # Gem specification
  lib/                   # Runtime library source
    mixlib/
      authentication.rb  # Main entrypoint requiring components
      authentication/
        digester.rb                # Digest / hashing utilities
        http_authentication_request.rb # HTTP request canonicalization/signing
        null_logger.rb             # No-op logger implementation
        signatureverification.rb   # Signature verification routines
        signedheaderauth.rb        # Signed header auth logic
        version.rb                 # VERSION constant (synced by Expeditor)
        version.rb                 # (Maintained by update_version.sh)
  spec/                  # RSpec tests
    spec_helper.rb       # RSpec setup (no coverage tool currently)
    mixlib/authentication/*_spec.rb
  .github/
    workflows/           # GitHub Actions CI (lint + unit tests)
      lint.yml           # Cookstyle/Rubocop linting on PR + push (main)
      unit.yml           # Windows + Ruby matrix tests (PR + push master)
    CODEOWNERS           # Review / ownership rules
    ISSUE_TEMPLATE/      # Issue templates (if populated)
    dependabot.yml       # Automated dependency update config
  .expeditor/            # Expeditor automation (versioning & pipelines)
    config.yml           # Post-merge automation: version bump, changelog, build, publish
    verify.pipeline.yml  # Buildkite pipeline definitions for verification
    run_linux_tests.sh   # Linux test bootstrap script (bundler caching)
    run_windows_tests.ps1# Windows test script
    update_version.sh    # Syncs gem version constant after bump
  CHANGELOG.md           # Human-readable change history (Expeditor updates)
  README.md              # Project overview & docs pointer
  LICENSE                # Apache 2.0 (PROTECTED – do not modify)
  NOTICE                 # Legal notices
  CODE_OF_CONDUCT.md     # Delegates to Chef community CoC (PROTECTED)
  CONTRIBUTING.md        # Delegates to Chef central contributor guide
  .rubocop.yml           # Style / lint config (Cookstyle + Rubocop)
  .gitignore             # Git ignore rules
```

## 3. Tooling & Ecosystem

| Aspect | Details |
|--------|---------|
| Language | Ruby (tested against 3.1 & 3.4 in CI) |
| Package Manager | Bundler (`bundle install`) |
| Test Framework | RSpec (rspec-core/expectations/mocks) |
| Style / Lint | Cookstyle (ChefStyle) + Rubocop (`rake style` / GitHub Action) |
| Automation | Expeditor (versioning, changelog, release pipeline) |
| CI | GitHub Actions (`lint`, `unit`) + Buildkite via Expeditor pipeline |
| Coverage | Not currently configured (SimpleCov recommended to ensure/measure >80%) |
| Platforms Tested | Linux (Buildkite & GitHub), Windows (Actions + Expeditor) |

### Suggested Coverage Enablement (If Not Present)

Add early in `spec/spec_helper.rb` (AI MUST request approval before committing if absent):

```ruby
require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter '/spec/'
end
puts "Coverage enabled: #{SimpleCov.coverage_path}"
```

## 4. MCP (Jira) Integration

If a Jira ID is supplied (e.g., `ABC-123`), ALWAYS:

1. Invoke atlassian MCP server to fetch issue:
   - Action Pattern: `atlassian-mcp-server.getJiraIssue(issueIdOrKey=ABC-123)` or equivalent tool invocation.
2. Parse fields: Summary, Description, Acceptance Criteria (AC), Story Points, Linked Issues, Labels.
3. Synthesize a plan block:
   - Design / Intent
   - Impacted Files (create/update/delete; tests to add)
   - Test Strategy (unit / edge cases / negative paths)
   - Risks & Mitigations
   - Coverage Focus (low-coverage areas prioritized)
4. Present plan to user with explicit confirmation prompt: `Continue to implementation? (yes/no)`.
5. Do NOT write code before user approves.

### Standard Output Structure (After Fetch)

```
Jira Issue: ABC-123
Summary: ...
Acceptance Criteria:
  - ...
Linked Issues: ABC-101 (relates), ABC-119 (blocks)
Plan:
  Design: ...
  Impacted Files: [...]
  Test Strategy: [...]
  Edge Cases: [...]
  Risks: [...]
Continue to implementation? (yes/no)
```

## 5. Workflow Overview (Canonical High-Level)

1. Intake & Clarify
2. Analyze Repo / Fetch Jira (if ID provided)
3. Plan Implementation
4. Confirm Plan (must be yes)
5. Implement Incrementally (small cohesive commits)
6. Add/Update Tests (ensure/raise >80% coverage)
7. Lint / Style Fixes
8. Commit (with DCO sign-off, referencing Jira ID if applicable)
9. Push & Open PR (HTML template, risk & coverage summary)
10. Apply Labels (map from Jira / context)

Each major step ends with:

```
Step Summary: <1–3 sentences>
Remaining Checklist:
 - [x] Completed items
 - [ ] Pending items
Continue to next step? (yes/no)
Recommended next prompt: <suggested user instruction>
```

## 6. Detailed Step Instructions

### 6.1 Intake & Clarify

Prompt user: “Please provide a Jira ID (e.g., ABC-123) or a freeform task description.”

### 6.2 Jira Retrieval (If ID Present)

Use MCP call (example placeholder):

```
atlassian-mcp-server.getJiraIssue(issueIdOrKey=ABC-123)
```

Never fabricate acceptance criteria. If missing, flag and request clarification.

### 6.3 Repository Analysis

- Confirm language & frameworks (Ruby/RSpec)
- Identify target files & necessary new specs
- Determine if coverage instrumentation needed

### 6.4 Planning

Produce: Design, Data Flow (if relevant), Impacted Files, New Tests, Edge Cases (nil/empty, invalid signatures, large headers, clock skew), Rollback Strategy.

### 6.5 Branch Creation

Branch naming:

- If Jira: EXACT Jira key (e.g., `ABC-123`)
- Else: concise kebab-case slug (e.g., `add-digest-sha512`)

Commands:

```bash
git checkout -b ABC-123
```

### 6.6 Implementation

Guidelines:

- Small, isolated changes
- Maintain backwards compatibility unless version bump plan approved
- Add TODO comments only with linked issue reference
Protected: Do NOT alter `LICENSE`, `CODE_OF_CONDUCT.md`, `CODEOWNERS`, Expeditor config, or GitHub workflow YAML without explicit approval.

### 6.7 Tests & Coverage

- Place tests in `spec/mixlib/authentication/` matching file naming.
- Ensure negative + boundary cases (empty headers, invalid timestamps, incorrect signature length, algorithm mismatch).
- If coverage <80% (after enabling SimpleCov), identify top uncovered lines and add focused tests.

### 6.8 Lint / Style

```bash
bundle exec rake style
```

Fix offenses; do not disable cops unless justified.

### 6.9 Commit (DCO REQUIRED)

Format:

```
<type>(scope): short imperative summary [ABC-123]

Body explaining rationale, risks, test additions.

Signed-off-by: Full Name <email@example.com>
```

Reject / rewrite any commit lacking sign-off.

### 6.10 Push & PR Creation

```bash
git push -u origin ABC-123
gh pr create --title "feat: support X [ABC-123]" --body "(temp)"
```

Then PATCH the PR body with the HTML template (below). Use `gh pr edit` if needed.

### 6.11 PR Description (HTML Template)

```html
<h2>Summary</h2>
<p>Concise explanation of change.</p>
<h2>Jira</h2>
<p><a href="https://jira.example.com/browse/ABC-123">ABC-123</a></p>
<h2>Changes</h2>
<ul><li>List of key modifications</li></ul>
<h2>Tests & Coverage</h2>
<p>Added X specs; coverage Δ: +2.3% (now 84.1%).</p>
<h2>Risk & Mitigations</h2>
<p>Risk: ... Mitigation: ...</p>
<h2>DCO</h2>
<p>All commits signed off.</p>
```

### 6.12 Labels

Apply functional + aspect + Expeditor bump labels (if version semantics needed). See Label Reference.

### 6.13 Idempotency & Resume

If branch already exists: fetch + checkout. If PR exists: update in-place. Never duplicate PR.

### 6.14 Post-PR Iteration

On feedback: amend or follow-up commits (still DCO-signed). Keep commits logically grouped.

## 7. Branching & PR Standards

| Topic | Rule |
|-------|------|
| Branch Name | EXACT Jira ID or descriptive slug |
| Draft PR | Use while tests incomplete or coverage <80% |
| Ready PR | All tests passing, coverage verified, lint clean |
| Status Checks | `lint`, `unit` (matrix), Expeditor verify pipeline (Buildkite) |
| Labels | Add aspect + platform + Expeditor bump (if needed) |

## 8. Commit & DCO Policy

MANDATORY: Final line of every commit message:

```
Signed-off-by: Full Name <email@domain>
```

AI MUST refuse to generate unsigned commits. If contributor email unknown, request it first. No automation may strip the sign-off.

## 9. Testing & Coverage Enforcement

Commands:

```bash
bundle install
bundle exec rake spec     # runs rspec suite
```

If coverage instrumentation added:

```bash
bundle exec rspec
open coverage/index.html  # manual review (macOS)
```

Coverage Policy:

1. Target >= 80% line & branch coverage.
2. If below threshold: list worst-offending files (lowest %), propose added examples.
3. Re-run until threshold passed.

Edge Case Checklist (Authentication Logic):

- Expired timestamp (clock skew)
- Incorrect digest algorithm specified
- Missing required header(s)
- Malformed signature (length/charset)
- Replay attempt (same nonce/timestamp if applicable)

## 10. Labels Reference

Core Mapping Guidance:

- bug/fix → Implementation defect
- enhancement/feature → New capability
- documentation → Docs-only change
- chore/maintenance → Non-functional upkeep
- test → Test-only improvements
- ci → CI / pipeline modifications
- security → Security relevant change

Repository Labels (Name → Description):

```
Aspect: Documentation        - How do we use this project?
Aspect: Integration          - Works correctly with other projects or systems.
Aspect: Packaging            - Distribution of artifacts.
Aspect: Performance          - System performance concerns.
Aspect: Portability          - Platform portability concern.
Aspect: Security             - Security / exposure / confidentiality.
Aspect: Stability            - Consistency & reliability.
Aspect: Testing              - Coverage / CI quality.
Aspect: UI                   - Interface presentation.
Aspect: UX                   - User experience.
dependencies                 - Dependency file update.
Expeditor: Bump Version Major - Triggers major version bump.
Expeditor: Bump Version Minor - Triggers minor version bump.
Expeditor: Skip All          - Skip all Expeditor merge actions.
Expeditor: Skip Changelog    - Do not update changelog.
Expeditor: Skip Habitat      - Skip habitat build.
Expeditor: Skip Omnibus      - Skip omnibus release build.
Expeditor: Skip Version Bump - Prevent automatic version bump.
hacktoberfest-accepted       - Hacktoberfest participation.
oss-standards                - OSS repository standardization.
Platform: AWS                - AWS platform relevance.
Platform: Azure              - Azure platform relevance.
Platform: Debian-like        - Debian derivatives.
Platform: Docker             - Docker/container context.
Platform: GCP                - GCP platform relevance.
Platform: Linux              - General Linux applicability.
Platform: macOS              - macOS applicability.
Platform: RHEL-like          - RHEL family.
Platform: SLES-like          - SUSE family.
Platform: Unix-like          - Generic Unix compatibility.
```

## 11. CI / Expeditor Integration

### GitHub Actions Workflows

1. `lint.yml`
   - Triggers: `pull_request`, `push` to `main`
   - Purpose: Cookstyle/Rubocop style validation.
2. `unit.yml`
   - Triggers: `pull_request`, `push` to `master`
   - Matrix: Windows Server (2019, 2022) × Ruby (3.1, 3.4)
   - Purpose: Unit test validation across environments.

### Expeditor (`.expeditor/config.yml`)

On PR merge into release branch:

1. Version bump (unless skipped by label)
2. Update `VERSION` file & propagate to `lib/mixlib/authentication/version.rb`
3. Update CHANGELOG (unless skipped)
4. Build gem (if version bumped)
Promoted pipeline triggers publish to RubyGems.

### Buildkite Pipeline (`verify.pipeline.yml`)

- Parallel steps for Ruby versions & platforms (Linux & Windows) using container executors.
- Bundler caching to `vendor/bundle`.

## 12. Security & Protected Files

NEVER modify without explicit maintainer instruction:

- `LICENSE`
- `CODE_OF_CONDUCT.md`
- `.github/CODEOWNERS`
- Expeditor config (`.expeditor/`)
- GitHub workflow YAML (`.github/workflows/*.yml`)
- Release automation scripts
- Any secret / credential / token references

Disallowed actions:

- Writing plaintext secrets
- Force-pushing to default branch (`master` or `main`)
- Merging PRs
- Adding large (>1MB) binary blobs

## 13. Prompts Pattern (Interaction Model)

Every major step output MUST include:

```
Step Summary: <short>
Remaining Steps:
 - [x] Step 1 Intake & Clarify
 - [ ] Step 2 Plan ...
Continue to next step? (yes/no)
Recommended next prompt: "Proceed to <next-step> with focus on <key element>."
```

No implicit progression: always wait for explicit `yes`.

## 14. Environment Preparation

Prerequisites: Ruby 3.1+ (or 3.4), Bundler, Git, GitHub CLI (`gh`).

```bash
git clone https://github.com/chef/mixlib-authentication.git
cd mixlib-authentication
bundle install
bundle exec rake spec
bundle exec rake style
```

Optional (enable coverage): add SimpleCov (see Section 3) and re-run tests.

## 15. Idempotency & Recovery

- If branch exists locally: `git checkout <branch>`
- If remote only: `git fetch origin && git checkout <branch>`
- If PR exists: update via additional commits; do not recreate
- If coverage instrumentation added previously: respect existing config; do not duplicate

## 16. Failure Handling

| Failure Type | Response |
|--------------|----------|
| Test failing | Identify spec/file; propose fix; re-run selectively |
| Lint failing | Auto-correct if safe (`cookstyle -A`), else manual patch |
| Coverage low | Highlight uncovered lines; propose targeted specs |
| Merge conflict | Present diff hunk-by-hunk; propose resolution; request confirmation |
| Jira fetch error | Ask for re-validation of ID or alternate task description |

## 17. Validation & Exit Criteria

Completion requires ALL:

1. Plan approved by user.
2. Code changes implemented & tests added/updated.
3. Lint passes locally & in CI.
4. Coverage >= 80% (if measurable; else instrumentation guidance provided + user acknowledgment).
5. Commits DCO-signed.
6. PR opened with HTML template filled.
7. Appropriate labels applied.
8. Risk assessment documented.
9. User confirms closure: `Task complete? (yes/no)`.

## 18. Safeguards Summary

- Do not introduce secrets.
- Do not disable tests or lower thresholds silently.
- Do not remove license headers.
- Always prompt before destructive or sweeping changes.

## 19. Quick Reference Commands

```bash
# Create branch
git checkout -b ABC-123

# Install deps
bundle install

# Run tests & style
bundle exec rake spec
bundle exec rake style

# Commit (DCO)
git add .
git commit -m "feat(auth): improve signature parsing [ABC-123]" -m "Signed-off-by: Full Name <email@example.com>"

# Push & PR
git push -u origin ABC-123
gh pr create --title "feat: improve signature parsing [ABC-123]" --body "<temp>"
```

## 20. Example Interaction Transcript (Pattern)

```
User: Implement support for HMAC-SHA512 (Jira SEC-42)
AI: Fetches SEC-42, outputs plan with impacted files, test matrix, asks: Continue? (yes/no)
User: yes
AI: Creates branch SEC-42, adds minimal code scaffold, proposes tests, asks to proceed.
...
AI: PR created #123 with coverage 82.4%, labels applied. Continue to finalize? (yes/no)
```

---

## 21. AI-Assisted Development & Compliance

- ✅ Create PR with `ai-assisted` label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
- ✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description

### Jira Ticket Updates (MANDATORY)

- ✅ **IMMEDIATELY after PR creation**: Update Jira ticket custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
- ✅ Use atlassian-mcp tools to update the Jira field programmatically
- ✅ **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`
- ✅ Verify the field update was successful

### Documentation Requirements

- ✅ Reference AI assistance in commit messages where appropriate
- ✅ Document any AI-generated code patterns or approaches in PR description
- ✅ Maintain transparency about which parts were AI-assisted vs manual implementation

### Workflow Integration

This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

```
Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes WITH SIGNED-OFF COMMITS
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes"
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
```

- **Never skip Jira field updates** - This is required for Progress AI governance
- **Always verify updates succeeded** - Check response from atlassian-mcp tools
- **Treat as atomic operation** - PR creation and Jira updates should happen together
- **Double-check before final summary** - Confirm all AI compliance items are completed

### Audit Trail

All AI-assisted work must be traceable through:

1. GitHub PR labels (`ai-assisted`)
2. Jira custom field (`customfield_11170` = "Yes")
3. PR descriptions mentioning AI assistance
4. Commit messages where relevant

---

This document is living; propose additive improvements via PR (following all policies above). Avoid deletions or semantic weakening of guardrails.
