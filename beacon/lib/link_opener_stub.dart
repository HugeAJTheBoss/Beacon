// Non-web fallback. The real implementation lives in link_opener_web.dart and
// is selected via conditional import on web. Returning false here lets callers
// fall back to url_launcher on mobile/desktop.
Future<bool> openInBrowserTab(String url) async {
  return false;
}
