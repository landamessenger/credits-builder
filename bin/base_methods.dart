import 'dart:io';

import 'package:credits_builder/dependency.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import 'exceptions.dart';
import 'scrapers/license.dart';
import 'scrapers/repository.dart';
import 'utils/constants.dart';
import 'utils/platform_support.dart';
import 'utils/pub_info.dart';

String introMessage(String version) => '''
  ════════════════════════════════════════════
     credits_builder (v $version)                
  ════════════════════════════════════════════
  ''';

Map<String, dynamic> loadConfigFile() {
  final File file = File("pubspec.yaml");
  final String yamlString = file.readAsStringSync();
  // ignore: always_specify_types
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap[configId] is! Map) {
    stderr.writeln(
      const NoConfigFoundException(
        'Check your config file pubspec.yaml has a `$configId` section',
      ),
    );
    exit(1);
  }

  final Map<String, dynamic> config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry in yamlMap[configId].entries) {
    config[entry.key] = entry.value;
  }

  return config;
}

Map<String, dynamic> loadDependenciesFile() {
  final File file = File("pubspec.yaml");
  final String yamlString = file.readAsStringSync();
  // ignore: always_specify_types
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap[dependenciesId] is! Map) {
    stderr.writeln(
      const NoConfigFoundException(
        'Check your config file pubspec.yaml has a `$dependenciesId` section',
      ),
    );
    exit(1);
  }

  final Map<String, dynamic> config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry in yamlMap[dependenciesId].entries) {
    config[entry.key] = entry.value;
  }

  return config;
}

Future<Dependency?> getData(String id, dynamic version) async {
  try {
    String v = '';
    bool findUpdate = false;
    bool isSdk = false;
    if (version.toString().contains('git')) {
      v = 'git';
    } else if (version.toString().contains('{path:')) {
      v = 'local';
    } else if (version.toString().contains('{sdk: flutter}')) {
      v = 'sdk';
      isSdk = true;
    } else {
      v = version.toString();
      findUpdate = true;
    }

    final info = findUpdate ? await getInfo(id) : null;
    final publisher = await getPublisher(id);
    var url = Uri.https(domain, 'packages/$id');
    var urlLicense = Uri.https(domain, 'packages/$id/license');
    var response = await http.get(url);
    var responseLicense = await http.get(urlLicense);

    return Dependency(
      id: id,
      repository: getRepository(response.body),
      licenseType: getLicense(id, response.body),
      licenseContent: getLicenseContent(responseLicense.body),
      publisher: publisher?.publisherId ?? "",
      currentVersion: v,
      version: info?.version ?? v,
      supportsAndroid: isSdk ? isSdk : supportAndroid(response.body),
      supportsIOS: isSdk ? isSdk : supportIOS(response.body),
      supportsLinux: isSdk ? isSdk : supportLinux(response.body),
      supportsMacOS: isSdk ? isSdk : supportMacOS(response.body),
      supportsWeb: isSdk ? isSdk : supportWeb(response.body),
      supportsWindows: isSdk ? isSdk : supportWindows(response.body),
    );
  } catch (e) {
    print(e);
    return null;
  }
}
