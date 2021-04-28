import 'dart:convert';
import 'package:meta/meta.dart';

import 'package:cp949/cp949.dart' as cp949;
import 'package:http/http.dart' as http;

enum StatusType {
  OK,
  NotFound,
  BodyException,
}

class DocumentStatus {
  StatusType statueType = StatusType.NotFound;
  String documentBody = '';
  Exception exception;

  DocumentStatus({
    @required this.statueType,
    @required this.documentBody,
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
      language = matched.namedGroup('language');
      return language.toLowerCase();
    }
  }

  // 2. meta charset에서 찾기
  final matchedMetaCharset = _metaCharsetReg.firstMatch(response.body);
  if (matchedMetaCharset != null) {
    language = matchedMetaCharset.namedGroup('language');
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

    final metaValue = match.namedGroup('value');
    final languageMatch = _contentCharsetReg.firstMatch(metaValue);
    if (languageMatch != null) {
      language = languageMatch.namedGroup('language');
      return language.toLowerCase();
    }
    break;
  }

  return language;
}

Future<DocumentStatus> getDocument(Uri uri) async {
  var resposne = await http.get(uri);

  if (resposne.statusCode != 200) {
    return DocumentStatus.notFoundStatus();
  }

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

    return DocumentStatus.success(body);
  } on Exception catch (e) {
    return DocumentStatus.exception(e);
  }
}
