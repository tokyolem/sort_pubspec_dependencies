## Description

A Dart CLI tool for sorting dependencies in your `pubspec.yaml` file.

Keep your `pubspec.yaml` organized by alphabetically sorting ```dependencies:``` and ```dev_dependencies:```. This tool ensures better readability and consistency across projects.

## Features

- Sorts `dependencies` and `dev_dependencies` alphabetically.
- Maintains additional metadata for dependencies (e.g., paths, Git URLs and refs, version constraints).
- CLI support for easy integration into development workflows.
- The package is implemented exclusively using Dart tools, there are no transitive dependencies.
- Lightweight and fast.

## Installation

Add `sort_pubspec_dependencies` as a dev dependency in your project:
```yaml
dev_dependencies:
  sort_pubspec_dependencies: <latest-version>
```

## Usage

Run the tool locally
```bash
dart run sort_pubspec_dependencies
```

## Options

You can create a `sort_dependencies.yaml` config in the root of your project for:

- Your `pubspec.yaml` is located outside the main project directory, you can explicitly specify the path to it using the key: `pubspecPath`
- If you want to run `flutter pub get` after sorting, set the value `true` to the key `needRunPubGetAfterSorting`

The `sort_dependencies.yaml` example: 
```yaml
pubspecPath: 'pubspec.yaml'
needRunPugGetAfterSorting: true
```

Also, you can run the tool via `dart run sort_pubspec_dependencies --pubspec-path=<path>/p=<path> --with-run-pub-get` to avoid creating a config and get the same effect

## Conclution

Feel free to modify this template to suit your preferences or project needs

Also, you can open issues with a description of the problem if you find unexpected behavior
