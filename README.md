# Sandwich Shop App

A small Flutter demo app for ordering sandwiches. It demonstrates common Flutter concepts: stateful widgets, forms, dropdowns, custom buttons, text input, simple repository logic, and widget tests.

---

## Table of contents

- About
- Features
- Screenshots
- Requirements
- Installation & setup (Windows)
- Running the app
- Usage
- Configuration & formatting
- Tests
- Project structure
- Known issues & roadmap
- Contributing
- Contact

---

## About

This app is a learning/demo project that provides a simple UI for composing sandwich orders: select bread, choose sandwich type, adjust quantity, and add order notes. It is intended for practicing Flutter UI, state management, and widget testing.

---

## Features

- Order screen with quantity controls (increment / decrement)
- Toggle for sandwich type (footlong / other)
- Bread type selection via an enum-backed dropdown
- Order notes with TextField
- Reusable stylised button widget
- Order item display widget (used by tests)
- Widget tests for UI assertions

---

## Screenshots



## Requirements

- OS: Windows (instructions below use Windows shell)
- Flutter SDK (compatible with constraints in `pubspec.yaml`)
- Dart (bundled with Flutter)
- Git (to clone the repo)
- Recommended editor: Visual Studio Code with Dart & Flutter extensions

Check your setup:
```powershell
flutter --version
flutter doctor
```

---

## Installation & setup (Windows)

1. Clone the repository:
```powershell
git clone https://github.com/Luke-L2264308/sandwich_shop.git 
```

2. Get dependencies:
```powershell
flutter pub get
```

3. (Optional) Activate devtools:
```powershell
flutter pub global activate devtools
```

---

## Running the app

1. Start an emulator or connect a device.
2. From project root:
```powershell
flutter run
```
Or open the project in VS Code and press F5.

---

## Usage

- Open the app to the Order screen.
- Use the Add / Remove buttons to change quantity.
- Toggle sandwich type to switch between sizes.
- Select bread type using the dropdown.
- Enter order notes in the text field; notes are shown in the OrderItemDisplay.
- The `OrderRepository` enforces min/max quantity behavior.

Testing tips:
- The widget tests assert exact text output from `OrderItemDisplay`. If you change text formatting, update tests or relax assertions (e.g., `find.textContaining`).

---

## Configuration & formatting

- Linting: `flutter_lints` is included in `pubspec.yaml`. To enable rule set, add `analysis_options.yaml` at project root with:
```yaml
include: package:flutter_lints/flutter.yaml
```



- Run static analysis:
```powershell
flutter analyze
```

- Apply automated fixes:
```powershell
dart fix --apply
```

---

## Tests

- Run all tests:
```powershell
flutter test
```

- Run a single test file:
```powershell
flutter test test/views/widget_test.dart
```

Notes:
- Tests currently expect exact strings from `OrderItemDisplay` (including "Note:" prefix and spacing). If tests fail, either adjust the widget output or the test assertions.

---

## Project structure

- lib/
  - main.dart — main app, `OrderScreen`, `OrderItemDisplay`, `StylisedButton`
  - repositories/order_repository.dart — quantity business logic
  - views/app_styles.dart — styling helpers
- test/
  - views/widget_test.dart — widget tests
- assets/images/ — image assets
- pubspec.yaml — dependencies & assets
- README.md — this file

---

## Known issues & roadmap

- Tests are strict about exact text formatting; consider using more resilient matchers.
- Some widgets may be incomplete or placeholder (e.g., stylised button icon rendering).
- Future improvements:
  - Persist orders locally or via backend
  - Add integration tests
  - Improve accessible labels and localization
  - Add screenshots and richer UI polish

---

## Contributing

1. Fork the repo and create a feature branch.
2. Run and test locally.
3. Add tests for new features/changes.
4. Submit a pull request with a clear description.

Please follow existing code style and run `flutter analyze` before opening PR.

---

## Contact

Project maintained by the repository owner. For questions or issues, open an issue in the repository or contact the maintainer via the project hosting platform.