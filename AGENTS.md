# Repository Guidelines

## Project Structure & Module Organization
- `App/`: app entry, root tab, shared app state (`AppStore`).
- `Features/`: SwiftUI feature screens (`Characters`, `Days`, `Settings`) and reusable UI (`Features/Common`).
- `Domain/`: pure models, protocols, and business services (filtering, weekday mapping, payload building).
- `Data/`: concrete implementations for bundle JSON loading, UserDefaults storage, local notification scheduling.
- `Resources/Data/`: bundled game data (`characters.json`, `weapons.json`, `schedules.json`).
- `Tests/Unit/`, `Tests/UI/`: XCTest unit/UI tests.
- `skills/`: local Codex skills used for repetitive project workflows.

## Build, Test, and Development Commands
- `xcodegen generate`: regenerate `MyBiasLevelUp.xcodeproj` from `project.yml`.
- `xcodebuild -project MyBiasLevelUp.xcodeproj -scheme MyBiasLevelUp -destination "platform=iOS Simulator,name=iPhone 16" build`: local build.
- `xcodebuild -project MyBiasLevelUp.xcodeproj -scheme MyBiasLevelUp -destination "platform=iOS Simulator,name=iPhone 16" test`: run unit/UI tests.
- `rg -n "pattern" App Features Domain Data Tests`: fast code search.

## Coding Style & Naming Conventions
- Swift 6 + Swift Concurrency (`async/await`, `Task`, `actor`) for async work.
- Follow Swift API Design Guidelines and keep UI state on `@MainActor`.
- Types: `PascalCase`; functions/properties: `camelCase`; constants: `lowerCamelCase` unless static semantic constants.
- Keep views thin; move non-UI logic to `Domain/Services`.

## Testing Guidelines
- Framework: XCTest.
- Test naming: `test_given_when_then` or behavior-focused names.
- Add unit tests for timezone/day mapping, filtering, persistence, notification content generation.
- For UI-impacting changes, add/update UI tests and include simulator evidence in PR.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `chore:`.
- One logical change per commit; reference issue/ticket in commit or PR body.
- PR must include: summary, why, test evidence (`xcodebuild ... test`), and screenshots for UI changes.

## Security & Configuration Tips
- Do not commit secrets, tokens, or APNs keys.
- Keep MVP notification flow local-only (`UNUserNotificationCenter`) unless backend is explicitly introduced.
- Validate JSON data changes with `skills/genshin-data-curator/scripts/validate_genshin_json.py` before merge.

## Agent-Specific Instructions
- Default to non-destructive edits and avoid unrelated refactors.
- When changing async flows, document actor/MainActor boundaries in code.
- If adding new 반복 workflows, prefer creating/updating a skill under `skills/`.
