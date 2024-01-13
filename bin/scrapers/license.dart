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
