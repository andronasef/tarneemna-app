---
last_mapped_commit: 70914c7b7717f2cabca6dc529f781ab29c0caec3
last_mapped_at: 2026-10-04
---
# Code Conventions

**Analysis Date:** 2026-10-04

## Language & Style Guidelines

- **Dart Formatter**: Standard Dart formatting with 80-character line recommendations.
- **Linter**: `flutter_lints` rules configured via `analysis_options.yaml`.
- **Naming Conventions**:
  - Files and directories: `lower_snake_case.dart`
  - Classes, Enums, Mixins: `UpperCamelCase`
  - Variables, Methods, Parameters: `lowerCamelCase`
  - Constant identifiers: `lowerCamelCase` or `UPPER_SNAKE_CASE`
- **Imports**: Package imports preferred over relative imports for cross-module dependencies (`package:tarneemna/...`).
- **Null Safety**: 100% sound null safety throughout all Dart sources.
- **Annotations**:
  - Explicit `@override` on all overridden lifecycle methods and getters.
  - `@pragma('vm:entry-point')` on isolate callbacks (such as download background callbacks).
