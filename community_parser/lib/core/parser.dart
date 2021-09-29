import 'package:community_parser/core/site_cookie.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:community_parser/util/get_document.dart';

import 'site_define.dart' as site_define;
import 'content_element.dart';

SiteCookie _siteCookie = SiteCookie();

/// Uri로부터 DocumentStatus를 가져온다.
/// - Cookie 정보를 Request에 넣어서 보낸다.
/// - Response로 온 Cookie 정보를 업데이트 한다.
Future<DocumentStatus> _getDocumentStatus(
  Uri uri,
  site_define.SiteType siteType,
) async {
  var siteMeta = site_define.getSiteMeta(siteType: siteType);
  if (siteMeta == null) {
    throw ArgumentError('siteType = $siteType is SiteMeta not implement');
  }

  final siteDomain = siteMeta.siteDomain;
  final cookieValue = _siteCookie.getCookieValue(siteDomain);

  var headers = <String, String>{'cookie': cookieValue};

  final documentResult = await getDocument(uri, headers: headers);
  if (documentResult.statueType != StatusType.OK) {
    throw ArgumentError('getDocument failed');
  }

  _siteCookie.updateCookie(siteDomain, documentResult.cookies);

  return documentResult;
}

String _findRefreshUrl(Document document) {
  // redirect 체크
  var refreshMetas = document.querySelectorAll('meta');
  if (refreshMetas.isEmpty) {
    return '';
  }

  var content = '';
  for (var meta in refreshMetas) {
    if (meta.attributes.containsKey('http-equiv') == false ||
        meta.attributes.containsKey('content') == false) {
      continue;
    }

    var equivValue = meta.attributes['http-equiv']?.toLowerCase() ?? '';
    if (equivValue != 'refresh') {
      continue;
    }

    content = meta.attributes['content'] ?? '';
    break;
  }

  final urlRegexp = RegExp(r'url.?=.?(?<url>.+)');
  final matched = urlRegexp.firstMatch(content);
  if (matched == null) {
    return '';
  }

  return matched.namedGroup('url') ?? '';
}

Future<Document> _getDocument(
  Uri uri,
  site_define.SiteType siteType,
) async {
  try {
    var documentStatus = await _getDocumentStatus(uri, siteType);
    var document = html_parser.parse(documentStatus.documentBody);

    // redirect 체크
    var redirectUrl = _findRefreshUrl(document);
    if (redirectUrl.isEmpty == true) {
      return document;
    }

    var redirectFullUrl = uri.origin;
    for (var segment in uri.pathSegments) {
      if (uri.pathSegments.indexOf(segment) == uri.pathSegments.length - 1) {
        if (segment.contains('.') == true) {
          continue;
        }
      }

      redirectFullUrl += '/$segment';
    }

    redirectFullUrl += '/$redirectUrl';
    documentStatus = await _getDocumentStatus(
      Uri.parse(redirectFullUrl),
      siteType,
    );

    document = html_parser.parse(documentStatus.documentBody);
    return document;
  } catch (e) {
    rethrow;
  }
}

/// PostParser
/// - Post 본문을 Parsing을 수행한다.
/// - dom형식으로 파싱하고, tree구조를 최적화 해야한다.
/// - tree 구조 최적화 형식은 PostElement을 상속 받은 클래스에서 구현
class PostParser {
  static Future<T?> parse<T extends PostElement>(
    String postId, {
    String subUrl = '',
    Map<String, String>? query,
    bool needQuestionMark = false,
  }) async {
    var siteType = site_define.getSiteType<T>();
    var uri = site_define.getPostUri(
      siteType: siteType,
      postId: postId,
      subUrl: subUrl,
      query: query,
      needQuestionMark: needQuestionMark,
    );

    var document = await _getDocument(uri, siteType);
    if (document.body == null) {
      return null;
    }

    final rootElement =
        site_define.getPostRootElement(siteType, document: document);

    var root = site_define.getPostElementInstance(siteType);
    root?.parseRoot(rootElement);

    return root as T?;
  }
}

