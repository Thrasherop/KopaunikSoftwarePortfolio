import 'favicon_stub.dart' if (dart.library.html) 'favicon_web.dart' as platform;

void setFaviconHref(String href) => platform.setFaviconHref(href);


