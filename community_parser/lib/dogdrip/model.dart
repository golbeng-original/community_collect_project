import 'package:html/dom.dart';
import 'package:community_parser/core/parser.dart';
import 'package:community_parser/core/content_element.dart';
import 'package:community_parser/core/site_meta.dart';
import 'package:tuple/tuple.dart';

class DogdripSiteMeta extends SiteMeta {
  DogdripSiteMeta()
      : super(
          siteDomain: 'dogdrip',
          startPageIndex: 1,
          startCommentPageIndex: 1,
          isExistCommentPage: true,
        );

  @override
  bool isErrorListPage(Document document) {
    final errorSection = document.querySelector('section.xedition-error');
    return errorSection != null ? true : false;
  }

  @override
  bool isErrorPostPage(Document document) {
    final errorSection = document.querySelector('section.xedition-error');
    return errorSection != null ? true : false;
  }

  @override
  String getAdjustListUrl(
    int pageIndex, {
    String subUrl = '',
  }) {
    // query list
    // mid={string}
    // sort_index=popular
    // category={int}

    return 'https://www.dogdrip.net/?page=$pageIndex';
  }

  @override
  String getAdjustPostBodyUrl(
    String postId, {
    String subUrl = '',
  }) {
    return 'https://www.dogdrip.net/' + postId;
  }

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final listRoot = document.querySelector('div.board-list');
    final listUnits = listRoot?.querySelectorAll('table.table > tbody > tr');
    return listUnits ?? <Element>[];
  }

  @override
  Element? getPostItemFromBodyRootQuery(Document document) {
    final postRoot = document.querySelector('div.inner-container > div');
    return postRoot;
  }

  @override
  Element? getPostRootQuery(Document document) {
    final postRoot = document.querySelector('#article_1 > div');
    return postRoot;
  }

  @override
  List<Element> getCommentListRootQuery(Document document) {
    final commentRoot =
        document.querySelectorAll('div.comment-list > div.comment-item');

    return commentRoot;
  }

  /// <default page, total page cout>
  @override
  Tuple2<int, int> findCommentPageCount(Document document) {
    final defaultPageData = Tuple2<int, int>(0, 0);
    if (isExistCommentPage == false) {
      return defaultPageData;
    }

    final commnetBoxElement = document.querySelector('div#commentbox');
    final commentUlElment = commnetBoxElement?.querySelector('ul.pagination');
    final liElements = commentUlElment?.querySelectorAll('li');
    if (liElements == null) {
      return defaultPageData;
    }

    var defaultPage = 0;
    for (var liElement in liElements) {
      if (liElement.classes.contains('avtive') == true) {
        defaultPage = liElements.indexOf(liElement) - startCommentPageIndex;
        break;
      }
    }

    return Tuple2<int, int>(defaultPage, liElements.length);
  }

  @override
  Uri getAdjustCommentPageUrl(
    int index, {
    String postId = '',
  }) {
    var url = 'https://www.dogdrip.net/';

    url += '?cpage=$index';

    if (postId.isNotEmpty) {
      url += '&document_srl=$postId';
    }

    return Uri.parse(url);
  }
}

String _getPostIdFromUrl(String postUrl) {
  // case 1
  final case_1_match = RegExp(r'document_srl=(?<postId>[0-9]+)');
  var matched = case_1_match.firstMatch(postUrl);
  if (matched != null) {
    return matched.namedGroup('postId') ?? '';
  }

  // case 2
  final case_2_match = RegExp(r'https://www.dogdrip.net/(?<postId>[0-9]+)');
  matched = case_2_match.firstMatch(postUrl);
  if (matched != null) {
    return matched.namedGroup('postId') ?? '';
  }

  return '';
}

/// 개드립 게시글 리스트 아이템 Parser
/// - List에서 List Unit Parsing하기
class DogdripPostListItemParser extends PostListItemParser {
  DogdripPostListItemParser(Document docuemnt) : super(docuemnt);

  @override
  bool isPostListItem(Element element) {
    return element.classes.contains('notice') ? false : true;
  }

