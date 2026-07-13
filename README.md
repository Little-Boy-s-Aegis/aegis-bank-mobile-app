# Aegis Bank Mobile App

This is the hybrid mobile application client for the Aegis Secure Banking Platform. Built using **Flutter** and the **Bloc** state management pattern, it offers persistent sessions and custom dashboards.

---

## Prerequisites
Ensure you have the following installed on your machine:
- **Flutter SDK** (Channel stable, 3.19+ recommended)
- **Dart SDK** (included with Flutter)
- **Android SDK** (for Android Emulator/Devices)
- **Xcode** (macOS only, for iOS Simulator/Devices)
- **VS Code** or **Android Studio** with Flutter extension

---

## Running the Mobile App

### 1. Retrieve Packages
Navigate to the `FE_App` folder and fetch all required pub dependencies:
```bash
cd FE_App
flutter pub get
```

### 2. Verify Flutter Environment
Check if your SDKs, emulators, and plugins are correctly set up:
```bash
flutter doctor
```

### 3. Start Emulator/Device
Start an Android Virtual Device (AVD) or iOS Simulator, or connect a physical phone in Developer Mode.

### 4. Run the App
To start the app in debug mode:
```bash
flutter run
```
To run on a specific device ID:
```bash
flutter run -d <device-id>
```

---

## Offline vs Online Backend Mode

- **Mock Repository Mode (Offline)**: By default, the app runs in offline mock mode so you can test features instantly without running any backend servers.
- **Connecting to the Backend (Online)**:
  1. On the Login screen, click the **Settings icon** (gear) in the top-right corner.
  2. Toggle off **Mock API Offline Mode**.
  3. Enter your backend host address:
     - **Android Emulator**: Use `http://10.0.2.2:8080` (routes to your host's localhost).
     - **iOS Simulator / Local WiFi**: Use `http://<your-local-ip-address>:8080` (ensure the backend host is bound to all interfaces or same network).

---

## Building the Production App

### Build Android APK
Generates a release bundle or fat APK for installation:
```bash
flutter build apk --release
```
The output file will be saved at `build/app/outputs/flutter-apk/app-release.apk`.

### Build iOS App Bundle
Generates the iOS runner build (requires macOS and Xcode):
```bash
flutter build ipa --release
```

---

## Security Hardening and Config Updates

* **Encrypted Storage Migration**: Upgraded mobile session cache and local repository from plaintext `SharedPreferences` to `flutter_secure_storage`. This encrypts user credentials, JWT access tokens, and vulnerability controls at rest.
* **Obfuscated Toggles and Credentials**: Inlined mock credentials and control flags are obfuscated to prevent reverse-engineering extraction.
* **Dynamic Network Setup**: Replaced static compile-time IP constants with static variables initialized at launch, enabling dynamic, real-time updates to backend API endpoints (`baseIp` and `port`) in the Repository Provider settings.

---

## Tech Stack

| Component | Version |
|---|---|
| Flutter | 3.19+ (stable channel) |
| Dart SDK | >=3.0.0 <4.0.0 |
| State Management | flutter_bloc 8.1.6 |
| HTTP Client | dio 5.7.0 |
| Secure Storage | flutter_secure_storage 10.3.1 |
| Provider | provider 6.1.2 |
| Intl | intl 0.19.0 |

---

## Deployment

This is a mobile application that connects to the banking API backend. For local development with the backend, start the full ecosystem using [aegis-bank-deployment](https://github.com/Little-Boy-s-Aegis/aegis-bank-deployment), then configure the app to point to your machine's IP.

---

## Related Repositories

| Repository | Description |
|---|---|
| [aegis-bank-deployment](https://github.com/Little-Boy-s-Aegis/aegis-bank-deployment) | Docker Compose orchestration |
| [aegis-bank-backend](https://github.com/Little-Boy-s-Aegis/aegis-bank-backend) | Spring Boot banking API |
| [aegis-bank-web-client](https://github.com/Little-Boy-s-Aegis/aegis-bank-web-client) | Next.js banking portal |
| [dashboard](https://github.com/Little-Boy-s-Aegis/dashboard) | SOC Dashboard - Go backend + React frontend |
| [agent-layer-1](https://github.com/Little-Boy-s-Aegis/agent-layer-1) | AI Sensor Agents |
| [agent-layer-2](https://github.com/Little-Boy-s-Aegis/agent-layer-2) | Meta Analyzer / SOAR Orchestrator prompts |
| [aegis-soar-engine](https://github.com/Little-Boy-s-Aegis/aegis-soar-engine) | SOAR Decision Engine |
| [aegis-staging-sandbox](https://github.com/Little-Boy-s-Aegis/aegis-staging-sandbox) | Staging Sandbox |
| [aegis-bank-terraform](https://github.com/Little-Boy-s-Aegis/aegis-bank-terraform) | Terraform IaC |
