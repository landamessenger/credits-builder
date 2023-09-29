class Dependency {
  String id;
  String repository;
  String licenseType;
  String licenseContent;
  String publisher;
  String currentVersion;
  String version;
  bool supportsAndroid;
  bool supportsIOS;
  bool supportsMacOS;
  bool supportsWindows;
  bool supportsLinux;
  bool supportsWeb;

  Dependency({
    this.id = '',
    this.repository = '',
    this.licenseType = '',
    this.licenseContent = '',
    this.publisher = '',
    this.currentVersion = '',
    this.version = '',
    this.supportsAndroid = false,
    this.supportsIOS = false,
    this.supportsMacOS = false,
    this.supportsWindows = false,
    this.supportsLinux = false,
    this.supportsWeb = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'repository': repository,
        'licenseType': licenseType,
        'licenseContent': licenseContent,
        'publisher': publisher,
        'currentVersion': currentVersion,
        'version': version,
        'supportsAndroid': supportsAndroid,
        'supportsIOS': supportsIOS,
        'supportsMacOS': supportsMacOS,
        'supportsWindows': supportsWindows,
        'supportsLinux': supportsLinux,
        'supportsWeb': supportsWeb,
      };

  Dependency fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    repository = json['repository'] ?? '';
    licenseType = json['licenseType'] ?? '';
    licenseContent = json['licenseContent'] ?? '';
    publisher = json['publisher'] ?? '';
    currentVersion = json['currentVersion'] ?? '';
    version = json['version'] ?? '';
    supportsAndroid = json['supportsAndroid'] ?? false;
    supportsIOS = json['supportsIOS'] ?? false;
    supportsMacOS = json['supportsMacOS'] ?? false;
    supportsWindows = json['supportsWindows'] ?? false;
    supportsLinux = json['supportsLinux'] ?? false;
    supportsWeb = json['supportsWeb'] ?? false;
    return this;
  }

  bool isUpToDate() =>
      currentVersion.endsWith(version) ||
      currentVersion == 'flutter' ||
      currentVersion == 'git' ||
      currentVersion == 'local';
}