  Element? _getAuthorElement(Element rootElement) {
    return rootElement.querySelector('td.author > a');
  }

  @override
  String parseAuthorIconUrl(Element element) {
    final authorRootElement = _getAuthorElement(element);

    final authorImageSource = authorRootElement?.querySelector('img');
    if (authorImageSource == null) {
      return '';
    }

    return authorImageSource.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorRootElement = _getAuthorElement(element);
    if (authorRootElement == null) {
      return '';
    }

    var authorName = authorRootElement.text;
    return authorName.trim();
  }

  Element? _getTitleRootElement(Element rootElement) {
    return rootElement.querySelector('td.title > span > a');
  }

  @override
  String parsePostId(Element element) {
    final titleRootElement = _getTitleRootElement(element);
    if (titleRootElement == null) {
      return '';
    }

    final postUrl = titleRootElement.attributes['href'] ?? '';
    return _getPostIdFromUrl(postUrl);
  }

  @override
  String parseBodyUrl(Element element) {
    return parsePostId(element);
  }

  @override
  int parseCommentCount(Element element) {
    final titleRootElement = _getTitleRootElement(element);
    if (titleRootElement == null) {
      return 0;
    }

    final commentCountElement =
        titleRootElement.querySelector('span.text-primary');
    final commentCountText = commentCountElement?.text ?? '';

    return int.tryParse(commentCountText) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    final goodCountElement = element.querySelector('td.voteNum');
    final goodCountText = goodCountElement?.text ?? '';

    return int.tryParse(goodCountText) ?? 0;
  }

  @override
  String parseSubject(Element element) {
    final titleRootElement = _getTitleRootElement(element);
    final subjectElement = titleRootElement?.querySelector('span.title-link');
    return subjectElement?.text ?? '';
  }

  @override
  int parseBadCount(Element element) {
    // 추천수를 알 수 가 없다..
    return -1;
  }

  @override
  String parseThumbnailUrl(Element element) {
    // Thumnail 정보가 없다..
    return '';
  }

  @override
  int parseViewCount(Element element) {
    // viewCount 정보가 없다.
    return -1;
  }

  @override
  String parseWriteDateTime(Element element) {
    final timeElement = element.querySelector('td.time');
    return timeElement?.text ?? '';
  }
}

/// 개드립 게시글 리스트 아이템 Parser
/// - 게시글 본문에서 List Unit 요소 Parsing 하기
class DogdripPostListItemFromBodyParser extends PostListItemParser {
  DogdripPostListItemFromBodyParser(Document docuemnt) : super(docuemnt);

  Element? _getArticleHeadElement(Element element) {
    return element.querySelector('div > div.article-head');
  }

  Element? _getTitleToolbarElement(Element element) {
    final articleHeadElement = _getArticleHeadElement(element);
    return articleHeadElement?.querySelector('div.title-toolbar');
  }

  @override
  String parseAuthorIconUrl(Element element) {
    final titleToolbarElement = _getTitleToolbarElement(element);
    final spans = titleToolbarElement?.querySelectorAll('div > span');
    if (spans == null || spans.length != 2) {
      return '';
    }

    final authorIconElement = spans[0].querySelector('a > img');
    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final titleToolbarElement = _getTitleToolbarElement(element);
    final spans = titleToolbarElement?.querySelectorAll('div > span');
    if (spans == null || spans.length != 2) {
      return '';
    }

    final authorIconElement = spans[0].querySelector('a');
    return authorIconElement?.text.trim() ?? '';
  }

  @override
  String parsePostId(Element element) {
    final articleHeadElement = _getArticleHeadElement(element);
    final postUrlElement = articleHeadElement?.querySelector('h4 > a');
    if (postUrlElement == null) {
      return '';
    }

    final postUrl = postUrlElement.attributes['href'] ?? '';
    return _getPostIdFromUrl(postUrl);
  }

  @override
  String parseBodyUrl(Element element) {
    return parsePostId(element);
  }

