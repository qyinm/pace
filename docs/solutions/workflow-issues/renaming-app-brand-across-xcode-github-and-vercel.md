---
title: Coordinating the Pace rename across app, repo, and hosting
date: 2026-06-27
category: docs/solutions/workflow-issues
module: branding
problem_type: workflow_issue
component: development_workflow
severity: medium
applies_when:
  - "A product rename touches Xcode targets, release artifacts, landing-page metadata, and hosting in one pass"
symptoms:
  - "App, package, landing page, and release assets drift onto different names during a rename"
  - "Public metadata moves to the new brand before downloads and production domains are actually ready"
root_cause: missing_workflow_step
resolution_type: workflow_improvement
tags:
  - branding-rename
  - xcode
  - github
  - vercel
  - sparkle
  - landingpage
---

# Coordinating the Pace rename across app, repo, and hosting

## Context

The `rytmo` to `Pace` rename crossed native app code, package metadata, release automation, the marketing site, GitHub, and Vercel. Treating those as separate cleanups leaves the project in a partially renamed state where the code says one thing, the repo says another, and user-facing URLs still serve the old brand.

## Guidance

Do the rename as one coordinated pass, then record any external dependencies that cannot be completed inside the repo.

1. Rename the native product surface first: app directory, Xcode project, scheme, target, entitlements, tests, and Swift package target names.
2. Centralize web-facing brand constants so metadata, download URLs, and screenshots do not drift across multiple files.
3. Rename repository and deployment resources deliberately, but keep their operational slugs separate from the product name when availability forces it.
4. Audit release artifacts after the text rename. Sparkle feeds and DMG links are part of the rename, not follow-up polish.
5. Leave an explicit note when a canonical domain or downloadable artifact is not yet provisioned.

The useful pattern on the landing page was to move repeated brand strings into one file:

```ts
export const SITE_NAME = "Pace"
export const SITE_URL = "https://pace.app"
export const DOWNLOAD_URL = "https://qyinm.github.io/pace/sparkle/Pace.dmg"
export const SCREENSHOT_PATH = "/pace-screenshot.svg"
```

That keeps page metadata, OG images, sitemap/robots output, and CTA links aligned while the rename is in flight.

On the native side, the rename is only complete when the build graph agrees:

```swift
let package = Package(
    name: "Pace",
    products: [
        .executable(name: "Pace", targets: ["Pace"])
    ]
)
```

## Why This Matters

Brand renames fail at the seams between systems, not inside one file. This run left two concrete examples:

- `sparkle/appcast.xml` now advertises `Pace-1.0.8-17.zip`, but the repository still only contains `rytmo-*.zip` artifacts and `Rytmo.dmg`.
- Landing-page metadata now points to `https://pace.app`, but the live Vercel setup still resolves through `usepace` and the working alias is `https://pace-qusseun.vercel.app` because `pace.vercel.app` was unavailable.

Without writing those gaps down, the rename looks finished in code review while updates and downloads are still broken for users.

## When to Apply

- When product naming changes across native app code and a separate marketing or docs site
- When repo slug, deployment project name, and canonical domain may differ
- When release automation publishes filenames or URLs derived from the app name
- When a rename includes external systems that cannot be atomically updated with source code

## Examples

Before:

- `rytmo.xcodeproj`, `rytmo/`, `rytmoTests/`, and landing-page assets mixed product identity with deployment-specific naming.
- Brand strings such as app name, URL, screenshot path, and download path were repeated across site metadata files.
- External rollout state was implicit, so stale Sparkle artifacts and unavailable domains were easy to miss.

After:

- Native project structure moved to `Pace.xcodeproj`, `Pace/`, and `Tests/PaceTests/`.
- Landing-page branding moved into `docs/landingpage/lib/site.ts`.
- GitHub repository was corrected to `qyinm/pace`, while the Vercel project remained `usepace` for operational reasons.
- Remaining rollout blockers were identified explicitly: regenerate Sparkle artifacts under the `Pace` name and provision or attach the final `pace.app` domain before treating metadata as production-ready.

## Related

- No existing `docs/solutions/` entries were present for this area during the rename.
