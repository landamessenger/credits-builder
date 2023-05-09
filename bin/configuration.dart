import 'dart:io';

import 'package:credits_builder/dependency.dart';
import 'package:http/http.dart' as http;
import 'package:pub_api_client/pub_api_client.dart';
import 'package:yaml/yaml.dart';

import 'exceptions.dart';

const configId = 'credits_builder';
const dependenciesId = 'dependencies';
const kDebugMode = true;

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

Future<PubPackage?> getInfo(String id) async {
  try {
    return await PubClient().packageInfo(id);
  } catch (e) {
    return null;
  }
}

Future<PackagePublisher?> getPublisher(String id) async {
  try {
    return await PubClient().packagePublisher(id);
  } catch (e) {
    return null;
  }
}

Future<Dependency?> getData(String id, dynamic version) async {
  try {
    var v = version.toString().contains('git') ? 'git' : version.toString();
    final info = await getInfo(id);
    final publisher = await getPublisher(id);
    var url = Uri.https('pub.dev', 'packages/$id');
    var urlLicense = Uri.https('pub.dev', 'packages/$id/license');
    var response = await http.get(url);
    var responseLicense = await http.get(urlLicense);

    final repository = getRepository(response.body);
    final licenseType = getLicense(id, response.body);
    final licenseContent = getLicenseContent(responseLicense.body);
    return Dependency(
      id: id,
      repository: repository,
      licenseType: licenseType,
      licenseContent: licenseContent,
      publisher: publisher?.publisherId ?? "",
      currentVersion: v,
      version: info?.version ?? "",
      supportsAndroid: supportAndroid(response.body),
      supportsIOS: supportIOS(response.body),
      supportsLinux: supportLinux(response.body),
      supportsMacOS: supportMacOS(response.body),
      supportsWeb: supportWeb(response.body),
      supportsWindows: supportWindows(response.body),
    );
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return null;
  }
}

String getRepository(String content) {
  try {
    String a = content.split("pkg-infobox-metadata")[1];
    String b = a.split('<h3 class="title">')[0];
    String c = b.split('<p>')[2];
    String d = c.split('</p>')[0];
    String e = d.split(' href="')[1];
    String f = e.split('" rel="ugc"')[0];
    return f;
  } catch (e) {
    return "";
  }
}

String getLicense(String id, String content) {
  try {
    String a =
        content.split('alt="Icon for licenses." width="14" height="14"/>')[1];
    String b = a.split(' (<a href="/packages/')[0];
    return b;
  } catch (e) {
    return "";
  }
}

String getLicenseContent(String content) {
  try {
    String a = content.split('<pre>')[1];
    String b = a.split('</pre>')[0];
    return b;
  } catch (e) {
    return "";
  }
}

bool supportAndroid(String content) {
  try {
    return _platformSupport('android', content);
  } catch (e) {
    return false;
  }
}

bool supportIOS(String content) {
  try {
    return _platformSupport('ios', content);
  } catch (e) {
    return false;
  }
}

bool supportMacOS(String content) {
  try {
    return _platformSupport('macos', content);
  } catch (e) {
    return false;
  }
}

bool supportWeb(String content) {
  try {
    return _platformSupport('web', content);
  } catch (e) {
    return false;
  }
}

bool supportWindows(String content) {
  try {
    return _platformSupport('windows', content);
  } catch (e) {
    return false;
  }
}

bool supportLinux(String content) {
  try {
    return _platformSupport('linux', content);
  } catch (e) {
    return false;
  }
}

bool _platformSupport(String platformId, String content) {
  try {
    String a = content.split('<span class="tag-badge-main">Plat')[1];
    String b = a.split('</div>')[0];
    return b.contains('%3A$platformId"');
  } catch (e) {
    return false;
  }
}
