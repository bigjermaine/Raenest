# Raenest — Send Money Lite

A simplified send-money flow built for the iOS take-home assignment: enter an amount, choose a beneficiary, confirm with biometrics, and show a success or error result.

The app builds and runs without a backend.

## Architecture and structure

The project uses **Clean Architecture** with **MVVM** and a thin coordinator.

```
Raenest/
  App/                 Composition root, scene setup, navigation
  Domain/              Entities, repository protocols, use cases
  Data/                JSON loaders, Keychain, biometrics, networking
  Presentation/        View controllers + view models (programmatic UIKit)
  Resources/           beneficiaries.json, validation_rules.json
RaenestTests/          Business-logic unit tests
```

- **Domain** has no UIKit or Keychain imports. Use cases express the product rules and are the main test surface.
- **Data** implements those protocols. `MockAPIClient` can be replaced with `URLSessionAPIClient` in `AppDependencyContainer` without changing the rest of the app.
- **Presentation** is MVVM: view models own state and user intent; view controllers render and forward actions.
- **AppCoordinator** owns navigation so screens do not push each other directly.

## Key technical decisions

- **Programmatic UIKit only.** No storyboards or XIBs. UIKit was chosen because the assignment requires it and it keeps view lifecycle explicit.
- **Validation is data, not constants.** `Resources/validation_rules.json` is decoded at runtime. Amount bounds and allowed currencies are never hardcoded in Swift.
- **Continue is a validation result.** The button is enabled only when amount, currency, and beneficiary all pass `ValidateTransferUseCase`.
- **Secure token access.** A mock token is written to the Keychain on launch. Confirming a transfer authenticates with Face ID / Touch ID (passcode fallback) *before* the token is read, then calls `POST /send`.
- **Networking is replaceable.** Screens talk to `TransferRepository`. The repository talks to `APIClient`. The running app uses `MockAPIClient`; a real `URLSession` client is included and unused.
- **Biometric cancel stays on Confirm.** Cancellation or a failed Face ID prompt does not navigate away. A network/send failure opens the error result screen.

## How to run

1. Open `Raenest.xcodeproj` in Xcode.
2. Select an iPhone simulator and run the **Raenest** scheme.
3. On the simulator, enroll Face ID via **Features → Face ID → Enrolled**.
4. Enter an amount between 10 and 20,000, pick a currency and beneficiary, then continue.
5. On confirm, approve Face ID (**Features → Face ID → Matching Face**).

To see the mocked failure path, send the amount `404`.

```
Product → Test
```

runs the unit tests.

## Assumptions

- Beneficiaries are local JSON only; no remote directory.
- There is no real login. The mock token is created on first launch.
- `404` as the amount is a deliberate mock failure so both result states can be reviewed.
- If biometrics are unavailable, the app falls back to device passcode authentication.

## Approximate time spent

About 4 hours.

## Known limitations

- The send API is mocked and delayed in-process; there is no retry/idempotency layer.
- Keychain access is not protected by an access-control object that itself requires biometrics; biometrics are enforced in application code before the read, which matches the assignment and stays testable.
- No localization, accessibility audit, or snapshot tests.
- iPhone is portrait-only.
