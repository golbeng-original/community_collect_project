import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cp949/cp949.dart' as cp949;
import 'package:http/http.dart' as http;

enum StatusType {
  OK,
  NotFound,
  BodyException,
}

/// Document의 body 정보 및 Cookie 내용을 가져온다.
/// - Header 내용 중 Encoding 정보를 찾아서 cp949, utf-8 Decoding 할지를 정한다.
class DocumentStatus {
  StatusType statueType = StatusType.NotFound;
  String documentBody = '';
  final Exception? exception;

  Map<String, String> cookies = {};

  DocumentStatus({
    required this.statueType,
    required this.documentBody,
    this.exception,
  });

  factory DocumentStatus.notFoundStatus() {
    return DocumentStatus(statueType: StatusType.NotFound, documentBody: '');
  }

  factory DocumentStatus.exception(Exception e) {
    return DocumentStatus(
        statueType: StatusType.BodyException, documentBody: '', exception: e);
  }

  factory DocumentStatus.success(String body) {
    return DocumentStatus(statueType: StatusType.OK, documentBody: body);
  }
}

RegExp _charsetReg = RegExp(
  r'charset=(?<language>.+)',
  caseSensitive: false,
);
RegExp _metaCharsetReg = RegExp(
  r'^<meta charset=\"(?<language>.+)\">$',
  multiLine: true,
  caseSensitive: false,
);
RegExp _metaContentTypeReg = RegExp(
  r'^<meta http-equiv=\"(?<key>.+)\" content=\"(?<value>.+)\">$',
  multiLine: true,
  caseSensitive: false,
);
RegExp _contentCharsetReg = RegExp(
  r'charset=(?<language>.+)',
  caseSensitive: false,
);

String _findDocumentLanguage(http.Response response) {
  var language = 'utf-8';

  // 1. header 에서 charset 찾기
  final headers = response.headers;
  if (headers.containsKey('content-type') == true) {
    final contentTypeValue = headers['content-type'];

    final matched = _charsetReg.firstMatch(contentTypeValue ?? '');
    if (matched != null) {
      language = matched.namedGroup('language') ?? '';
      return language.toLowerCase();
    }
  }

  // 2. meta charset에서 찾기
  final matchedMetaCharset = _metaCharsetReg.firstMatch(response.body);
  if (matchedMetaCharset != null) {
    language = matchedMetaCharset.namedGroup('language') ?? '';
    return language.toLowerCase();
  }

  // 3. meta http-equiv에서 찾기
  final matches = _metaContentTypeReg.allMatches(response.body);
  for (var match in matches) {
    //print(match.group(0));

    final metaKey = match.namedGroup('key');
    if (metaKey?.toLowerCase() != 'content-type') {
      continue;
    }

    final metaValue = match.namedGroup('value') ?? '';
    final languageMatch = _contentCharsetReg.firstMatch(metaValue);
    if (languageMatch != null) {
      language = languageMatch.namedGroup('language') ?? '';
      return language.toLowerCase();
    }
    break;
  }

  return language;
}

Future<DocumentStatus> getDocument(
  Uri uri, {
  Map<String, String>? headers,
}) async {
  var resposne = await http.get(uri, headers: headers);

  if (resposne.statusCode != 200) {
    return DocumentStatus.notFoundStatus();
  }

  // 쿠키 정보 가져오기
  var cookieMap = _getCookie(resposne.headers);

  try {
    final language = _findDocumentLanguage(resposne);

    String body;
    switch (language) {
      case 'euc-kr':
        body = cp949.decode(resposne.bodyBytes);
        break;
      default:
        body = utf8.decode(resposne.bodyBytes);
        break;
    }

    var documentStatus = DocumentStatus.success(body);
    documentStatus.cookies = cookieMap;

    return documentStatus;
  } on Exception catch (e) {
    return DocumentStatus.exception(e);
  }
}

Future<DocumentStatus> headRequest(
  Uri uri, {
  Map<String, String>? headers,
}) async {
  var resposne = await http.head(uri, headers: headers);

  if (resposne.statusCode != 200) {
    return DocumentStatus.notFoundStatus();
  }

  // 쿠키 정보 가져오기
  var cookieMap = _getCookie(resposne.headers);

  var documentStatus = DocumentStatus.success('');
  documentStatus.cookies = cookieMap;

  return documentStatus;
}

final domainRegexp = RegExp(r'domain=(.+?),(?<kv>.+)');
final pathRegexp = RegExp(r'path=(.+?),(?<kv>.+)');

Map<String, String> _getCookie(Map<String, String>? header) {
  if (header == null) {
    return <String, String>{};
  }

  if (header.containsKey('set-cookie') == false) {
    return <String, String>{};
  }

  var cookieMap = <String, String>{};

  var cookieText = header['set-cookie'] ?? '';
  var cookieSplit = cookieText.split(';');

  for (var cookieElement in cookieSplit) {
    var matched = domainRegexp.firstMatch(cookieElement);
    if (matched != null) {
      var cookieSource = matched.namedGroup('kv') ?? '';
      var cookieKeyValue = _getCookieValue(cookieSource);

      if (cookieKeyValue != null) {
        cookieMap[cookieKeyValue.key] = cookieKeyValue.value;
      }
      continue;
    }

    matched = pathRegexp.firstMatch(cookieElement);
    if (matched != null) {
      var cookieSource = matched.namedGroup('kv') ?? '';
      var cookieKeyValue = _getCookieValue(cookieSource);
      if (cookieKeyValue != null) {
        cookieMap[cookieKeyValue.key] = cookieKeyValue.value;
      }
      continue;
    }
  }

  return cookieMap;
}

MapEntry<String, String>? _getCookieValue(String cookieValue) {
  var keyValue = cookieValue.split('=');
  if (keyValue.length != 2) {
    return null;
  }

  return MapEntry(keyValue[0], keyValue[1]);
}
