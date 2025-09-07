import 'dart:core';

/// Hilfsfunktionen, um externe Links sicher zu öffnen.
class LinkSanitizer {
  static const _blockHosts = {
    'example.com',
    'www.example.com',
    'example.org',
    'www.example.org',
    'test.com',
    'localhost',
  };

  /// Normalisiert Nutzer/Feed-URLs:
  /// - DOI-Präfixe -> https://doi.org/<doi>
  /// - http -> https
  /// - Fügt https hinzu, wenn kein Schema vorhanden
  /// - Blockiert bekannte Platzhalter
  static Uri? normalizeForLaunch(String raw) {
    var url = raw.trim();

    // DOI-Shortcuts abfangen
    if (url.toLowerCase().startsWith('doi:')) {
      final doi = url.substring(4).trim();
      if (doi.isNotEmpty) {
        url = 'https://doi.org/$doi';
      }
    }

    // Fehlende Schemas zulassen (z. B. "nature.com/...") -> https ergänzen
    if (!url.contains('://')) {
      url = 'https://$url';
    }

    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      return null;
    }

    if (!uri.hasScheme || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }

    // Immer https bevorzugen
    if (uri.scheme == 'http') {
      uri = uri.replace(scheme: 'https');
    }

    final host = (uri.host).toLowerCase();
    if (_blockHosts.contains(host)) {
      return null;
    }

    return uri;
  }
}
