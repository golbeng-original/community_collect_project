import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:community_parser/util/get_document.dart';
import 'package:community_parser/core/site_define.dart' as site_define;

enum PrefixParseResult {
  skip_child_parse,
  keep_going,
  ignore,
}

enum PostContentType {
  none,
  root,
  container,
  span,
  text, // 표시
  new_line,
  link,
  img, // 표시
  video, // 표시
  paragraph,
}

class PostParser {
  static Future<PostElement> parse<T extends PostElement>(
      String bodyUrl) async {
    var siteType = site_define.getSiteType<T>();
    var uri = site_define.getPostUri(siteType: siteType, postfixUrl: bodyUrl);
    if (uri == null) {
      return null;
    }

    final documentResult = await getDocument(uri);
    if (documentResult.statueType != StatusType.OK) {
      return null;
    }

    final document = html_parser.parse(documentResult.documentBody);

    final rootElement =
        site_define.getPostRootElement(siteType, document: document);

    var root = site_define.getPostElementInstance(siteType);
    root?.parseRoot(rootElement);

    return root;
  }
}

abstract class PostElement {
  final List<PostElement> _children = <PostElement>[];
  PostContentType _type = PostContentType.none;
  String _tag = '';
  String _content = '';

  PostContentType get postContentType => _type;
  String get tag => _tag;
  String get content => _content;
  List<PostElement> get children => _children;

  PostElement createPostElement({
    PostContentType contentType,
  });

  void setElementData({
    PostContentType contentType = PostContentType.container,
    String tag = '',
    String content = '',
  }) {
    _type = contentType;
    _tag = tag;
    _content = content;
  }

  void addChildPostElement({
    PostContentType contentType = PostContentType.container,
    String tag = '',
    String content = '',
  }) {
    _children.add(createPostElement()
      ..setElementData(contentType: contentType, tag: tag, content: content));
  }

  void printPost({int tabCount = 0}) {
    final tabCountStr = '-' * tabCount;
    print(
        '${tabCountStr}tag = $tag, contentType = $postContentType, content = $content');

    for (var child in _children) {
      child.printPost(tabCount: tabCount + 1);
    }
  }

  void parseRoot(Element rootNode) {
    setElementData(contentType: PostContentType.root);

    for (var node in rootNode.nodes) {
      var postEmenet = createPostElement();
      postEmenet = postEmenet?._parse(node);

      if (postEmenet != null) {
        _children.add(postEmenet);
      }
    }
  }

  PostElement _parse(Node rootNode) {
    if (rootNode.nodeType != Node.ELEMENT_NODE &&
        rootNode.nodeType != Node.TEXT_NODE) {
      return null;
    }

    // TextNode Parsing
    if (rootNode.nodeType == Node.TEXT_NODE) {
      final content = rootNode.text.trim();
      if (content.isEmpty) {
        return null;
      }

      setElementData(
        contentType: PostContentType.text,
        content: content,
      );
      return this;
    }

    final prefixResult = _prefixParseTag(rootNode);
    if (prefixResult == PrefixParseResult.ignore) {
      return null;
    } else if (prefixResult == PrefixParseResult.skip_child_parse) {
      return this;
    }

    for (var node in rootNode.nodes) {
      var postEmenet = createPostElement();
      postEmenet = postEmenet?._parse(node);

      if (postEmenet != null) {
        _children.add(postEmenet);
      }
    }

    return _postfixParseTag(this);
  }

  /// true : Skip 하위 자식 parse 생략
  PrefixParseResult _prefixParseTag(Node targetNode) {
    var targetElement = targetNode as Element;
    if (targetElement == null) {
      return PrefixParseResult.keep_going;
    }

    final tag = targetElement.localName.toLowerCase();
    switch (tag) {
      case 'a':
        return prefixParseATag(targetElement);
      case 'img':
        return prefixParseImgTag(targetElement);
      case 'table':
        return prefixParseTableTag(targetElement);
      case 'br':
        setElementData(tag: tag, contentType: PostContentType.new_line);
        return PrefixParseResult.keep_going;
    }

    return prefixParseDefaultTag(tag, targetElement);
  }

  PostElement _postfixParseTag(PostElement postElement) {
    switch (postElement.tag) {
      case 'a':
        return postfixParseATag(postElement);
      case 'img':
        return postfixParseImgTag(postElement);
      case 'p':
        return postfixParsePTag(postElement);
    }

    return postfixParseDefaultTag(postElement);
  }

