---
description: Set up or audit branch-based staging deployments without disrupting production
---
Set up or audit this project's production-like staging environment. If staging already exists, verify that it works and follows the conventions below, then correct gaps rather than recreate working resources. Changes to `staging` should deploy automatically to staging; changes to `main` should deploy automatically to production. Preserve existing production behavior and keep `main` as GitHub's default branch.

## Inspect and confirm

Inspect the repository, deployment configuration, and existing environments. Identify what already complies, what is broken or unverified, and what needs changing. Reuse working resources and credentials; leave compliant configuration unchanged. Identify the deployment owners, services, credentials, and automation affected by any changes. Briefly confirm these decisions with the user before implementation:

- For Convex, whether Vercel or GitHub Actions should deploy it. Recommend Vercel when the Convex backend belongs to the Vercel application and is included in its deployment source; otherwise recommend GitHub Actions.
- For each external service, whether staging should use a sandbox, separate real credentials, or shared production credentials. Prefer sandbox instances where available; read-only integrations may share production access, while paid services such as OpenRouter may warrant separate, limited credentials. Use WorkOS's staging environment when applicable.

Keep staging feature-complete rather than replacing integrations with mocks or disabling features.

## Implement

Use available authenticated CLIs and APIs to create and configure staging resources, deployment settings, secrets, and GitHub automation. This request authorizes those staging setup changes and a staging deployment, subject to the confirmed decisions and applicable permission rules. Ask if access or authorization is missing.

Create `staging` from `main` if absent, preserving it if it already exists. Keep the normal PR flow as feature branch → `staging` → `main`, without enforcing hotfix policy. Organization branch protections are already managed; leave them unchanged and respect them when delivering repository changes. Promotion to `main` and triggering production deployments are outside scope.

For Vercel, restrict Git-triggered deployments to `main` and `staging`, merging this into existing `vercel.json` settings:

```json
{
  "git": {
    "deploymentEnabled": {
      "**": false,
      "main": true,
      "staging": true
    }
  }
}
```

For Convex, create a development deployment named `staging` if absent. Configure the chosen deployment mechanism to target the correct backend for each branch. When Vercel owns deployment, adapt this build command to the project's package manager, build script, and frontend URL variable:

```json
{
  "buildCommand": "bunx convex deploy --cmd-url-env-var-name VITE_CONVEX_URL --cmd \"bun run build\""
}
```

Scope staging credentials and environment variables to staging, not arbitrary previews or production. Generate application-owned secrets when appropriate and reuse existing deployment credentials only as agreed. Never invent credentials or obtain API keys by accessing third-party integration services. Ask the user to obtain those when needed. Keep secret values out of repository files and output.

Retain production's security model. Do not add staging-only passwords or authentication by default. Inspect actual platform protections and existing Convex authorization; intentionally public routes may remain public. Raise concrete additional risks with the user rather than silently adding restrictions.

Avoid production impact. If any required change would affect live production, explain its impact and the smallest viable change, then obtain explicit approval before proceeding.

## Verify and hand off

Create or rewrite `docs/deployment.md` with a very brief, direct explanation of how deployment is set up: the branch/PR flow, what triggers and runs each environment's deployment, and how services and environment configuration connect. Describe the current setup, not setup instructions or migration history, and omit secret values.

Run relevant project checks and verify an actual staging deployment, deploying changes when needed. Verify branch targeting, frontend/backend connections, and configured integrations without modifying production data. Distinguish verified behavior from configuration-only checks.

Report the staging URL, what already complied, what changed, what was verified, and any blockers. For credentials or manual steps you cannot complete, state exactly what the user must obtain, where it must be configured, and how to finish deployment. Mark incomplete deployment or verification explicitly.
