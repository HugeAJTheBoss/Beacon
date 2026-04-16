// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
// web-only implementation that uses dart:html and opens a new browser tab, then returns true.
import 'dart:html' as html;

Future<bool> openInBrowserTab(String url) async {
  html.window.open(url, '_blank');
  return true;
}