/// PostCommentParser
/// - Comment내용을 parsing한다.
/// - PostCommnetItem을 상속받은 클래스에서 CommentRoot Element를 기준으로 QuerySelector를 수행하여 요소를 찾는다.
class PostCommentParser {
  /// Page가 존재 하지않는 CommentList 인 사이트 일 경우 호출
  static Future<List<T>> parseForSingle<T extends PostCommentItem>(
    String postId, {
    String subUrl = '',
    Map<String, String>? query,
    bool needQuestionMark = false,
  }) async {
    var siteType = site_define.getSiteType<T>();

    var uri = site_define.getCommentUri(
      siteType: siteType,
      postId: postId,
      subUrl: subUrl,
      query: query,
      needQuestionMark: needQuestionMark,
    );

    return await _parseCommentUnit<T>(siteType, uri);
  }

  /// Page가 존재하는 CommentList 인 사이트 일 경우 호출
  static Future<List<T>> parseForPage<T extends PostCommentItem>(
    String postId, {
    String subUrl = '',
    Map<String, String>? query,
    bool needQuestionMark = false,
  }) async {
    var siteType = site_define.getSiteType<T>();
    var siteMeta = site_define.getSiteMeta(siteType: siteType);
    if (siteMeta == null) {
      throw ArgumentError('getSiteMeta Failed');
    }

    var uri = site_define.getCommentUri(
      siteType: siteType,
      postId: postId,
      subUrl: subUrl,
      query: query,
      needQuestionMark: needQuestionMark,
    );

    if (siteMeta.isExistCommentPage == false) {
      return await _parseCommentUnit<T>(siteType, uri);
    }

    // 댓글 현재페이지/ 전체 페이지 갯수 가져오기
    var pageTuple = await siteMeta.getCommentPageCount(uri);
    final defaultPageIndex = pageTuple.item1;
    final totalPagecount = pageTuple.item2;

    var totalPageCommentItems = <T>[];

    // defaultPage 외에 CommentItems들을 가져온다.
    for (var pageIndex = 0; pageIndex < totalPagecount; pageIndex++) {
      var commentPageUrl =
          siteMeta.getCommentPageUrl(pageIndex, postId: postId);

      if (commentPageUrl == null) {
        continue;
      }

      var anotherCommnetItems =
          await _parseCommentUnit<T>(siteType, commentPageUrl);

      if (anotherCommnetItems.isEmpty) {
        continue;
      }

      totalPageCommentItems.addAll(anotherCommnetItems);
    }

    return totalPageCommentItems;
  }

  static Future<List<T>> _parseCommentUnit<T extends PostCommentItem>(
    site_define.SiteType siteType,
    Uri commentPageUrl,
  ) async {
    var result = <T>[];

    var document = await _getDocument(commentPageUrl, siteType);
    if (document.body == null) {
      return result;
    }

    document = site_define.getPostCommentDocument(
      siteType: siteType,
      commentDocument: document,
    );

    final commentElements = site_define.getPostCommentListElements(
      siteType: siteType,
      document: document,
    );

    for (var commentElement in commentElements) {
      final comment = site_define.getPostCommentInstance<T>();
      if (comment == null) {
        break;
      }

      if (comment.parseRoot(commentElement) == false) {
        continue;
      }

      result.add(comment as T);
    }

    return result;
  }
}

/// Comment의 정보를 모두 담는다.
/// - 작성자 icon, 이름, 좋아요, 싫어요 등등..
/// - CommentContent는 Comment 내용을 구조화한다 것이다.
abstract class PostCommentItem {
  var reComment = false;

  var authorIconUrl = '';
  var authorName = '';
  var commentGoodCount = 0;
  var commentBadCount = 0;
  String commentWriteDatetime = '';

  CommentContent? commentContent;

