# JLPT Flashcards

JLPT Flashcards is a Flutter app for learning Japanese vocabulary and kanji using spaced-repetition (SM-2). Supports desktop and mobile targets and includes study modes, example sentences, and progress tracking.

## Features
- Spaced-repetition scheduling (SM-2)
- JLPT level tagging (N1..N5)
- Multiple practice modes: flashcards, multiple-choice, listening
- Progress & review history
- Import/Export (CSV / Anki-compatible)
- Desktop-friendly UI (Windows / Linux / macOS) and mobile support

## Demo
Add screenshots or GIFs in the `assets/screenshots/` folder and link them here.

## Getting started

Prerequisites
- Flutter SDK (>= 3.x)
- Windows / Linux / macOS build dependencies (if building desktop)
- Optional: Dart/Flutter tools in PATH

Install and run (Windows PowerShell)
```powershell
Set-Location E:\flutter_projects\jlpt_flashcards
flutter pub get
flutter run -d windows   # or -d chrome / -d linux / -d macos / -d android / -d ios
```

Build release
```powershell
flutter build windows
```

## Development notes
- Spaced repetition logic: lib/services/spaced_repetition.dart
- Card model: lib/models/vocabulary_card.dart
- Tests: test/ (add CI to run `flutter test`)

## Contributing
1. Fork the repo
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit and push
4. Open a pull request

Please include tests for new scheduling behavior and UI changes.

## License
Choose a license (e.g., MIT). Add a LICENSE file.

## Contact
Project maintainer: add your name and email or link to GitHub profile.
