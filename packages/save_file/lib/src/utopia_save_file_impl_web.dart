import 'dart:html' as html;

class UtopiaSaveFileImpl {
  static Future<bool> fromUrl(String url, {String? name}) async {
    html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
    return true;
  }
}