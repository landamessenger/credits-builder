import '../scrapers/platform.dart';

bool supportAndroid(String content) {
  try {
    return platformSupport('android', content);
  } catch (e) {
    return false;
  }
}

bool supportIOS(String content) {
  try {
    return platformSupport('ios', content);
  } catch (e) {
    return false;
  }
}

bool supportMacOS(String content) {
  try {
    return platformSupport('macos', content);
  } catch (e) {
    return false;
  }
}

bool supportWeb(String content) {
  try {
    return platformSupport('web', content);
  } catch (e) {
    return false;
  }
}

bool supportWindows(String content) {
  try {
    return platformSupport('windows', content);
  } catch (e) {
    return false;
  }
}

bool supportLinux(String content) {
  try {
    return platformSupport('linux', content);
  } catch (e) {
    return false;
  }
}