  @override
  int parseCommentCount(Element element) {
    // CommentCount Element PostBodyRoot 밖에 존재한다....

    final commentCountElement = document.querySelector('div#commentbox > h4');
    final commentCountText = commentCountElement?.text.trim() ?? '';

    final commentRegExp = RegExp(r'(?<comment>[0-9]+)');
    var commentMatch = commentRegExp.firstMatch(commentCountText);
    if (commentMatch == null) {
      return 0;
    }

    return int.tryParse(commentMatch.namedGroup('comment') ?? '') ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    var scripts = document.querySelectorAll('script');
    if (scripts.isEmpty) {
      return 0;
    }

    final goodCommetRegExp =
        RegExp(r'id=\"document_voted_count\">(?<goodCount>[0-9]+)<');

    for (var script in scripts) {
      if (script.text.isEmpty == true) {
        continue;
      }

      final matched = goodCommetRegExp.firstMatch(script.text);
      if (matched != null) {
        return int.tryParse(matched.namedGroup('goodCount') ?? '') ?? 0;
      }
    }

    return 0;
  }

  @override
  int parseBadCount(Element element) {
    // badCount가 없다.
    return -1;
  }

  @override
  String parseSubject(Element element) {
    final articleHeadElement = _getArticleHeadElement(element);
    final postUrlElement = articleHeadElement?.querySelector('h4 > a');
    return postUrlElement?.text ?? '';
  }

  @override
  String parseThumbnailUrl(Element element) {
    // Thumnail 존재 하지 않는다.
    return '';
  }

  @override
  int parseViewCount(Element element) {
    // ViewCount 정보가 존재하지 않는다.
    return -1;
  }

  @override
  String parseWriteDateTime(Element element) {
    final titleToolbarElement = _getTitleToolbarElement(element);
    final spans = titleToolbarElement?.querySelectorAll('div > span');
    if (spans == null || spans.length != 2) {
      return '';
    }

    final timeElements = spans[1].querySelectorAll('span');
    if (timeElements.length != 2) {
      return '';
    }

    return timeElements[1].text;
  }
}

/// 개드립 게시글 Parsing 결과
class DogdripPostElement extends PostElement {
  @override
  PostElement createPostElement({
    PostContentType contentType = PostContentType.container,
  }) {
    return DogdripPostElement()..setElementData(contentType: contentType);
  }

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    return super.prefixParseDefaultTag(tag, targetElement);
  }

  @override
  PrefixParseResult prefixParseIframeTag(Element targetElement) {
    var iFrameSource = targetElement.attributes['src'] ?? '';
    if (iFrameSource.contains('youtube.com') == true) {
      setElementData(
          contentType: PostContentType.youtube, content: iFrameSource);
      return PrefixParseResult.skip_child_parse;
    }

    return super.prefixParseIframeTag(targetElement);
  }

  @override
  PostElement? postfixParseDefaultTag(PostElement postElement) {
    if (postElement.postContentType == PostContentType.text) {
      var textContent = postElement.content;

      // Youtube 주소를 포함하고 있다면, 링크 + youtube ContentType으로 표시한다.
      var regExp = RegExp(r'https?://(www.)?(youtu.be|youtube.com)?/(.+)');
      if (regExp.hasMatch(textContent) == true) {
        return _createYoutubeLinkElement(textContent);
      }

      regExp = RegExp(r'^https?://');
      if (regExp.hasMatch(textContent) == true) {
        return _createLinkElement(textContent);
      }
    }

    return super.postfixParseDefaultTag(postElement);
  }

  PostElement _createYoutubeLinkElement(String youtubeUrl) {
    var rootElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.container,
        tag: 'div',
      );

    var pElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.paragraph,
        tag: 'p',
      );
    var youtubeElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.youtube,
        content: youtubeUrl,
      );

    pElement.children.add(youtubeElement);
    rootElement.children.add(pElement);

    pElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.paragraph,
        tag: 'p',
      );

    var aElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.link,
        tag: 'a',
        content: youtubeUrl,
      );

    var textElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.text,
        content: youtubeUrl,
      );

    aElement.children.add(textElement);

    pElement.children.add(aElement);
    rootElement.children.add(pElement);

    return rootElement;
  }

  PostElement _createLinkElement(String url) {
    var rootElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.container,
        tag: 'div',
      );

    var pElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.paragraph,
        tag: 'p',
      );

    var aElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.link,
        tag: 'a',
        content: url,
      );

    var textElement = DogdripPostElement()
      ..setElementData(
        contentType: PostContentType.text,
        content: url,
      );

    aElement.children.add(textElement);

    pElement.children.add(aElement);
    rootElement.children.add(pElement);

    return rootElement;
  }
}

