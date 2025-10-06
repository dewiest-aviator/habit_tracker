# Habit Tracker Agent Guidelines

## 1. Overview

This document provides a comprehensive guide to the Habit Tracker project architecture, development practices, and operational workflows. It consolidates key information about the project’s structure, coding standards, tooling, and processes to ensure maintainability, scalability, and collaboration efficiency.

## 2. Project Scope

Habit Tracker is a modular Flutter application designed to help users build and maintain habits. The codebase emphasizes clean architecture, separation of concerns, and testability. Features are encapsulated in independent modules, leveraging core services for shared functionality.

## 3. Tooling and Environment

- **Flutter SDK** managed via FVM for consistent versioning.
- **State management** with Riverpod.
- **Routing** using GoRouter.
- **Localization** with Flutter’s internationalization tools (`gen-l10n`).
- **Static analysis and formatting** enforced through CI/CD pipelines.
- Environment-specific configurations are managed centrally for flexibility across development stages.

## 4. Architecture

### Core Principles

- Follow Flutter’s recommended best practices for modularity, testability, and maintainability.
- Separate UI, business logic, and data layers clearly.
- Use dependency injection and providers to decouple components.

### Layered Structure

- **Presentation Layer**: UI widgets and screens composed of reusable components.
- **Application Layer**: State management, business logic, and use cases implemented with Riverpod providers.
- **Domain Layer**: Core entities, models, and business rules.
- **Data Layer**: Repositories, data sources (local and remote), and data mappers.

### State Management

- Utilize Riverpod for compile-time safety and reactive programming.
- Prefer immutable state and state notifier patterns for predictable state transitions.

### Side Effects and Async

- Handle side effects and asynchronous operations via providers and service abstractions.
- Ensure error handling and loading states are managed consistently.

### Data and Mapping

- Use data mappers to convert between domain models and data entities.
- Maintain clear separation between data representations and business logic.

### Errors

- Implement centralized error handling strategies.
- Surface meaningful error messages to UI and log errors for telemetry.

## 5. Folder Layout

- `lib/core`: Contains foundational modules shared across features.
  - `config/env`: Manages environment-specific configurations.
    - Subfolders: `dev`, `staging`, `prod` — each contains environment-specific configuration files (e.g., API endpoints, feature flags).
    - `app_config.dart`: Defines the `AppEnvironment` enum (`dev`, `staging`, `prod`) and global configuration logic.
    - `selector.dart`: Contains runtime logic to select the appropriate environment configuration based on build flags or runtime conditions.
  - `localization`: Internationalization setup and generated localization delegates.
  - `router`: Application routing logic using GoRouter.
  - `services`: Core services such as network clients and authentication.
  - `telemetry`: Analytics and logging abstractions respecting user consent.
  - `theme`: Centralized theming and styling.

- `features/`: Contains feature modules encapsulating UI, state, and domain logic, each with its own providers and dependencies on core abstractions.

### Extending Environments

- Follow existing folder and naming conventions.
- Add new environment-specific configuration files in a new subfolder under `lib/core/config/env`.
- Update `AppEnvironment` enum and `selector.dart` to include the new environment.
- Use `selector.dart` in `main.dart` to initialize the app with the correct environment.

## 6. Testing Strategy

- **Unit Tests**: Test pure business logic and providers in core and feature modules.
- **Widget Tests**: Validate UI components and their response to state changes.
- **Integration Tests**: Cover end-to-end feature flows, navigation, and service interactions.
- Run tests with coverage reports (`fvm flutter test --coverage`).
- Maintain coverage thresholds as defined in CI/CD.

## 7. Localization and Assets

- Add user-facing strings in ARB files under `lib/core/localization/`.
- Regenerate localization delegates using `fvm flutter gen-l10n`.
- Manage assets consistently and reference them via centralized asset management.

## 8. Analytics and Telemetry

- Route all analytics events through the `TelemetryService` abstraction in `lib/core/telemetry`.
- Respect user privacy and consent toggles on all platforms.
- Document new analytics events with event names, triggers, and parameters.
- Cover telemetry flows with tests verifying consent gating and event dispatch.

## 9. Secrets and CI/CD

- Manage secrets securely and avoid committing sensitive information.
- Use CI/CD pipelines to:
  - Enforce static analysis (`fvm flutter analyze`).
  - Run tests and collect coverage.
  - Automate localization generation and code formatting checks.
  - Deploy artifacts only after passing quality gates.

## 10. Documentation and Changelog

- Maintain up-to-date documentation for architectural decisions, APIs, and analytics events.
- Use a changelog to track significant changes, releases, and updates systematically.

## 11. Release Process

- Ensure all tests pass and coverage thresholds are met.
- Validate localization and assets.
- Review telemetry and analytics event coverage.
- Tag releases following semantic versioning.
- Deploy via automated CI/CD pipelines.

## 12. Contribution Workflow

- Fork and branch from the main repository.
- Follow coding standards and architectural guidelines.
- Write tests for new features or bug fixes.
- Submit pull requests with clear descriptions and linked issues.
- Participate in code reviews and address feedback promptly.

## 12.1 Git Branching, Commit, and PR Conventions

### Branching Strategy
- Follow a feature-based branching model derived from `main`.
- Use descriptive branch names with the following format:
  - `feature/<short-description>` for new features.
  - `fix/<short-description>` for bug fixes.
  - `refactor/<short-description>` for refactors.
  - `ci/<short-description>` for CI/CD changes.
  - Example: `feature/add-habit-reminders` or `fix/firebase-upload-auth`.

### Commit Message Conventions
- Use [Conventional Commits](https://www.conventionalcommits.org/) for all commits.
- Format: `<type>(<scope>): <short summary>`.
- Common types: `feat`, `fix`, `refactor`, `docs`, `ci`, `test`, `style`.
- Examples:
  - `feat(auth): implement email login with Firebase`
  - `fix(ci): correct WIF token for staging`
  - `refactor(config): simplify env selector logic`

### Pull Request (PR) Handling
- Create a new branch from the latest `main` using:
  ```bash
  git fetch origin
  git checkout main
  git pull --ff-only origin main
  git checkout -b <branch-name>
  ```
- Push your branch and open a PR using `gh pr create --fill`.
- Assign yourself or relevant reviewers.
- PR titles should follow the same convention as commits.
- Include a clear description of what was changed, why, and any testing steps.
- Enable **auto-merge** (`gh pr merge <PR_NUMBER> --auto --merge`) after CI passes.
- Small, focused PRs are preferred over large multi-purpose ones.

### Merge Strategy
- Use **merge commits** for traceability.
- Avoid rebasing public branches.
- Delete feature branches after merge to keep the repo clean.

## 13. Quick Commands

- **Run tests with coverage:** `fvm flutter test --coverage`
- **Analyze code:** `fvm flutter analyze`
- **Generate localizations:** `fvm flutter gen-l10n`
- **Format code:** `fvm dart format .`
- **Run app with environment selector:** Use `main.dart` importing `selector.dart` to initialize the correct environment.

## 14. Appendix: Flutter Architectural Concepts and Recommendations

- Favor composition over inheritance in UI components.
- Use Riverpod providers to expose dependencies and state.
- Separate UI, domain, and data layers for maintainability.
- Handle side effects and asynchronous operations via providers.
- Use immutable state and state notifier patterns.
- Leverage GoRouter for declarative routing and navigation guards.
- Abstract platform-specific implementations behind interfaces.
- Respect user privacy and consent in telemetry and analytics.
- Maintain modular and extensible codebases to enable independent feature development and testing.
