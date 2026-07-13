# Aegis Bank Mobile App

Flutter client for the Little Boy's Aegis banking demonstration. The app can
run entirely against in-memory mock repositories or connect to the Spring Boot
banking API. It covers authentication, account balances, transfers, transaction
history, and administrator security controls.

> This is a hackathon and security-training application. Mock accounts,
> deliberate attack/defense scenarios, and simulator controls are not intended
> for production banking use.

## Features

- Login and registration with persisted sessions
- Customer dashboard and account balance display
- Validated account-to-account transfers
- Searchable transaction history
- Administrator security-control screen
- Offline mock mode for demos without infrastructure
- Runtime backend host and port configuration
- Encrypted local storage through `flutter_secure_storage`
- Versioned Flutter web scaffold, with application code portable to generated
  Android/iOS/desktop scaffolds

## Architecture

```text
screens
  |-- AuthCubit
  |-- TransactionCubit
  `-- SecurityCubit
          |
   RepositoryRegistry (Provider)
      |               |
      | mock mode     | online mode
      v               v
 in-memory repos   Dio repositories --> Aegis Bank API
          \             /
           SecureStorage
```

`RepositoryRegistry` is the runtime switch between mock and online
implementations. Bloc/Cubit owns screen state, Provider exposes the repository
registry, Dio performs HTTP calls, and `SecureStorage` holds the JWT, user
profile, mode, and server configuration.

## Prerequisites

- Flutter stable with Dart `>=3.0.0 <4.0.0`
- Chrome for the checked-in Flutter web target
- Android Studio/Android SDK or Xcode/CocoaPods only after adding the
  corresponding local platform scaffold
- A running `aegis-bank-backend` only when online mode is enabled

Check the toolchain before installing packages:

```bash
flutter doctor
flutter pub get
```

## Run Locally

The application starts in mock mode, so no backend is needed:

```bash
flutter run
```

The checked-in platform target is web:

```bash
flutter devices
flutter run -d chrome
```

### Mock accounts

| Role | Username | Password | Account |
|---|---|---|---|
| Customer | `alice` | `password123` | `ACC-123456` |
| Customer | `bob` | `password123` | `ACC-987654` |
| Administrator | `admin` | `admin123` | none |

These credentials exist only in `MockAuthRepository` and must not be reused in
any deployed environment.

## Connect to the Backend

From the login screen, open the settings control, disable **Mock API Offline
Mode**, and set the API host and port. The values are stored securely and the
repository implementations update immediately.

Common host values:

| Target | Backend host |
|---|---|
| Android emulator | `10.0.2.2` |
| iOS simulator | `127.0.0.1` |
| Physical device | Development machine's LAN IP |
| Flutter web | Host reachable by the browser |

The default port is `8080`. For a physical device, keep both devices on the
same network and ensure the backend/firewall accepts LAN traffic.

Compile-time defaults are also supported:

```bash
flutter run \
  --dart-define=API_IP=10.0.2.2 \
  --dart-define=API_PORT=8080
```

Previously saved runtime values take precedence after startup.

## Backend API Contract

Online repositories use these endpoints:

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/auth/login` | Authenticate and return JWT/user data |
| `POST` | `/api/auth/register` | Create a demo customer |
| `GET` | `/api/accounts/{accountNumber}/details` | Load account details |
| `POST` | `/api/transactions/transfer` | Submit a transfer |
| `GET` | `/api/transactions/history` | Load account history |

Authenticated requests receive `Authorization: Bearer <token>` from the Dio
interceptor.

## Quality Checks

```bash
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test
```

The current test suite covers transfer input validation, including account
format, self-transfer, positive numeric amounts, and required descriptions.

## Build Artifacts

```bash
flutter build web --release
```

Web output is written to `build/web/`. This repository currently versions only
the web platform scaffold. To create mobile scaffolds in a local development
branch, use `flutter create --platforms=android,ios .`, review the generated
files, then use `flutter build apk`, `flutter build appbundle`, or (on macOS)
`flutter build ipa`.

## Repository Layout

```text
lib/
├── data/
│   ├── api/dio_client.dart
│   ├── repositories/
│   └── secure_storage.dart
├── domain/models/
├── presentation/
│   ├── bloc/
│   └── screens/
└── main.dart
test/
└── transfer_screen_test.dart
web/
```

## Security Notes

- Tokens and user session fields are kept in platform secure storage, not
  plaintext preferences.
- The app currently uses HTTP for local demo connectivity. Use TLS and trusted
  certificates before connecting outside a development network.
- Client-side validation improves usability but is not an authorization
  boundary; the backend must independently validate every transfer.
- Clearing application data resets saved mode, endpoint, and session state.

## Related Repositories

- [`aegis-bank-backend`](https://github.com/Little-Boy-s-Aegis/aegis-bank-backend) — banking API
- [`aegis-bank-deployment`](https://github.com/Little-Boy-s-Aegis/aegis-bank-deployment) — complete local platform
- [`dashboard`](https://github.com/Little-Boy-s-Aegis/dashboard) — SOC dashboard
