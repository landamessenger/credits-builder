# Credits builder

A simple package to generate a credit page of your dependencies. The best way to thank and appreciate the work of third party libraries.

## Configuration

Setup the dependency:

```yaml
dependencies:
  credits_builder: ^0.0.1                 # android   ios   linux   macos   web   windows

credits_builder:
  outputFile: "assets/dependencies.json"  # default value
```

## Usage

### Generate the dependencies file

By running this command you will create/update your dependencies file in the assets folder (`assets/dependencies.json`):

```bash
dart run credits_builder:start
```

### Runtime side

You can get all the dependencies:

```dart
Future<List<Dependency>> getDependencies(BuildContext context) =>
      CreditsBuilder().config().get(context);
```

If you defined a dependency file name different from the default you can retrieve the information like this:

```dart
 Future<List<Dependency>> getDependencies(BuildContext context) =>
    CreditsBuilder()
        .config(
          path: 'assets/other_file_name.json',
        )
        .get(context);
```

If you want to preprocess the file information before using it (for example to deobfuscate the file with [Stringcare](https://github.com/StringCare/stringcare)) you can do it like this:

```dart
 Future<List<Dependency>> getDependencies(BuildContext context) =>
    CreditsBuilder()
        .config(
          process: (data) async => Stringcare().revealData(data) ?? data,
        )
        .get(context);
```



