# Soultech Vending — Phase 2

Phase 2 foundation for the Soultech Vending management app.

## Included
- Soultech branding and logo
- Machine CRUD: add/edit/delete
- Machine details dashboard
- Machine-specific records filter foundation
- SQLite schema for machines, sales, products, restocking and cash/reconciliation
- Change Added terminology
- Location commission percentage
- Profit/commission calculation foundation
- Sales chart foundation
- Arabic/English localization structure
- February–August CSV import template
- Android project scaffold
- Gradle launcher that avoids the corrupted Gradle wrapper cache issue

## First run

Requirements: Flutter stable, Android SDK, Java 17 or a Flutter-supported JDK.

From this folder:

```bash
flutter --version
flutter create . --platforms=android,ios
flutter pub get
flutter run
```

If `flutter create .` asks to overwrite a generated Android/iOS file, keep the project files in `lib/`, `assets/`, and `pubspec.yaml`. The command is included as a safety step because Flutter's native template is version-specific.

### If you see `zip END header not found`

This means a corrupted Gradle distribution is cached. Run:

```bash
flutter clean
rm -rf ~/.gradle/wrapper/dists
flutter pub get
flutter run
```

This project also includes `android/gradlew`, which downloads Gradle 8.11.1 into the project instead of relying on the global wrapper cache.

## Historical import

Use `assets/data/legacy_import_template.csv`. Required fields:

- machine_code
- date
- product
- quantity
- selling_price
- cost_price
- note

The importer should map the existing February–August notes into machine-linked sales records.

## Soultech business rule

Location commission is configurable per machine/location. The current business proposal describes a sales-share option of 10%–20%, with the final percentage agreed per location/contract.
