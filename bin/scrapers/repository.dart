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