  bool parseRoot(Element element) {
    init(element);

    reComment = parseReComment(element);

    authorIconUrl = parseAuthorIconUrl(element);
    authorName = parseAuthorName(element);

    final contentElement = getCommentContentElement(element);

    commentContent = createCommentContent();
    commentContent!.parseRoot(contentElement);

    commentGoodCount = parseCommentGoodCount(element);
    commentBadCount = parseCommentBadCount(element);

    commentWriteDatetime = parseCommentWriteDatetime(element);

    parseCommentEtc(element);

    return true;
  }

  void init(Element element) {}

  bool parseReComment(Element element);
  String parseAuthorIconUrl(Element element);
  String parseAuthorName(Element element);

  CommentContent createCommentContent();
  Element? getCommentContentElement(Element element);

  int parseCommentGoodCount(Element element);
  int parseCommentBadCount(Element element);

  String parseCommentWriteDatetime(Element element);

  void parseCommentEtc(Element element) {}
}

/// PostListParser
/// - 게시물 리스트의 각 항목의 요소들을 Parsing한다.
/// - PostListItemParser를 상속 받아서 처리한다.
/// - 각 사이트 별로, 게시물 리스트로부터 항목 요소 Parsing부분,<br>
///   본몬으로부터 항목 요소 Parsing부분을 구현하여 한다.
/// - 항목 요소는 PostListItem을 반환(전 사이트 공통)
class PostListParser {
  static Future<List<PostListItem>> parse<T extends PostListItemParser>({
    required int pageIndex,
    String subUrl = '',
    Map<String, String>? query,
  }) async {
    final siteType = site_define.getSiteType<T>();

    var uri = site_define.getPageUri(
      siteType: siteType,
      query: query,
      subUrl: subUrl,
      pageIndex: pageIndex,
    );

    var document = await _getDocument(uri, siteType);

    final subjectElements = site_define.getPagePostListElements(
      siteType: siteType,
      document: document,
    );

    var result = <PostListItem>[];
    for (var subjectElement in subjectElements) {
      var postListItem = PostListItem();

      final parser = site_define.getPostListItemParser(
        siteType,
        document: document,
        isFromBody: false,
      );

      if (parser == null) {
        break;
      }

      if (postListItem.parseRoot(subjectElement, parser: parser) == false) {
        continue;
      }

      result.add(postListItem);
    }

    return result;
  }

  static Future<PostListItem?> parseFromPostBody<T extends PostListItemParser>(
    String postId, {
    String subUrl = '',
    Map<String, String>? query,
    bool needQuestionMark = false,
  }) async {
    final siteType = site_define.getSiteType<T>();
    final siteMeta = site_define.getSiteMeta(siteType: siteType);

    if (siteMeta == null) {
      throw ArgumentError('siteType : $siteType is not implements');
    }

    var uri = site_define.getPostUri(
      siteType: siteType,
      postId: postId,
      subUrl: subUrl,
      query: query,
      needQuestionMark: needQuestionMark,
    );

    var document = await _getDocument(uri, siteType);
    if (document.body == null) {
      throw ArgumentError('siteType : $siteType, uri($uri) document is wroung');
    }

    Element? postBodyRootElement;

    try {
      postBodyRootElement = site_define.getPostAuthorElement(
        siteType: siteType,
        document: document,
      );
    } catch (e) {
      // isRefreshCookieRequest Cookie 갱신 된 상태에서 다시 Request
      if (siteMeta.isRefreshCookieRequest == false) {
        rethrow;
      }

      var document = await _getDocument(uri, siteType);
      if (document.body == null) {
        throw ArgumentError(
            'siteType : $siteType, uri($uri) document is wroung');
      }

      postBodyRootElement = site_define.getPostAuthorElement(
        siteType: siteType,
        document: document,
      );
    }

    if (postBodyRootElement == null) {
      throw ArgumentError(
        'siteType : $siteType, uri($uri) document is wroung (postBodyRootElement is null)',
      );
    }

    var postListItem = PostListItem();

    final parser = site_define.getPostListItemParser(
      siteType,
      document: document,
      isFromBody: true,
    );

    if (parser == null) {
      throw ArgumentError(
          'siteType : $siteType is PostListItemParser not implement');
    }

    if (postListItem.parseRoot(postBodyRootElement, parser: parser) == false) {
      throw ArgumentError('${T.runtimeType} parseRoot is Failed');
    }

    return postListItem;
  }
}

