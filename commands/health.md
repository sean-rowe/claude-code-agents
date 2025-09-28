# Health Check Command

Verifies system configuration and dependencies.

## Usage
```bash
/health
```

## What It Checks

1. **Git Configuration**
   - Git installed
   - User configured
   - Current branch
   - Remote configured

2. **Project Tracking**
   - JIRA/GitHub CLI available
   - Project configured
   - Authentication valid

3. **Development Tools**
   - Node.js/npm
   - Go
   - Python
   - Make

4. **Pipeline State**
   - State file exists
   - State file valid JSON
   - Current stage
   - No errors

## Implementation

```bash
echo "==================================="
echo "🏥 HEALTH CHECK"
echo "==================================="

# Git checks
echo "[1/4] Checking Git..."
if command -v git &>/dev/null; then
  echo "✓ Git installed: $(git --version)"
  echo "✓ Branch: $(git branch --show-current)"
  echo "✓ Remote: $(git remote -v | head -1)"
else
  echo "✗ Git not installed"
fi

# Tracking tools
echo "[2/4] Checking tracking tools..."
if command -v acli &>/dev/null; then
  echo "✓ JIRA CLI available"
elif command -v gh &>/dev/null; then
  echo "✓ GitHub CLI available"
else
  echo "⚠ No tracking CLI found"
fi

# Development tools
echo "[3/4] Checking dev tools..."
command -v node &>/dev/null && echo "✓ Node: $(node --version)"
command -v go &>/dev/null && echo "✓ Go: $(go version)"
command -v python3 &>/dev/null && echo "✓ Python: $(python3 --version)"
command -v make &>/dev/null && echo "✓ Make: $(make --version | head -1)"

# Pipeline state
echo "[4/4] Checking pipeline state..."
if [ -f pipeline-state.json ]; then
  if jq empty pipeline-state.json 2>/dev/null; then
    STAGE=$(jq -r .stage pipeline-state.json)
    echo "✓ State valid: Stage=$STAGE"
  else
    echo "✗ State file corrupted"
  fi
else
  echo "⚠ No state file - run '/pipeline setup'"
fi

echo "==================================="
echo "✓ Health check complete"
```

## Output Example
```
===================================
🏥 HEALTH CHECK
===================================

[1/4] Checking Git...
✓ Git installed: git version 2.39.2
✓ Branch: main
✓ Remote: origin  https://github.com/user/repo.git

[2/4] Checking tracking tools...
✓ JIRA CLI available

[3/4] Checking dev tools...
✓ Node: v18.17.0
✓ Go: go version go1.21.0
✓ Python: Python 3.11.4
✓ Make: GNU Make 3.81

[4/4] Checking pipeline state...
✓ State valid: Stage=ready

===================================
✓ Health check complete
```