/// 개드립 Comment Unit parsing하기
class DogdripPostCommentItem extends PostCommentItem {
  Element? _getAuthorElement(Element element) {
    var findElement = element.querySelector('div.comment-bar > div > h6 > a');
    findElement ??= element.querySelector(
      'div.comment-bar-author > div > h6 > a',
    );

    return findElement;
  }

  @override
  String parseAuthorIconUrl(Element element) {
    final authorElement = _getAuthorElement(element);

    final imgElement = authorElement?.querySelector('img');
    if (imgElement == null) {
      return '';
    }

    return imgElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorElement = _getAuthorElement(element);
    return authorElement?.text ?? '';
  }

  Element? _getGoodBadCountElement(Element element) {
    return element.querySelector('div.comment-content div.action');
  }

  @override
  int parseCommentBadCount(Element element) {
    final countRootElement = _getGoodBadCountElement(element);

    final spanElements = countRootElement?.querySelectorAll('span > span');
    if (spanElements == null || spanElements.length != 2) {
      return 0;
    }

    final badCountElement = spanElements[1].querySelector('span.count');
    if (badCountElement == null) {
      return 0;
    }

    return int.tryParse(badCountElement.text) ?? 0;
  }

  @override
  int parseCommentGoodCount(Element element) {
    final countRootElement = _getGoodBadCountElement(element);

    final spanElements = countRootElement?.querySelectorAll('span.ed');
    if (spanElements == null || spanElements.length != 2) {
      return 0;
    }

    final goodCountElement = spanElements[0].querySelector('span.count');
    if (goodCountElement == null) {
      return 0;
    }

    return int.tryParse(goodCountElement.text) ?? 0;
  }

  @override
  String parseCommentWriteDatetime(Element element) {
    var timeElement = element.querySelector('div.comment-bar > div > span');
    timeElement ??=
        element.querySelector('div.comment-bar-author > div > span');

    return timeElement?.text.trim() ?? '';
  }

  @override
  bool parseReComment(Element element) {
    return element.classes.contains('depth') ? true : false;
  }

  @override
  CommentContent createCommentContent() {
    return DogdripCommentContent();
  }

  @override
  Element? getCommentContentElement(Element element) {
    return element.querySelector('div.xe_content');
  }
}

/// 개드립 Comment 내용 표현
class DogdripCommentContent extends CommentContent {
  @override
  CommentContent createCommentContent({
    PostContentType contentType = PostContentType.none,
  }) {
    return DogdripCommentContent()..setContentData(contentType: contentType);
  }

  String _findImgUrl(String? styleStr) {
    if (styleStr == null) {
      return '';
    }

    final imageUrlRegexp = RegExp(r'background-image:url\((?<url>.+)\);');

    final matched = imageUrlRegexp.firstMatch(styleStr);
    if (matched == null) {
      return '';
    }

    return matched.namedGroup('url') ?? '';
  }

  @override
  PrefixParseResult prefixParseATag(Element targetElement) {
    final style = targetElement.attributes['style'];
    final imgUrl = _findImgUrl(style);
    if (imgUrl.isNotEmpty == true) {
      setContentData(
          tag: 'img', contentType: PostContentType.img, content: imgUrl);

      return PrefixParseResult.skip_child_parse;
    }

    return super.prefixParseATag(targetElement);
  }
}
