import 'package:community_parser/community_parser.dart';
import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';
import 'package:html/parser.dart' as html_parser;

abstract class SiteMeta {
  int _startPageIndex = 0;
  int _startCommentPageIndex = 0;
  bool _isExistCommentPage = false;
  bool _isSpecificCommentPage = false;

  SiteMeta({
    int startPageIndex = 0,
    int startCommentPageIndex = 0,
    bool isExistCommentPage = false,
    bool isSpecificCommentPage = false,
  }) {
    _startPageIndex = startPageIndex;
    _startCommentPageIndex = startCommentPageIndex;
    _isExistCommentPage = isExistCommentPage;
    _isSpecificCommentPage = isSpecificCommentPage;
  }

  int get startPageIndex => _startPageIndex;
  int get startCommentPageIndex => _startCommentPageIndex;
  bool get isExistCommentPage => _isExistCommentPage;
  bool get isSpecificCommentPage => _isSpecificCommentPage;

  String getListUrl({
    @required int pageIndex,
    String subUrl = '',
    Map<String, String> query,
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

  String getAdjustListUrl(int pageIndex, {String subUrl});

  String getPostBodyUrl(
    String postId, {
    bool needQuestionMark = false,
    String subUrl,
    Map<String, String> query,
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
    String subUrl,
  });

  String getSpecificCommentUrl(
    String postId, {
    String subUrl = '',
    Map<String, String> query,
    bool needQuestionMark = false,
  }) {
    return null;
  }

  List<Element> getPostItemListRootQuery(Document document);
  Element getPostItemFromBodyRootQuery(Document document);
  Element getPostRootQuery(Document document);

  Document getCommentDocument(String documentString) {
    return html_parser.parse(documentString);
  }

  List<Element> getCommentListRootQuery(Document document);

  bool isErrorListPage(Document document);
  bool isErrorPostPage(Document document);
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

  Uri getCommentPageUrl(int index, {String postId}) {
    final adjustIndex = startCommentPageIndex + index;
    return getAdjustCommentPageUrl(adjustIndex, postId: postId);
  }

  Uri getAdjustCommentPageUrl(int index, {String postId}) {
    return null;
  }
}
