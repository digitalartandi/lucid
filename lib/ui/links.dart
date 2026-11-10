// lib/ui/links.dart
import 'package:url_launcher/url_launcher.dart';

import '../services/link_sanitizer.dart';

/// Öffnet einen externen Link im Browser. Gibt false zurück, wenn es nicht ging.
Future<bool> openExternal(String url) async {
  final Uri? uri = LinkSanitizer.normalizeForLaunch(url);
  if (uri == null) return false;
  try {
    return await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (_) {
    return false;
  }
}