/// 게시글 리스트에서 게시글 항목에 대한 파싱을 담당한다.
/// - PostListItem의 ParseRoot로 PostListItemParser의 구현체가 넘겨지게 된다.
abstract class PostListItemParser {
  late Document _document;

  Document get document {
    return _document;
  }

  PostListItemParser(Document docuemnt) {
    _document = docuemnt;
  }

  bool isPostListItem(Element element) {
    return true;
  }

  void init(Element element) {}

  String parsePostId(Element element);
  String parseBodyUrl(Element element);

  String parseThumbnailUrl(Element element);
  String parseSubject(Element element);

  String parseAuthorIconUrl(Element element);
  String parseAuthorName(Element element);

  int parseCommentCount(Element element);
  int parseViewCount(Element element);
  int parseGoodCount(Element element);
  int parseBadCount(Element element);

  String parseWriteDateTime(Element element);

  dynamic parseExtraData_1(Element element) {
    return null;
  }

  dynamic parseExtraData_2(Element element) {
    return null;
  }
}

/// 게시글 리스트에서 게시글 항목에 대한 정보를 담는다.
/// - PostListItemParser로 부터 정보를 가져오게 된다.
class PostListItem {
  var postId = '';
  var postBodyUrl = '';

  var thumbnailUrl = '';
  var subject = '';
  var authorIconUrl = '';
  var authorName = '';

  var commentCount = 0;
  var viewCount = 0;
  var goodCount = 0;
  var badCount = 0;

  dynamic extraData_1;
  dynamic extraData_2;

  String writeDateTime = '';

  bool get isEmpty {
    if (postBodyUrl.isEmpty || subject.isEmpty) {
      return true;
    }

    return false;
  }

  bool parseRoot(
    Element element, {
    required PostListItemParser parser,
  }) {
    //
    _parseWarp(parser.init, element: element);

    postId = _parseWarp<String>(parser.parsePostId, element: element) ?? '';

    postBodyUrl =
        _parseWarp<String>(parser.parseBodyUrl, element: element) ?? '';
    if (postBodyUrl.isEmpty) {
      return false;
    }

    thumbnailUrl =
        _parseWarp<String>(parser.parseThumbnailUrl, element: element) ?? '';
    subject = _parseWarp<String>(parser.parseSubject, element: element) ?? '';
    authorIconUrl =
        _parseWarp<String>(parser.parseAuthorIconUrl, element: element) ?? '';
    authorName =
        _parseWarp<String>(parser.parseAuthorName, element: element) ?? '';

    commentCount =
        _parseWarp<int>(parser.parseCommentCount, element: element) ?? 0;
    viewCount = _parseWarp<int>(parser.parseViewCount, element: element) ?? 0;
    goodCount = _parseWarp<int>(parser.parseGoodCount, element: element) ?? 0;
    badCount = _parseWarp<int>(parser.parseBadCount, element: element) ?? 0;

    writeDateTime =
        _parseWarp<String>(parser.parseWriteDateTime, element: element) ?? '';

    extraData_1 =
        _parseWarp<dynamic>(parser.parseExtraData_1, element: element);
    extraData_2 =
        _parseWarp<dynamic>(parser.parseExtraData_2, element: element);

    return true;
  }

  T? _parseWarp<T>(
    Function(Element) parseFunc, {
    required Element element,
  }) {
    try {
      return parseFunc(element);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
