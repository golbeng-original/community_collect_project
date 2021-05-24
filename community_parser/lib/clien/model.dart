import 'package:community_parser/core/content_element.dart';
import 'package:community_parser/core/parser.dart';
import 'package:community_parser/core/site_meta.dart';
import 'package:html/dom.dart';

/// 클리앙 SiteMeta
class ClienSiteMeta extends SiteMeta {
  ClienSiteMeta() : super(startPageIndex: 0);

  @override
  bool isErrorListPage(Document document) {
    return document.body.classes.contains('error') ? true : false;
  }

  @override
  bool isErrorPostPage(Document document) {
    return document.body.classes.contains('error') ? true : false;
  }

  @override
  bool isErrorCommentPage(Document document) {
    return false;
  }

  @override
  String getAdjustListUrl(
    int pageIndex, {
    String subUrl,
  }) {
    // query list
    // table={string}

    return 'https://www.clien.net/service/$subUrl/?po=$pageIndex';
  }

  @override
  String getAdjustPostBodyUrl(
    String postId, {
    String subUrl,
  }) {
    return 'https://www.clien.net/service/$subUrl/$postId';
  }

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final postItemListRootElement =
        document.querySelector('div.content_list > div.list_content');

    final postItemListElements =
        postItemListRootElement.querySelectorAll('div.list_symph');

    return postItemListElements ?? <Element>[];
  }

  @override
  Element getPostRootQuery(Document document) {
    return document.querySelector('article > div.post_article');
  }

  @override
  Element getPostItemFromBodyRootQuery(Document document) {
    return document.querySelector('div#div_content');
  }

  @override
  List<Element> getCommentListRootQuery(Document document) {
    final commentRootElement = document
        .querySelector('div#div_content > div.post_comment > div.comment');
    final commentElements =
        commentRootElement?.querySelectorAll('div.comment_row');

    return commentElements ?? <Element>[];
  }
}

/// 클리앙 게시글 리스트 아이템 Parser
/// - List에서 List Unit Parsing하기
class ClienPostListItemParser extends PostListItemParser {
  ClienPostListItemParser(Document docuemnt) : super(docuemnt);

  @override
  String parseAuthorIconUrl(Element element) {
    // TODO: implement parseAuthorIconUrl
    throw UnimplementedError();
  }

  @override
  String parseAuthorName(Element element) {
    // TODO: implement parseAuthorName
    throw UnimplementedError();
  }

  @override
  int parseBadCount(Element element) {
    // TODO: implement parseBadCount
    throw UnimplementedError();
  }

  @override
  String parseBodyUrl(Element element) {
    // TODO: implement parseBodyUrl
    throw UnimplementedError();
  }

  @override
  int parseCommentCount(Element element) {
    // TODO: implement parseCommentCount
    throw UnimplementedError();
  }

  @override
  int parseGoodCount(Element element) {
    // TODO: implement parseGoodCount
    throw UnimplementedError();
  }

  @override
  String parsePostId(Element element) {
    // TODO: implement parsePostId
    throw UnimplementedError();
  }

  @override
  String parseSubject(Element element) {
    // TODO: implement parseSubject
    throw UnimplementedError();
  }

  @override
  String parseThumbnailUrl(Element element) {
    // TODO: implement parseThumbnailUrl
    throw UnimplementedError();
  }

  @override
  int parseViewCount(Element element) {
    // TODO: implement parseViewCount
    throw UnimplementedError();
  }

  @override
  String parseWriteDateTime(Element element) {
    // TODO: implement parseWriteDateTime
    throw UnimplementedError();
  }
}

/// 클리앙 게시글 리스트 아이템 Parser
/// - 게시글 본문에서 List Unit 요소 Parsing 하기
class ClienPostListItemFromBodyParser extends PostListItemParser {
  ClienPostListItemFromBodyParser(Document docuemnt) : super(docuemnt);

  @override
  String parseAuthorIconUrl(Element element) {
    // TODO: implement parseAuthorIconUrl
    throw UnimplementedError();
  }

  @override
  String parseAuthorName(Element element) {
    // TODO: implement parseAuthorName
    throw UnimplementedError();
  }

  @override
  int parseBadCount(Element element) {
    // TODO: implement parseBadCount
    throw UnimplementedError();
  }

  @override
  String parseBodyUrl(Element element) {
    // TODO: implement parseBodyUrl
    throw UnimplementedError();
  }

  @override
  int parseCommentCount(Element element) {
    // TODO: implement parseCommentCount
    throw UnimplementedError();
  }

  @override
  int parseGoodCount(Element element) {
    // TODO: implement parseGoodCount
    throw UnimplementedError();
  }

  @override
  String parsePostId(Element element) {
    // TODO: implement parsePostId
    throw UnimplementedError();
  }

  @override
  String parseSubject(Element element) {
    // TODO: implement parseSubject
    throw UnimplementedError();
  }

  @override
  String parseThumbnailUrl(Element element) {
    // TODO: implement parseThumbnailUrl
    throw UnimplementedError();
  }

  @override
  int parseViewCount(Element element) {
    // TODO: implement parseViewCount
    throw UnimplementedError();
  }

  @override
  String parseWriteDateTime(Element element) {
    // TODO: implement parseWriteDateTime
    throw UnimplementedError();
  }
}

/// 크리앙 게시글 Parsing 결과
class ClienPostElement extends PostElement {
  @override
  PostElement createPostElement({
    PostContentType contentType = PostContentType.none,
  }) {
    return ClienPostElement()..setElementData(contentType: contentType);
  }
}

/// 클리앙 Comment Unit Parsing하기
class ClienPostCommentItem extends PostCommentItem {
  @override
  CommentContent createCommentContent() {
    // TODO: implement createCommentContent
    throw UnimplementedError();
  }

  @override
  Element getCommentContentElement(Element element) {
    // TODO: implement getCommentContentElement
    throw UnimplementedError();
  }

  @override
  String parseAuthorIconUrl(Element element) {
    // TODO: implement parseAuthorIconUrl
    throw UnimplementedError();
  }

  @override
  String parseAuthorName(Element element) {
    // TODO: implement parseAuthorName
    throw UnimplementedError();
  }

  @override
  int parseCommentBadCount(Element element) {
    // TODO: implement parseCommentBadCount
    throw UnimplementedError();
  }

  @override
  int parseCommentGoodCount(Element element) {
    // TODO: implement parseCommentGoodCount
    throw UnimplementedError();
  }

  @override
  String parseCommentWriteDatetime(Element element) {
    // TODO: implement parseCommentWriteDatetime
    throw UnimplementedError();
  }

  @override
  bool parseReComment(Element element) {
    // TODO: implement parseReComment
    throw UnimplementedError();
  }
}

class ClienCommentContent extends CommentContent {
  @override
  CommentContent createPostElement({PostContentType contentType}) {
    return ClienCommentContent()..setContentData(contentType: contentType);
  }
}
