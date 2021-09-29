/// domain 별로 Cookie를 관리한다.
class SiteCookie {
  final _setCookies = <String, Map<String, String>>{};

  void updateCookie(String domain, Map<String, String> cookies) {
    if (_setCookies.containsKey(domain) == false) {
      _setCookies[domain] = <String, String>{};
    }

    _setCookies[domain]!.addAll(cookies);
  }

  String getCookieValue(String domain) {
    if (_setCookies.containsKey(domain) == false) {
      return '';
    }

    final cookies = _setCookies[domain]!;
    if (cookies.isEmpty) {
      return '';
    }

    var cookieHeader = '';
    for (var key in cookies.keys) {
      cookieHeader += '$key=${cookies[key]};';
    }

    return cookieHeader;
  }
}
