# Raenest — Send Money Lite

A simplified send-money flow for the iOS take-home assignment:

1. Enter amount
2. Select beneficiary
3. Confirm & send
4. Display success or error

The Xcode project builds and runs without a real backend or external service.

## Architecture and structure

The app uses **Clean Architecture** with **MVVM** and a thin coordinator.

```
Raenest/
  App/                 Scene setup, dependency container, navigation
  Domain/              Entities, repository protocols, use cases
  Data/                JSON loading, Keychain, biometrics, networking
  Presentation/        View controllers and view models (programmatic UIKit)
  Resources/           beneficiaries.json, validation_rules.json
RaenestTests/          Business-logic unit tests
```

- **Domain** has no UIKit, Keychain, or URLSession imports. Product rules live in use cases.
- **Data** implements the domain protocols. `MockAPIClient` can be replaced with `URLSessionAPIClient` in `AppDependencyContainer`.
- **Presentation** is MVVM. View models own state and user intent. View controllers render UI and forward actions.
- **AppCoordinator** owns navigation so screens do not push each other directly.

### Flow

- **Screen 1 — Amount & Beneficiary:** amount input, currency chips, searchable beneficiary cards. Continue is enabled only when amount, currency, and beneficiary are valid.
- **Screen 2 — Confirm & Send:** summary of amount, currency, and beneficiary. Confirm requires biometrics, then reads the Keychain token and calls mocked `POST /send`.
- **Result:** success or error. Success starts a new transfer. Failure returns to Confirm.

## Key technical decisions

- **Programmatic UIKit only.** No storyboards or XIBs, as required. UIKit keeps view lifecycle explicit for this flow.
- **MVVM + Clean Architecture.** Chosen so UI, business logic, networking, and secure storage stay separated, and so the core rules are easy to unit test.
- **Validation is loaded at runtime.** `Resources/validation_rules.json` is decoded on launch. `min_amount`, `max_amount`, and `allowed_currencies` are not hardcoded in Swift.
- **Continue is a validation result.** `ValidateTransferUseCase` decides whether the form is complete. The button is not enabled by ad-hoc UI checks.
- **Beneficiary currency must match.** Each beneficiary has a receive currency in JSON. The list is filtered to that currency, and validation rejects a mismatch.
- **Secure token access.** A mock token is stored in the Keychain on first launch, protected by `SecAccessControl` (biometrics, with device passcode fallback). Confirm authenticates with Face ID or Touch ID, then reads that same token using the authenticated `LAContext` so the user is not prompted twice. The token is never read without that gate.
- **Networking is replaceable.** Screens talk to `TransferRepository`. The repository talks to `APIClient`. The running app uses `MockAPIClient`. A production-shaped `URLSessionAPIClient` is included and unused.
- **Biometric cancel stays on Confirm.** Cancellation or a failed Face ID prompt does not navigate away. A send/network failure opens the error result screen.
- **Accessibility.** Amount, currency, search, beneficiary cards, and primary actions have VoiceOver labels and hints. Validation and biometric errors are announced. Text uses Dynamic Type with capped maximum sizes.
- **async/await** is used for biometrics and the send request.

## Assumptions

- Beneficiaries come from local JSON only. No remote directory or API is required.
- There is no real login or signup. The mock auth token is created on first launch.
- Amount `404` is a deliberate mock failure so both result states can be reviewed.
- If biometrics are unavailable, the app falls back to device passcode authentication.
- A beneficiary can only receive the currency stored on that record.

## Approximate time spent

About 4 hours.

## Known limitations

- The send API is mocked in-process. There is no retry or idempotency layer.
- Keychain access is not protected by a biometric access-control object. Biometrics are enforced in application code before the Keychain read. That matches the assignment (“require biometric authentication before accessing the token”) and keeps the send flow testable.
- No localization, accessibility audit, or snapshot tests.
- iPhone is portrait-only.
- Haptic feedback is implemented, but the iOS Simulator does not play haptics. Use a physical device to feel it.

## How to run

1. Open `Raenest.xcodeproj` in Xcode.
2. Select an iPhone simulator and run the **Raenest** scheme.
3. Enroll Face ID: **Features → Face ID → Enrolled**.
4. Enter an amount between 10 and 20,000, choose a currency, select a matching beneficiary, then tap Continue.
5. On Confirm, approve Face ID: **Features → Face ID → Matching Face**.

To see the mocked error path, send the amount `404`.


Run unit tests with **Product → Test**. Tests cover validation rules, beneficiary filtering and currency matching, send + biometric cancellation, Confirm error routing, Keychain status mapping, and Continue-button enablement.

