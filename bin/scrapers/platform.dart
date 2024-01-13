bool platformSupport(String platformId, String content) {
  try {
    String a = content.split('<span class="tag-badge-main">Plat')[1];
    String b = a.split('</div>')[0];
    return b.contains('%3A$platformId"');
  } catch (e) {
    return false;
  }
}
