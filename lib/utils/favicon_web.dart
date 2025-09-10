// Web implementation for updating the favicon dynamically.
// Uses conditional import from favicon.dart, only compiled on web.
import 'package:web/web.dart' as web;

void setFaviconHref(String href) {
  try {
    final normalized = _normalizeFaviconHref(href);
    final existing = web.document.querySelector('link[rel="icon"]');
    if (existing is web.HTMLLinkElement) {
      existing.href = normalized;
      existing.type = _inferMimeType(normalized);
      return;
    }

    final el = web.document.createElement('link');
    if (el is web.HTMLLinkElement) {
      el.rel = 'icon';
      el.type = _inferMimeType(normalized);
      el.href = normalized;
      web.document.head?.append(el);
    } else {
      // Fallback: set attributes via generic Element API
      el.setAttribute('rel', 'icon');
      el.setAttribute('type', _inferMimeType(normalized));
      el.setAttribute('href', normalized);
      web.document.head?.append(el);
    }
  } catch (_) {
    // Silently ignore failures; favicon is non-critical.
  }
}

String _inferMimeType(String href) {
  final lower = href.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.ico')) return 'image/x-icon';
  if (lower.endsWith('.svg')) return 'image/svg+xml';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return 'image/png';
}

String _normalizeFaviconHref(String href) {
  final lower = href.toLowerCase();
  // Leave absolute URLs unchanged
  if (lower.startsWith('http://') || lower.startsWith('https://') || lower.startsWith('data:')) {
    return href;
  }
  // If it's already in the built web asset form, keep as-is
  if (lower.startsWith('assets/assets/')) {
    return href;
  }
  // Flutter serves packaged assets under /assets/, preserving the original subpath.
  // So a Flutter asset path like 'assets/logo.png' becomes 'assets/assets/logo.png' on web.
  if (lower.startsWith('assets/')) {
    return 'assets/' + href;
  }
  // Otherwise return unchanged (supports custom relative paths placed next to index.html)
  return href;
}


