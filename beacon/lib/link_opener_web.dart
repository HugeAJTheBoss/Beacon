import 'dart:html' as html;

Future<bool> openInBrowserTab(String url) async {
  html.window.open(url, '_blank');
  return true;
}
