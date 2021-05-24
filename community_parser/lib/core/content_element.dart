import 'package:community_parser/community_parser.dart';
import 'package:html/dom.dart';

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
  youtube, //표시
  audio,
  paragraph,
}

bool _isContent(PostContentType contentType) {
  if (contentType == PostContentType.text) return true;
  if (contentType == PostContentType.img) return true;
  if (contentType == PostContentType.youtube) return true;
  if (contentType == PostContentType.video) return true;
  if (contentType == PostContentType.audio) return true;

  return false;
}

abstract class PostElement {
  final List<PostElement> _children = <PostElement>[];

  PostContentType _type = PostContentType.none;
  String _tag = '';
  String _content = '';

  PostElement parent;

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
    var newPostElement = createPostElement()
      ..setElementData(
        contentType: contentType,
        tag: tag,
        content: content,
      );

    newPostElement.parent = this;

    _children.add(newPostElement);
  }

  void printContent({int tabCount = 0}) {
    final tabCountStr = '-' * tabCount;
    print(
        '${tabCountStr}tag = $tag, contentType = $postContentType, content = $content');

    for (var child in _children) {
      child.printContent(tabCount: tabCount + 1);
    }
  }

  void parseRoot(Element rootNode) {
    setElementData(contentType: PostContentType.root);

    if (rootNode == null) {
      return;
    }

    for (var node in rootNode.nodes) {
      var postEmenet = createPostElement();
      postEmenet = postEmenet?._parse(node);

      if (postEmenet != null) {
        postEmenet.parent = this;
        _children.add(postEmenet);
      }
    }

    _postfixParseRootTag();
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

      return _postfixParseTag(this);
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
      case 'iframe':
        return prefixParseIframeTag(targetElement);
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

  void _postfixParseRootTag() {
    postfixParseDefaultTag(this);
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

  PrefixParseResult prefixParseIframeTag(Element targetElement) {
    setElementData(tag: tag);
    return PrefixParseResult.keep_going;
  }

  //////////////////////////////////////////////////////
  PostElement postfixParseDefaultTag(PostElement postElement) {
    if (postElement.children.length == 1 &&
        postElement.children[0].isExistContent()) {
      return postElement.children[0];
    }

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
    if (_isContent(_type) == true) {
      return true;
    }

    for (var child in _children) {
      if (child.isExistContent() == true) {
        return true;
      }
    }

    return false;
  }

  bool isExistContentType({PostContentType contentType}) {
    if (_type == contentType) return true;

    for (var child in _children) {
      if (child.isExistContentType(contentType: contentType) == true) {
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

  Iterable<PostElement> findPostElementAllFromContentType(
      PostContentType contentType) sync* {
    if (contentType == contentType) {
      yield this;
    }

    for (var child in children) {
      yield* child.findPostElementAllFromContentType(contentType);
    }
  }
}

abstract class CommentContent {
  final List<CommentContent> _children = <CommentContent>[];
  PostContentType _type = PostContentType.none;
  String _tag = '';
  String _content = '';

  CommentContent parent;

  PostContentType get postContentType => _type;
  String get tag => _tag;
  String get content => _content;
  List<CommentContent> get children => _children;

  CommentContent createPostElement({
    PostContentType contentType,
  });

  void parseRoot(Element rootNode) {
    setContentData(contentType: PostContentType.root);

    if (rootNode == null) {
      return;
    }

    for (var node in rootNode.nodes) {
      var postEmenet = createPostElement();
      postEmenet = postEmenet?._parse(node);

      if (postEmenet != null) {
        postEmenet.parent = this;
        _children.add(postEmenet);
      }
    }

    postfixRoot(this);
  }

  void removeSelf() {
    if (parent == null) {
      return;
    }

    parent.children.remove(this);
  }

  void setContentData({
    PostContentType contentType = PostContentType.container,
    String tag = '',
    String content = '',
  }) {
    _type = contentType;
    _tag = tag;
    _content = content;
  }

  void addChildCommentContent({
    PostContentType contentType = PostContentType.container,
    String tag = '',
    String content = '',
  }) {
    var newCommentContent = createPostElement()
      ..setContentData(
        contentType: contentType,
        tag: tag,
        content: content,
      );

    newCommentContent.parent = this;
    _children.add(newCommentContent);
  }

  void printContent({int tabCount = 0}) {
    final tabCountStr = '-' * tabCount;
    print(
        '${tabCountStr}tag = $tag, contentType = $postContentType, content = $content');

    for (var child in _children) {
      child.printContent(tabCount: tabCount + 1);
    }
  }

  CommentContent _parse(Node rootNode) {
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

      setContentData(
        contentType: PostContentType.text,
        content: content,
      );

      return _postfixParseTag(this);
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
      case 'br':
        setContentData(tag: tag, contentType: PostContentType.new_line);
        return PrefixParseResult.keep_going;
    }

    return prefixParseDefaultTag(tag, targetElement);
  }

  CommentContent _postfixParseTag(CommentContent commentContent) {
    switch (commentContent.tag) {
      case 'a':
        return postfixParseATag(commentContent);
      case 'img':
        return postfixParseImgTag(commentContent);
      case 'p':
        return postfixParsePTag(commentContent);
    }

    return postfixParseDefaultTag(commentContent);
  }

  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    setContentData(tag: tag);
    return PrefixParseResult.keep_going;
  }

  CommentContent postfixParseDefaultTag(CommentContent commentContent) {
    if (commentContent.children.length == 1 &&
        commentContent.children[0].isExistContent()) {
      return commentContent.children[0];
    }

    return commentContent;
  }

  void postfixRoot(CommentContent rootCommentContent) {}

  //
  PrefixParseResult prefixParseATag(Element targetElement) {
    var linkSource = targetElement.attributes['href'] ?? '';

    setContentData(
        tag: 'a', contentType: PostContentType.link, content: linkSource);

    return PrefixParseResult.keep_going;
  }

  PrefixParseResult prefixParseImgTag(Element targetElement) {
    var imgSource = targetElement.attributes['src'] ?? '';

    setContentData(
      tag: 'img',
      contentType: PostContentType.img,
      content: imgSource,
    );

    return PrefixParseResult.keep_going;
  }

  CommentContent postfixParseATag(CommentContent commentContent) {
    // a 태그 하단에 Img 태그 하나만 있다면, img 태그로 대체
    var imgPostElements = <CommentContent>[];
    for (var child in commentContent.children) {
      if (child.tag == 'img') {
        imgPostElements.add(child);
      }
    }

    if (imgPostElements.length == 1) {
      return imgPostElements[0];
    }

    return commentContent;
  }

  CommentContent postfixParseImgTag(CommentContent commentContent) {
    return commentContent;
  }

  CommentContent postfixParsePTag(CommentContent commentContent) {
    // p 태그에 어떤 표시 컨텐츠도 없으면 생략...
    if (commentContent.isExistContent() == false) {
      return null;
    }

    return commentContent;
  }
  //

  bool isExistContent() {
    if (_isContent(_type) == true) {
      return true;
    }

    for (var child in _children) {
      if (child.isExistContent() == true) {
        return true;
      }
    }

    return false;
  }

  bool isExistContentType({PostContentType contentType}) {
    if (_type == contentType) return true;

    for (var child in _children) {
      if (child.isExistContentType(contentType: contentType) == true) {
        return true;
      }
    }

    return false;
  }

  Iterable<CommentContent> findCommentContentAllFromContentType(
      PostContentType contentType) sync* {
    if (contentType == contentType) {
      yield this;
    }

    for (var child in children) {
      yield* child.findCommentContentAllFromContentType(contentType);
    }
  }
}
