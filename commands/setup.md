# Setup Command

## What It Does
Sets up project tracking and configuration.

## Usage
`/setup`

## Steps
1. Create .env file with PROJECT_KEY
2. Setup tracking (JIRA/GitHub/Manual)
3. Verify configuration

## Implementation
```bash
# Create .env if missing
[ -f .env ] || echo "PROJECT_KEY=$(basename $PWD | tr '[:lower:]' '[:upper:]')" > .env
source .env

# Setup based on available tools
if command -v acli &>/dev/null; then
  echo "✓ Using JIRA for tracking"
elif command -v gh &>/dev/null; then
  echo "✓ Using GitHub Issues"
else
  echo "✓ Using manual tracking"
fi

echo "✓ Project $PROJECT_KEY configured"
```

## Output
```
✓ Project MYAPP configured
```