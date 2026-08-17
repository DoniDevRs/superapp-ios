# SuperApp iOS

The iOS implementation of the **Pix Transfer** redesign for SuperApp, a
fictional banking super-app. This repository holds the native app: the
SwiftUI/UIKit code, the local Swift Package modules, and the unit/UI test
suites.

## Overview

This app is a redesign of the Pix (Brazilian instant payment) transfer
journey — going from a fictional legacy flow with 6 screens and 11 fields
down to a streamlined, accessible 3-screen flow (recipient selection,
amount/review, and result).

It was built end-to-end following a **Spec-Driven Development (SDD)**
workflow executed with Claude Code: business requirement → spec → plan →
tasks → implementation → tests → accessibility audit → code review, each
stage producing a reviewable artifact before the next began. The spec, the
full task breakdown, the custom Claude Skills, and the subagents used to
build this app live in the
[`superapp-agentic-workflow`](https://github.com/DoniDevRs/superapp-agentic-workflow)
repository — that's the place to go for the *why* and the *how* behind this
implementation.

## Architecture

The app follows **Clean Architecture + MVVM-C**, split across a multi-module
Swift Package Manager structure:

- **`App`** — the composition root. Bootstraps the app and wires
  `RootCoordinator`, which starts the Pix flow.
- **`Packages/Core`** — cross-feature primitives: networking contracts,
  navigation (`Coordinator` protocol), and shared utilities (e.g., currency
  formatting). No feature-specific logic lives here.
- **`Packages/Pix`** — the Pix Transfer feature, internally layered as
  Domain (entities, use cases, repository protocol) → Data (repository
  implementation) → Presentation (ViewModel, SwiftUI views) → Coordinator.

Navigation is centralized in **`PixCoordinator`** (UIKit), which owns the
`UINavigationController` and decides which screen to push next — views and
the ViewModel never navigate directly, they only communicate intent via
closures. A single **`PixViewModel`** instance is shared across all 3 screens
of the flow (`SelectRecipientView` → `ReviewPaymentView` →
`ConfirmationView`), so state like the selected recipient, amount, and
receipt carries across navigation without manual hand-offs between
per-screen ViewModels.

## Design System

Visual components (buttons, colors, typography, cards) come from
[`SuperAppDesignSystem`](https://github.com/DoniDevRs/superapp-design-system),
consumed as a local Swift Package dependency (`Packages/Pix/Package.swift`
points at `../../../superapp-design-system`). Feature code is not supposed
to define ad hoc visual components when an equivalent already exists there.

## Testing & Accessibility

- **23 unit tests** covering `PixViewModel` business logic (validation,
  navigation intents, error handling) and `CurrencyFormatter`, plus
  **3 UI tests** driving the app end to end with `XCUIApplication` — all
  passing.
- An automated accessibility audit
  (`XCUIApplication.performAccessibilityAudit()`, iOS 17+) runs across the
  full Pix flow (`AccessibilityAuditUITests`) with no `issueHandler`, so it
  fails the build on any finding — a real regression gate, not just a
  report. It currently reports **0 findings**, after **6 issues** (insufficient
  color contrast, undersized tap targets, unexposed VoiceOver text, and
  fixed font sizes not tracking Dynamic Type, among others) were found and
  fixed during development.

## Known issues

- [#1 — Design System component survey](https://github.com/DoniDevRs/superapp-ios/issues/1):
  tracks the audit of which `SuperAppDesignSystem` components already cover
  the Pix flow and what's still missing.
- [#2 — Tapping a recent recipient doesn't navigate to `ReviewPaymentView`](https://github.com/DoniDevRs/superapp-ios/issues/2):
  an open bug where a real user tap on a recent recipient row doesn't
  trigger navigation, even though the equivalent XCUITest synthetic tap
  passes. Root cause still under investigation.

## How to run

```sh
cd superapp-ios
open SuperApp.xcodeproj
```

In Xcode, select the **SuperApp** scheme, choose an iPhone simulator, and
press **⌘R** to run the app.

To run the test suite (unit + UI tests): **⌘U**.

## Screenshots

Before (legacy flow) and after (this redesign):

![Old Pix flow: 6 screens with 4 redundant decisions](docs/images/pix-antes.png)

![New Pix flow: 3 screens](docs/images/pix-depois.png)