  //////////////////////////////////////////////////////
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    setElementData(tag: tag);
    return PrefixParseResult.keep_going;
  }

  PrefixParseResult prefixParseATag(Element targetElement) {
    var linkSource = targetElement.attributes['href'] ?? '';

    setElementData(
        tag: 'a', contentType: PostContentType.link, content: linkSource);

    return PrefixParseResult.keep_going;
  }

  PrefixParseResult prefixParseImgTag(Element targetElement) {
    var imgSource = targetElement.attributes['src'] ?? '';

    setElementData(
      tag: 'img',
      contentType: PostContentType.img,
      content: imgSource,
    );

    return PrefixParseResult.keep_going;
  }

  PrefixParseResult prefixParseTableTag(Element targetElement) {
    setElementData(tag: tag);
    return PrefixParseResult.keep_going;
  }

  //////////////////////////////////////////////////////
  PostElement postfixParseDefaultTag(PostElement postElement) {
    return postElement;
  }

  PostElement postfixParseATag(PostElement postElement) {
    // a 태그 하단에 Img 태그 하나만 있다면, img 태그로 대체
    var imgPostElements = <PostElement>[];
    for (var child in postElement.children) {
      if (child.tag == 'img') {
        imgPostElements.add(child);
      }
    }

    if (imgPostElements.length == 1) {
      return imgPostElements[0];
    }

    return postElement;
  }

  PostElement postfixParseImgTag(PostElement postElement) {
    return postElement;
  }

  PostElement postfixParsePTag(PostElement postElement) {
    // p 태그에 어떤 표시 컨텐츠도 없으면 생략...
    if (postElement.isExistContent() == false) {
      return null;
    }

    return postElement;
  }

  //////////////////////////////////////////////////////
  bool isExistContent() {
    if (_type == PostContentType.text) return true;
    if (_type == PostContentType.img) return true;

    for (var child in _children) {
      if (child.isExistContent() == true) {
        return true;
      }
    }

    return false;
  }

  PostElement findPostElementFromTag(List<String> tag) {
    for (var child in _children) {
      if (tag.contains(child.tag)) {
        return child;
      }

      var findPostElement = child.findPostElementFromTag(tag);
      if (findPostElement != null) {
        return findPostElement;
      }
    }

    return null;
  }

  Iterable<PostElement> findPostElementAllFromTag(List<String> tags) sync* {
    for (var child in _children) {
      if (tag.contains(child.tag)) {
        yield child;
      }

      yield* child.findPostElementAllFromTag(tags);
    }
  }
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
class PostCommentParser {
  static Future<List<PostCommentItem>> parse<T extends PostCommentItem>(
      String bodyUrl) async {
    var siteType = site_define.getSiteType<T>();
    var uri = site_define.getPostUri(siteType: siteType, postfixUrl: bodyUrl);
    if (uri == null) {
      return null;
    }

    final documentResult = await getDocument(uri);
    if (documentResult.statueType != StatusType.OK) {
      return null;
    }

    final document = html_parser.parse(documentResult.documentBody);

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

  var commentImgUrl = '';
  var commentText = '';

  var commentGoodCount = 0;
  var commentBadCount = 0;

  DateTime commentWriteDatetime;

  bool parseRoot(Element element) {
    reComment = parseReComment(element);

    authorIconUrl = parseAuthorIconUrl(element);
    authorName = parseAuthorName(element);

    commentImgUrl = parseCommentImgUrl(element);
    commentText = parseCommentText(element);

    commentGoodCount = parseCommentGoodCount(element);
    commentBadCount = parseComentBadCount(element);

    commentWriteDatetime = parseCommentWriteDatetime(element);

    return true;
  }

  bool parseReComment(Element element);
  String parseAuthorIconUrl(Element element);
  String parseAuthorName(Element element);

  String parseCommentImgUrl(Element element);
  String parseCommentText(Element element);

  int parseCommentGoodCount(Element element);
  int parseComentBadCount(Element element);

  DateTime parseCommentWriteDatetime(Element element);
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

class PostListParser {
  static Future<List<PostListItem>> parse<T extends PostListItemParser>({
    @required int pageIndex,
    Map<String, String> query,
  }) async {
    final siteType = site_define.getSiteType<T>();

    var uri = site_define.getPageUri(
        siteType: siteType, query: query, pageIndex: pageIndex);
    if (uri == null) {
      throw ArgumentError('T is not define');
    }

    final documentResult = await getDocument(uri);
    if (documentResult.statueType != StatusType.OK) {
      throw ArgumentError('getDocument failed');
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
      String bodyUrl) async {
    final siteType = site_define.getSiteType<T>();

    var uri = site_define.getPostUri(siteType: siteType, postfixUrl: bodyUrl);
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
      return null;
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

  String parsePostId(Element element);
  String parseBodyUrl(Element element);

  String parseThumbnailUrl(Element element);
  String parseSubjet(Element element);

  String parseAuthorIconUrl(Element element);
  String parseAuthorName(Element element);

  int parseCommentCount(Element element);
  int parseViewCount(Element element);
  int parseGoodCount(Element element);
  int parseBadCount(Element element);

  DateTime parseWriteDateTime(Element element);
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

  DateTime writeDateTime;

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
    subject = _parseWarp<String>(parser.parseSubjet, element: element) ?? '';
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
        _parseWarp<DateTime>(parser.parseWriteDateTime, element: element);

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
