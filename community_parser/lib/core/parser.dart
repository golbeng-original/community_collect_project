import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'package:community_parser/util/get_document.dart';

import 'site_define.dart' as site_define;
import 'content_element.dart';

/// PostParser
/// - Post 본문을 Parsing을 수행한다.
/// - dom형식으로 파싱하고, tree구조를 최적화 해야한다.
/// - tree 구조 최적화 형식은 PostElement을 상속 받은 클래스에서 구현
class PostParser {
  static Future<PostElement> parse<T extends PostElement>(
    String postId, {
    String subUrl = '',
    Map<String, String> query,
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
    if (uri == null) {
      throw ArgumentError('getPostUrl Failed');
    }

    final documentResult = await getDocument(uri);
    if (documentResult.statueType != StatusType.OK) {
      throw ArgumentError('getDocument($uri) is status not ok');
    }

    final document = html_parser.parse(documentResult.documentBody);

    final rootElement =
        site_define.getPostRootElement(siteType, document: document);

    var root = site_define.getPostElementInstance(siteType);
    root?.parseRoot(rootElement);

    return root;
  }
}

/// PostCommentParser
/// - Comment내용을 parsing한다.
/// - PostCommnetItem을 상속받은 클래스에서 CommentRoot Element를 기준으로 QuerySelector를 수행하여 요소를 찾는다.
class PostCommentParser {
  /// Page가 존재 하지않는 CommentList 인 사이트 일 경우 호출
  static Future<List<PostCommentItem>>
      parseForSingle<T extends PostCommentItem>(
    String postId, {
    String subUrl = '',
    Map<String, String> query,
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
    if (uri == null) {
      throw ArgumentError('getPostUrl Failed');
    }

    return await _parseCommentUnit(siteType, uri);
  }

  /// Page가 존재하는 CommentList 인 사이트 일 경우 호출
  static Future<List<PostCommentItem>> parseForPage<T extends PostCommentItem>(
    String postId, {
    String subUrl = '',
    Map<String, String> query,
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
    if (uri == null) {
      throw ArgumentError('getPostUrl Failed');
    }

    if (siteMeta.isExistCommentPage == false) {
      return await _parseCommentUnit(siteType, uri);
    }

    // 댓글 현재페이지/ 전체 페이지 갯수 가져오기
    var pageTuple = await siteMeta.getCommentPageCount(uri);
    final defaultPageIndex = pageTuple.item1;
    final totalPagecount = pageTuple.item2;

    var totalPageCommentItems = <PostCommentItem>[];
    // defaultPage 외에 CommentItems들을 가져온다.
    for (var pageIndex = 0; pageIndex < totalPagecount; pageIndex++) {
      var commentPageUrl =
          siteMeta.getCommentPageUrl(pageIndex, postId: postId);

      var anotherCommnetItems =
          await _parseCommentUnit(siteType, commentPageUrl);

      if (anotherCommnetItems == null) {
        continue;
      }

      totalPageCommentItems.addAll(anotherCommnetItems);
    }

    return totalPageCommentItems;
  }

  static Future<List<PostCommentItem>>
      _parseCommentUnit<T extends PostCommentItem>(
    site_define.SiteType siteType,
    Uri commentPageUrl,
  ) async {
    final documentResult = await getDocument(commentPageUrl);
    if (documentResult.statueType != StatusType.OK) {
      throw ArgumentError('getDocument($commentPageUrl) is status not ok');
    }

    final document = site_define.getPostCommentDocument(
      siteType: siteType,
      documentString: documentResult.documentBody,
    );

    final commentElements = site_define.getPostCommentListElements(
      siteType: siteType,
      document: document,
    );

    var result = <PostCommentItem>[];
    for (var commentElement in commentElements) {
      final comment = site_define.getPostCommentInstance(siteType);
      if (comment == null) {
        break;
      }

      if (comment.parseRoot(commentElement) == false) {
        continue;
      }

      result.add(comment);
    }

    return result;
  }
}

abstract class PostCommentItem {
  var reComment = false;

  var authorIconUrl = '';
  var authorName = '';

  CommentContent commentContent;

  var commentGoodCount = 0;
  var commentBadCount = 0;

  String commentWriteDatetime;

  bool parseRoot(Element element) {
    reComment = parseReComment(element);

    authorIconUrl = parseAuthorIconUrl(element);
    authorName = parseAuthorName(element);

    commentContent = createCommentContent();
    final contentElement = getCommentContentElement(element);
    commentContent.parseRoot(contentElement);

    commentGoodCount = parseCommentGoodCount(element);
    commentBadCount = parseCommentBadCount(element);

    commentWriteDatetime = parseCommentWriteDatetime(element);

    return true;
  }

  bool parseReComment(Element element);
  String parseAuthorIconUrl(Element element);
  String parseAuthorName(Element element);

  CommentContent createCommentContent();
  Element getCommentContentElement(Element element);

  int parseCommentGoodCount(Element element);
  int parseCommentBadCount(Element element);

  String parseCommentWriteDatetime(Element element);
}

/// PostListParser
/// - 게시물 리스트의 각 항목의 요소들을 Parsing한다.
/// - PostListItemParser를 상속 받아서 처리한다.
/// - 각 사이트 별로, 게시물 리스트로부터 항목 요소 Parsing부분,<br>
///   본몬으로부터 항목 요소 Parsing부분을 구현하여 한다.
/// - 항목 요소는 PostListItem을 반환(전 사이트 공통)
class PostListParser {
  static Future<List<PostListItem>> parse<T extends PostListItemParser>({
    @required int pageIndex,
    String subUrl = '',
    Map<String, String> query,
  }) async {
    final siteType = site_define.getSiteType<T>();

    var uri = site_define.getPageUri(
      siteType: siteType,
      query: query,
      subUrl: subUrl,
      pageIndex: pageIndex,
    );
    if (uri == null) {
      throw ArgumentError('T is not define');
    }

    final documentResult = await getDocument(uri);
    if (documentResult.statueType != StatusType.OK) {
      throw ArgumentError('getDocument($uri) status is not ok');
    }

    final document = html_parser.parse(documentResult.documentBody);

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

  static Future<PostListItem> parseFromPostBody<T extends PostListItemParser>(
    String postId, {
    String subUrl = '',
    Map<String, String> query,
    bool needQuestionMark = false,
  }) async {
    final siteType = site_define.getSiteType<T>();

    var uri = site_define.getPostUri(
      siteType: siteType,
      postId: postId,
      subUrl: subUrl,
      query: query,
      needQuestionMark: needQuestionMark,
    );
    if (uri == null) {
      throw ArgumentError('T is not define');
    }

    final documentResult = await getDocument(uri);
    if (documentResult.statueType != StatusType.OK) {
      throw ArgumentError('getDocument failed');
    }

    final document = html_parser.parse(documentResult.documentBody);

    final postBodyRootElement = site_define.getPostAuthorElement(
      siteType: siteType,
      document: document,
    );

    if (postBodyRootElement == null) {
      return null;
    }

    var postListItem = PostListItem();

    final parser = site_define.getPostListItemParser(
      siteType,
      document: document,
      isFromBody: true,
    );

    if (postListItem.parseRoot(postBodyRootElement, parser: parser) == false) {
      throw ArgumentError('${T.runtimeType} parseRoot is Failed');
    }

    return postListItem;
  }
}

abstract class PostListItemParser {
  Document _document;

  Document get document {
    return _document;
  }

  PostListItemParser(Document docuemnt) {
    _document = docuemnt;
  }

  bool isPostListItem(Element element) {
    return true;
  }

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
}

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

  String writeDateTime;

  bool get isEmpty {
    if (postBodyUrl.isEmpty || subject.isEmpty) {
      return true;
    }

    return false;
  }

  bool parseRoot(
    Element element, {
    @required PostListItemParser parser,
  }) {
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
        _parseWarp<String>(parser.parseWriteDateTime, element: element);

    return true;
  }

  T _parseWarp<T>(Function(Element) parseFunc, {@required Element element}) {
    try {
      return parseFunc(element);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
