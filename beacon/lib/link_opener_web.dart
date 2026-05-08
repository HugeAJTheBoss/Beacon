// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
// Web-only implementation. Opens the URL in a new tab via window.open and
// reports success. Pulled in via conditional import when dart.library.html is
// available (i.e. running on Flutter Web).
import 'dart:html' as html;

Future<bool> openInBrowserTab(String url) async {
  html.window.open(url, '_blank');
  return true;
}
