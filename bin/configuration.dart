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

Future<PubPackage?> _getInfo(String id) async {
  try {
    return await PubClient().packageInfo(id);
  } catch (e) {
    return null;
  }
}

Future<PackagePublisher?> _getPublisher(String id) async {
  try {
    return await PubClient().packagePublisher(id);
  } catch (e) {
    return null;
  }
}

Future<Dependency?> getData(String id, dynamic version) async {
  try {
    String v = '';
    bool findUpdate = false;
    if (version.toString().contains('git')) {
      v = 'git';
    } else if (version.toString().contains('{path:')) {
      v = 'local';
    } else if (version.toString().contains('{sdk: flutter}')) {
      v = 'sdk';
    } else {
      v = version.toString();
      findUpdate = true;
    }

    final info = findUpdate ? await _getInfo(id) : null;
    final publisher = await _getPublisher(id);
    var url = Uri.https('pub.dev', 'packages/$id');
    var urlLicense = Uri.https('pub.dev', 'packages/$id/license');
    var response = await http.get(url);
    var responseLicense = await http.get(urlLicense);

    final repository = _getRepository(response.body);
    final licenseType = _getLicense(id, response.body);
    final licenseContent = _getLicenseContent(responseLicense.body);

    return Dependency(
      id: id,
      repository: repository,
      licenseType: licenseType,
      licenseContent: licenseContent,
      publisher: publisher?.publisherId ?? "",
      currentVersion: v,
      version: info?.version ?? v,
      supportsAndroid: _supportAndroid(response.body),
      supportsIOS: _supportIOS(response.body),
      supportsLinux: _supportLinux(response.body),
      supportsMacOS: _supportMacOS(response.body),
      supportsWeb: _supportWeb(response.body),
      supportsWindows: _supportWindows(response.body),
    );
  } catch (e) {
    print(e);
    return null;
  }
}

String _getRepository(String content) {
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

String _getLicense(String id, String content) {
  try {
    String a =
        content.split('alt="Icon for licenses." width="14" height="14"/>')[1];
    String b = a.split(' (<a href="/packages/')[0];
    return b;
  } catch (e) {
    return "";
  }
}

String _getLicenseContent(String content) {
  try {
    String a = content.split('<pre>')[1];
    String b = a.split('</pre>')[0];
    return b;
  } catch (e) {
    return "";
  }
}

bool _supportAndroid(String content) {
  try {
    return _platformSupport('android', content);
  } catch (e) {
    return false;
  }
}

bool _supportIOS(String content) {
  try {
    return _platformSupport('ios', content);
  } catch (e) {
    return false;
  }
}

bool _supportMacOS(String content) {
  try {
    return _platformSupport('macos', content);
  } catch (e) {
    return false;
  }
}

bool _supportWeb(String content) {
  try {
    return _platformSupport('web', content);
  } catch (e) {
    return false;
  }
}

bool _supportWindows(String content) {
  try {
    return _platformSupport('windows', content);
  } catch (e) {
    return false;
  }
}

bool _supportLinux(String content) {
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
