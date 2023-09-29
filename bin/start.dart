import 'dart:convert';
import 'dart:io';

import 'configuration.dart';

const kDebugMode = true;

void main(List<String> arguments) async {
  var dependencies = loadDependenciesFile();
  print(introMessage(dependencies['credits_builder'].toString()));

  var config = loadConfigFile();

  final map = <String, dynamic>{};
  map['dependencies'] = {};
  print('Preparing ${dependencies.length} dependencies');
  for (var c in dependencies.keys.toList()) {
    final dependency = await getData(c, dependencies[c]);
    if (dependency == null) continue;
    var message = '- ${dependency.id} ${dependency.currentVersion}';

    if (dependency.publisher.isNotEmpty) {
      message += ' from ${dependency.publisher}';
    }

    if (dependency.licenseType.isNotEmpty) {
      message += ' (${dependency.licenseType})';
    }

    if (!dependency.isUpToDate()) {
      message += ' [NOT UP TO DATE] ❌  ';
    }

    print(message);

    map['dependencies'][dependency.id] = dependency.toJson();
  }

  final File file = File('./${config['assets']}');

  var encoder = const JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(map));
}
