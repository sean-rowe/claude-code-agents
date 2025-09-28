# Deploy Command

## What It Does
Deploys code to production.

## Usage
`/deploy`

## Steps
1. Pre-flight checks
2. Build and test
3. Deploy

## Implementation
Use the deployer agent:
```javascript
await Task({
  subagent_type: "general-purpose",
  description: "Deployment",
  prompt: "Use deployer agent to deploy to production"
});
```

## Output
```
[1/3] Pre-flight checks: ✓ Ready
[2/3] Build and test: ✓ Pass
[3/3] Deploying: ✓ Complete

✓ Deployment successful
```