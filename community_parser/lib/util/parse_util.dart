final _pureReousrceUrlRegexp_1 = RegExp(
  r'url=(?<url>[\S][^?]+)?',
  caseSensitive: false,
);

final _pureReousrceUrlRegexp_2 = RegExp(
  r'(?<url>[\S][^?]+)?',
  caseSensitive: false,
);

String getPureResourceImage(String url) {
  var findUrl = _pureReousrceUrlRegexp_1.firstMatch(url);
  var resourceUrl = findUrl?.namedGroup('url') ?? '';
  if (resourceUrl.isNotEmpty) {
    return resourceUrl;
  }

  findUrl = _pureReousrceUrlRegexp_2.firstMatch(url);
  resourceUrl = findUrl?.namedGroup('url') ?? '';
  return resourceUrl;
}
