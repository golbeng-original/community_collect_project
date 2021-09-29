import 'package:community_parser/core/content_element.dart';
import 'package:community_parser/core/parser.dart';
import 'package:community_parser/core/site_meta.dart';
import 'package:html/dom.dart';

/// 클리앙 SiteMeta
class ClienSiteMeta extends SiteMeta {
  ClienSiteMeta() : super(siteDomain: 'clien', startPageIndex: 0);

  @override
  bool isErrorListPage(Document document) {
    if (document.body == null) {
      return false;
    }

    return document.body!.classes.contains('error') ? true : false;
  }

  @override
  bool isErrorPostPage(Document document) {
    if (document.body == null) {
      return false;
    }

    return document.body!.classes.contains('error') ? true : false;
  }

  @override
  bool isErrorCommentPage(Document document) {
    return false;
  }

  @override
  String getAdjustListUrl(
    int pageIndex, {
    String subUrl = '',
  }) {
    // query list
    // table={string}

    return 'https://www.clien.net/service/$subUrl/?po=$pageIndex';
  }

  @override
  String getAdjustPostBodyUrl(
    String postId, {
    String subUrl = '',
  }) {
    return 'https://www.clien.net/service/$subUrl/$postId';
  }

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final postItemListRootElement =
        document.querySelector('div.content_list > div.list_content');

    final postItemListElements =
        postItemListRootElement?.querySelectorAll('div.list_item');

    return postItemListElements ?? <Element>[];
  }

  @override
  Element? getPostRootQuery(Document document) {
    return document.querySelector('article > div.post_article');
  }

  @override
  Element? getPostItemFromBodyRootQuery(Document document) {
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
    final authorIconElement =
        element.querySelector('div.list_author > span.nickname > img');

    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorNameElement =
        element.querySelector('div.list_author > span.nickname > span');

    return authorNameElement?.text.trim() ?? '';
  }

  @override
  String parsePostId(Element element) {
    return element.attributes['data-board-sn'] ?? '';
  }

  @override
  String parseBodyUrl(Element element) {
    final rootElement =
        element.querySelector('div.list_title > a.list_subject');
    if (rootElement == null) {
      return '';
    }

    return rootElement.attributes['href'] ?? '';
  }

  @override
  String parseSubject(Element element) {
    final subjectElement =
        element.querySelector('div.list_title span.subject_fixed');
    if (subjectElement == null) {
      return '';
    }

    return subjectElement.text.trim();
  }

  @override
  int parseBadCount(Element element) {
    // BadCount 존재하지 않음
    return -1;
  }

  @override
  int parseCommentCount(Element element) {
    final commentCount = element.attributes['data-comment-count'] ?? '';
    return int.tryParse(commentCount) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    final goodCountElement = element.querySelector('div.list_symph > span');
    final goodCountStr = goodCountElement?.text ?? '';

    return int.tryParse(goodCountStr) ?? 0;
  }

  @override
  String parseThumbnailUrl(Element element) {
    // Thmbnail 존재 하지 않음
    return '';
  }

  @override
  int parseViewCount(Element element) {
    final viewCountElement = element.querySelector('div.list_hit > span.hit');
    final viewCountStr = viewCountElement?.text ?? '';

    return int.tryParse(viewCountStr) ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    final writeDateTimeElement =
        element.querySelector('div.list_time > span.time > span.timestamp');
    return writeDateTimeElement?.text ?? '';
  }
}

/// 클리앙 게시글 리스트 아이템 Parser
/// - 게시글 본문에서 List Unit 요소 Parsing 하기
class ClienPostListItemFromBodyParser extends PostListItemParser {
  ClienPostListItemFromBodyParser(Document docuemnt) : super(docuemnt);

  @override
  String parseAuthorIconUrl(Element element) {
    final authorIconElement =
        element.querySelector('div.post_info span.nickname > img');

    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorNameElement =
        element.querySelector('div.post_info span.nickname > span');

    return authorNameElement?.text ?? '';
  }

  @override
  String parsePostId(Element element) {
    final bodyUrl = parseBodyUrl(element);
    final split = bodyUrl.split('/');
    if (split.isEmpty) {
      return '';
    }

    final postId = split.last;
    return postId;
  }

  @override
  String parseBodyUrl(Element element) {
    final bodyUrlMetaElement = document.querySelector('meta[property="url"]');
    if (bodyUrlMetaElement == null) {
      return '';
    }

    return bodyUrlMetaElement.attributes['content'] ?? '';
  }

  @override
  String parseSubject(Element element) {
    final subjectElement =
        element.querySelector('div.post_title > h3.post_subject > span');
    return subjectElement?.text ?? '';
  }

  @override
  String parseThumbnailUrl(Element element) {
    //Thumnbnail은 존재하지 않는다.
    return '';
  }

  @override
  int parseBadCount(Element element) {
    //badCount는 존재하지 앟는다.
    return -1;
  }

  @override
  int parseCommentCount(Element element) {
    final commentCountElement = element.querySelector(
        'div.post_title > h3.post_subject > a.post_reply > span');

    final commentCountStr = commentCountElement?.text ?? '';
    return int.tryParse(commentCountStr) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    final goodCountElement =
        element.querySelector('div.post_title > div.view_symph > span');

    final goodCountStr = goodCountElement?.text ?? '';
    return int.tryParse(goodCountStr) ?? 0;
  }

