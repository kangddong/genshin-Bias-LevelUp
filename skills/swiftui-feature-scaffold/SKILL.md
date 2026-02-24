---
name: swiftui-feature-scaffold
description: Scaffold SwiftUI feature modules using MVVM in this repository's structure (Features/, Domain/, Tests/) with predictable file layout and test stubs.
---

# SwiftUI Feature Scaffold

Use this skill when adding a new feature screen.

## Output Layout
- `Features/<Feature>/<Feature>View.swift`
- `Features/<Feature>/<Feature>ViewModel.swift`
- `Tests/Unit/<Feature>ViewModelTests.swift`

## Rules
- UI state updates on `@MainActor`.
- Business rules live in `Domain/Services` or protocols.
- ViewModel depends on protocol abstractions, not concrete data classes.
- Include at least one unit test for state transition.

## How to Use Templates
Copy templates from `assets/templates/` and replace `__FEATURE__` tokens.
