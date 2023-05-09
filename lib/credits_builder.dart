library credits_builder;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dependency.dart';

export 'dependency.dart';

class CreditsBuilder {
  static CreditsBuilder? _instance;

  CreditsBuilder._internal();

  factory CreditsBuilder() {
    _instance ??= CreditsBuilder._internal();
    return _instance!;
  }

  String path = "assets/credits.json";

  final dependencies = <Dependency>[];

  Future<Uint8List> Function(Uint8List data) process = (data) async => data;

  CreditsBuilder config({
    String? path,
    Future<Uint8List> Function(Uint8List data)? process,
  }) {
    if (path?.isNotEmpty == true) {
      this.path = path!;
    }
    if (process != null) {
      this.process = process;
    }
    return this;
  }

  Future<List<Dependency>> get(BuildContext context) async {
    if (dependencies.isNotEmpty) {
      return dependencies;
    }
    try {
      final data = await DefaultAssetBundle.of(context).load(
        path,
      );

      var content =
          String.fromCharCodes(await process(data.buffer.asUint8List()));
      final jsonResult = jsonDecode(content);

      for (dynamic value in (jsonResult['dependencies'] as Map).values) {
        try {
          dependencies.add(Dependency().fromJson(value));
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return dependencies;
  }

  Future<List<Dependency>> getAndroidDependencies(BuildContext context) async {
    final dependencies = await get(context);
    dependencies.removeWhere((element) => !element.supportsAndroid);
    return dependencies;
  }

  Future<List<Dependency>> getIOSDependencies(BuildContext context) async {
    final dependencies = await get(context);
    dependencies.removeWhere((element) => !element.supportsIOS);
    return dependencies;
  }

  Future<List<Dependency>> getWebDependencies(BuildContext context) async {
    final dependencies = await get(context);
    dependencies.removeWhere((element) => !element.supportsWeb);
    return dependencies;
  }

  Future<List<Dependency>> getMacOSDependencies(BuildContext context) async {
    final dependencies = await get(context);
    dependencies.removeWhere((element) => !element.supportsMacOS);
    return dependencies;
  }

  Future<List<Dependency>> getWindowsDependencies(BuildContext context) async {
    final dependencies = await get(context);
    dependencies.removeWhere((element) => !element.supportsWindows);
    return dependencies;
  }

  Future<List<Dependency>> getLinuxDependencies(BuildContext context) async {
    final dependencies = await get(context);
    dependencies.removeWhere((element) => !element.supportsLinux);
    return dependencies;
  }
}