  @override
  int parseViewCount(Element element) {
    final viewCountElement =
        element.querySelector('div.view_info > span.view_count > strong');

    final viewCountStr = viewCountElement?.text ?? '';
    return int.tryParse(viewCountStr) ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    final writeDateTimeElment =
        element.querySelector('div.post_view > div.post_author > span');

    if (writeDateTimeElment == null) {
      return '';
    }

    var writeDateTimeStr = writeDateTimeElment.text;

    final writeDateTimeRegexp =
        RegExp(r'[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}');
    final matched = writeDateTimeRegexp.firstMatch(writeDateTimeStr);
    if (matched == null) {
      return '';
    }

    return matched.group(0) ?? '';
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

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    //setElementData(tag: tag);
    //return PrefixParseResult.keep_going;

    if (tag != 'p') {
      return super.prefixParseDefaultTag(tag, targetElement);
    }

    if (targetElement.classes.contains('video') == false) {
      return super.prefixParseDefaultTag(tag, targetElement);
    }

    final youtubeElement = targetElement.querySelector('iframe');
    if (youtubeElement == null) {
      return super.prefixParseDefaultTag(tag, targetElement);
    }

    final youtubeUrl = youtubeElement.attributes['src'] ?? '';
    setElementData(
        tag: 'youtube',
        contentType: PostContentType.youtube,
        content: youtubeUrl);

    return PrefixParseResult.skip_child_parse;
  }
}

/// 클리앙 Comment Unit Parsing하기
class ClienPostCommentItem extends PostCommentItem {
  @override
  CommentContent createCommentContent() {
    return ClienCommentContent();
  }

  @override
  String parseAuthorIconUrl(Element element) {
    final authorIconElement = element.querySelector('span.nickname > img');
    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorNameElement = element.querySelector('span.nickname > span');
    return authorNameElement?.text ?? '';
  }

  @override
  Element? getCommentContentElement(Element element) {
    //comment-img
    var insertElements = <Element>[];
    final videoElement = element.querySelector('div.comment-video > video');
    if (videoElement != null) {
      insertElements.add(videoElement);
    }

    final imgElement = element.querySelector('div.comment-img > img');
    if (imgElement != null) {
      insertElements.add(imgElement);
    }

    final contentElement =
        element.querySelector('div.comment_content > div.comment_view');

    if (insertElements.isEmpty) {
      return contentElement;
    }

    if (contentElement == null) {
      return null;
    }

    var rootElement = Element.tag('div');

    for (var insertElement in insertElements) {
      var pElement = Element.tag('p');
      pElement.append(insertElement);
      rootElement.append(pElement);
    }

    var contentRootElement = Element.tag('div');
    contentRootElement.append(contentElement);
    rootElement.append(contentRootElement);

    return rootElement;
  }

  @override
  int parseCommentBadCount(Element element) {
    // badCount는 존재하지 않는다.
    return -1;
  }

  @override
  int parseCommentGoodCount(Element element) {
    final commentCoodCountElement =
        element.querySelector('div.comment_content_symph > button > strong');
    if (commentCoodCountElement == null) {
      return 0;
    }

    if (commentCoodCountElement.id.startsWith('setLikeCount') == false) {
      return 0;
    }

    final commentGoodCountStr = commentCoodCountElement.text;
    return int.tryParse(commentGoodCountStr) ?? 0;
  }

  @override
  String parseCommentWriteDatetime(Element element) {
    final writeDateTimeElement =
        element.querySelector('div.comment_time > span.timestamp');

    final writeDateTimeStr = writeDateTimeElement?.text ?? '';
    final writeDateTimeRegexp = RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}');
    final matched = writeDateTimeRegexp.firstMatch(writeDateTimeStr);
    if (matched == null) {
      return '';
    }

    return matched.group(0) ?? '';
  }

  @override
  bool parseReComment(Element element) {
    return element.classes.contains('re') ? true : false;
  }
}

class ClienCommentContent extends CommentContent {
  @override
  CommentContent createCommentContent({
    PostContentType contentType = PostContentType.none,
  }) {
    return ClienCommentContent()..setContentData(contentType: contentType);
  }

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    if (tag == 'input') {
      return PrefixParseResult.ignore;
    }

    if (tag == 'video') {
      var videoSourceElement = targetElement.querySelector('source');
      if (videoSourceElement == null) {
        return PrefixParseResult.ignore;
      }

      var videoUrl = videoSourceElement.attributes['src'] ?? '';
      setContentData(
        tag: 'video',
        contentType: PostContentType.video,
        content: videoUrl,
      );

      return PrefixParseResult.skip_child_parse;
    }

    if (tag == 'p' && targetElement.classes.contains('video') == true) {
      final iframeElement = targetElement.querySelector('iframe');
      if (iframeElement != null) {
        final youtubeUrl = iframeElement.attributes['src'] ?? '';
        if (youtubeUrl.isNotEmpty == true) {
          setContentData(
            tag: 'youtube',
            contentType: PostContentType.youtube,
            content: youtubeUrl,
          );
        }
      }

      return PrefixParseResult.skip_child_parse;
    }

    return super.prefixParseDefaultTag(tag, targetElement);
  }
}
