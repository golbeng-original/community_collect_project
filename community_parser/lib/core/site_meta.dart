import 'package:community_parser/community_parser.dart';
import 'package:html/dom.dart';
import 'package:tuple/tuple.dart';
import 'package:html/parser.dart' as html_parser;

abstract class SiteMeta {
  late String _siteDomain;
  int _startPageIndex = 0;
  int _startCommentPageIndex = 0;
  bool _isExistCommentPage = false;
  bool _isSpecificCommentPage = false;
  bool _isRefreshCookieRequest = false;

  SiteMeta({
    required String siteDomain,
    int startPageIndex = 0,
    int startCommentPageIndex = 0,
    bool isExistCommentPage = false,
    bool isSpecificCommentPage = false,
    bool isRefreshCookieRequest = false,
  }) {
    _siteDomain = siteDomain;
    _startPageIndex = startPageIndex;
    _startCommentPageIndex = startCommentPageIndex;
    _isExistCommentPage = isExistCommentPage;
    _isSpecificCommentPage = isSpecificCommentPage;
    _isRefreshCookieRequest = isRefreshCookieRequest;
  }

  String get siteDomain => _siteDomain;
  int get startPageIndex => _startPageIndex;
  int get startCommentPageIndex => _startCommentPageIndex;
  bool get isExistCommentPage => _isExistCommentPage;
  bool get isSpecificCommentPage => _isSpecificCommentPage;
  bool get isRefreshCookieRequest => _isRefreshCookieRequest;

  /// pageIndex에 해당하는 List를 가져오는 Url을 가져온다.
  /// subUrl 또는 Query가 포함 될 수 있다.
  String getListUrl({
    required int pageIndex,
    String subUrl = '',
    Map<String, String>? query,
  }) {
    var metaPageIndex = startPageIndex + pageIndex;
    var url = getAdjustListUrl(metaPageIndex, subUrl: subUrl);

    if (query == null) {
      return url;
    }

    for (var key in query.keys) {
      url = url + '&$key=${query[key]}';
    }

    return url;
  }

  String getAdjustListUrl(
    int pageIndex, {
    String subUrl = '',
  });

  /// PostId에 해당하는 Body Url을 가져온다.
  String getPostBodyUrl(
    String postId, {
    bool needQuestionMark = false,
    String subUrl = '',
    Map<String, String>? query,
  }) {
    var url = getAdjustPostBodyUrl(postId, subUrl: subUrl);
    if (query != null) {
      if (needQuestionMark == true) {
        url += '?';
      }

      for (var key in query.keys) {
        var splitMark = '&';
        if (query.keys.first == key) {
          splitMark = needQuestionMark ? '?' : '&';
        }
        url += '$splitMark$key=${query[key]}';
      }
    }

    return url;
  }

  String getAdjustPostBodyUrl(
    String postId, {
    String subUrl = '',
  });

  String? getSpecificCommentUrl(
    String postId, {
    String subUrl = '',
    Map<String, String>? query,
    bool needQuestionMark = false,
  }) {
    return null;
  }

  /// 게시글 목록을 표현하는 Html Element를 가져온다.
  List<Element> getPostItemListRootQuery(Document document);

  /// 게시글 항목을 표현하는 Html Element를 가져온다. (게시글 본문으로부터 가져온다.)
  Element? getPostItemFromBodyRootQuery(Document document);

  /// 게시글을 포현하는 Html Element를 가져온다.
  Element? getPostRootQuery(Document document);

  /// 댓글을 표현하는 Document를 가져온다.
  /// - 평범한 사이트일 경우에는 Document에 표현된다.
  /// - 특수한 경우에는 별도의 Dpcument를 불러와야 한다. (다시 Get Method로 가져온다.)
  Document getCommentDocument(Document commentDocument) {
    return commentDocument;
  }

  /// 댓글 목록 리스트를 표현하는 Html Element를 가져온다.
  List<Element> getCommentListRootQuery(Document document);

  /// List항목을 표현하는 Document가 Error를 표시하는 페이지인가??
  bool isErrorListPage(Document document);

  /// 게시글을 표현하는 Document가 Error를 표시하는 페이지인가??
  bool isErrorPostPage(Document document);

  /// 댓글을 표현하는 Document가 Error를 표시하는가??
  bool isErrorCommentPage(Document document) {
    return isErrorPostPage(document);
  }

  /// <default page, total page cout>
  Future<Tuple2<int, int>> getCommentPageCount(Uri commentBodyUrl) async {
    var documentResult = await getDocument(commentBodyUrl);
    if (documentResult.statueType != StatusType.OK) {
      return Tuple2<int, int>(0, 0);
    }

    var document = html_parser.parse(documentResult.documentBody);
    return findCommentPageCount(document);
  }

  /// <default page, total page cout>
  Tuple2<int, int> findCommentPageCount(Document document) {
    return Tuple2<int, int>(0, 0);
  }

  Uri? getCommentPageUrl(
    int index, {
    String postId = '',
  }) {
    final adjustIndex = startCommentPageIndex + index;
    return getAdjustCommentPageUrl(adjustIndex, postId: postId);
  }

  Uri? getAdjustCommentPageUrl(
    int index, {
    String postId = '',
  }) {
    return null;
  }
}
