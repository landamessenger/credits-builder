import 'dart:convert';
import 'dart:io';

import 'configuration.dart';

const kDebugMode = true;

void main(List<String> arguments) async {
  var dependencies = loadDependenciesFile();
  if (kDebugMode) {
    print(introMessage(dependencies['credits_builder'].toString()));
  }

  var config = loadConfigFile();

  final map = <String, dynamic>{};
  map['dependencies'] = {};
  print('Preparing ${dependencies.length} dependencies');
  for (var c in dependencies.keys.toList()) {
    //final package = await getInfo(c);
    final publisher = await getData(c, dependencies[c]);
    if (publisher == null) continue;
    if (kDebugMode) {
      print('- ${publisher.id} added');
    }
    map['dependencies'][publisher.id] = publisher.toJson();
  }

  final File file = File('./${config['assets']}');
  file.writeAsStringSync(jsonEncode(map));
}
