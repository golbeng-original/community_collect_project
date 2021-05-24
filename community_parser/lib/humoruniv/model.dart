import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:community_parser/core/parser.dart';
import 'package:community_parser/core/content_element.dart';
import 'package:community_parser/core/site_meta.dart';

class HumorunivSiteMeta extends SiteMeta {
  @override
  bool isErrorListPage(Document document) {
    if (document == null) {
      return true;
    }

    final errorReg = RegExp(r'^INTERNAL ERROR', caseSensitive: false);
    if (errorReg.hasMatch(document.body.text) == true) {
      return true;
    }

    return false;
  }

  @override
  bool isErrorPostPage(Document document) {
    var titleMeta = document.querySelector('meta[name=title]');
    return titleMeta == null ? true : false;
  }

  @override
  String getAdjustListUrl(int pageIndex, {String subUrl}) {
    return 'http://web.humoruniv.com/board/humor/list.html?pg=$pageIndex';
  }

  @override
  String getAdjustPostBodyUrl(
    String postId, {
    String subUrl,
  }) {
    return 'http://web.humoruniv.com/board/humor/read.html?number=$postId';
  }

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final listRoot = document.querySelector('div#cnts_list_new');
    final listUnits =
        listRoot?.querySelectorAll('table#post_list > tbody > tr');
    return listUnits ?? <Element>[];
  }

  @override
  Element getPostRootQuery(Document document) {
    final divElement = document.querySelector('div#wrap_cnts');
    final postBodyElement = divElement?.querySelector('wrap_copy#wrap_copy');
    return postBodyElement;
  }

  @override
  List<Element> getCommentListRootQuery(Document document) {
    final commentRootElement = document.querySelector('div.cmt_area');
    final commentelements = commentRootElement
        ?.querySelectorAll('table > tbody > tr[id^=\'comment_\']');

    return commentelements ?? <Element>[];
  }

  @override
  Element getPostItemFromBodyRootQuery(Document document) {
    var postAuthorInfoRootElement =
        document.querySelector('table#profile_table');
    if (postAuthorInfoRootElement == null) {
      return null;
    }

    return postAuthorInfoRootElement.querySelector('td > table');
  }
}

/// 웃긴대학 게시글 리스트 아이템 Parser
/// - List에서 List Unit Parsing하기
class HumorunivPostListItemParser extends PostListItemParser {
  HumorunivPostListItemParser(Document docuemnt) : super(docuemnt);

  @override
  String parsePostId(Element element) {
    final findPostId =
        RegExp(r'li_chk_pds-(?<id>[0-9]+)').firstMatch(element.id);
    return findPostId?.namedGroup('id') ?? '';
  }

  @override
  String parseBodyUrl(Element element) {
    final subjectElement = element.querySelector('td.li_sbj > a');
    if (subjectElement == null) {
      return '';
    }

    return subjectElement.attributes['href'] ?? '';
  }

  @override
  String parseThumbnailUrl(Element element) {
    final thumbnailElement = element.querySelector('td.li_num > div > a > img');
    if (thumbnailElement == null) {
      return '';
    }

    final thnmbnailSource = thumbnailElement.attributes['src'];
    final findThumbnail =
        RegExp(r'\?url=(?<url>.+)\?').firstMatch(thnmbnailSource ?? '');

    return findThumbnail?.namedGroup('url') ?? '';
  }

  @override
  String parseSubject(Element element) {
    final subjectElement = element.querySelector('td.li_sbj > a');
    final subjectHtml = subjectElement?.innerHtml?.trim() ?? '';
    final subjectSplit = subjectHtml.split('\n');
    if (subjectSplit.isEmpty == true) {
      return '';
    }

    return subjectSplit[0];
  }

  @override
  String parseAuthorIconUrl(Element element) {
    final authorRootElement =
        element.querySelector('td.li_icn > table > tbody > tr');

    if (authorRootElement == null) {
      return '';
    }

    final authorIconElement = authorRootElement.querySelector('img.hu_icon');
    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorRootElement =
        element.querySelector('td.li_icn > table > tbody > tr');

    if (authorRootElement == null) {
      return '';
    }

    final authorNameElement =
        authorRootElement?.querySelector('span.hu_nick_txt');

    return authorNameElement?.text?.trim() ?? '';
  }

  @override
  int parseCommentCount(Element element) {
    final subjectElement = element.querySelector('td.li_sbj > a');
    if (subjectElement == null) {
      return 0;
    }
    final commentElement =
        subjectElement?.querySelector('span.list_comment_num');

    if (commentElement == null) {
      return 0;
    }

    final commentHtml = commentElement.innerHtml.trim();
    final findComment = RegExp('[0-9]+').firstMatch(commentHtml ?? '');
    return int.tryParse(findComment?.group(0) ?? '0') ?? 0;
  }

  @override
  int parseViewCount(Element element) {
    final undTypeElement = element.querySelector('td.li_und');
    if (undTypeElement == null) {
      return 0;
    }

    var viewCountSource = undTypeElement.text.trim() ?? '';
    viewCountSource = viewCountSource.replaceAll(',', '');

    return int.tryParse(viewCountSource) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    var undTypeElement = element.querySelector('td.li_und');
    undTypeElement = undTypeElement?.nextElementSibling;
    if (undTypeElement == null) {
      return 0;
    }

    final goodCountElement = undTypeElement.querySelector('span');
    var goodCountSource = goodCountElement?.text?.trim() ?? '';
    goodCountSource = goodCountSource.replaceAll(',', '');

    return int.tryParse(goodCountSource) ?? 0;
  }

  @override
  int parseBadCount(Element element) {
    var undTypeElement = element.querySelector('td.li_und');
    undTypeElement = undTypeElement?.nextElementSibling;
    undTypeElement = undTypeElement?.nextElementSibling;

    if (undTypeElement == null) {
      return 0;
    }

    final badCountElement = undTypeElement.querySelector('font');
    var badCountSource = badCountElement?.text?.trim() ?? '';
    badCountSource = badCountSource.replaceAll(',', '');

    return int.tryParse(badCountSource) ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    var writeDate = '';
    final writeDateElement = element.querySelector('td.li_date > span.w_date');
    if (writeDateElement != null) {
      writeDate = writeDateElement.text ?? '';
    }

    var writeTime = '';
    final writeTimeElement = element.querySelector('td.li_date > span.w_time');
    if (writeTimeElement != null) {
      writeTime = writeTimeElement.text ?? '';
    }

    return DateTime.parse(writeDate + ' ' + writeTime).toString();
  }
}

/// 웃긴대학 게시글 리스트 아이템 Parser
/// - 게시글 본문에서 List Unit 요소 Parsing 하기
class HumorunivPostListItemFromBodyParser extends PostListItemParser {
  HumorunivPostListItemFromBodyParser(Document docuemnt) : super(docuemnt);

  @override
  String parsePostId(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 3) {
      return '';
    }

    final spanElements =
        trElements[2].querySelectorAll('div#content_info > span');
    if (spanElements == null) {
      return '';
    }

    return spanElements.first?.text ?? '';
  }

  @override
  String parseBodyUrl(Element element) {
    var metaElement = document.querySelector('meta[property=\'og:url\']');
    if (metaElement == null) {
      return '';
    }

    final bodyUrl = metaElement.attributes['content'] ?? '';
    return bodyUrl;
  }

  @override
  String parseThumbnailUrl(Element element) {
    var thumbnailRootElement = document.querySelector('wrap_copy div#wrap_img');

    thumbnailRootElement = thumbnailRootElement?.querySelector('a > img');
    if (thumbnailRootElement != null) {
      return thumbnailRootElement.attributes['src'] ?? '';
    }

    thumbnailRootElement =
        document.querySelector('wrap_copy div.simple_attach_img_div');
    thumbnailRootElement = thumbnailRootElement?.querySelector('a > img');
    if (thumbnailRootElement != null) {
      return thumbnailRootElement.attributes['src'] ?? '';
    }

    thumbnailRootElement =
        document.querySelector('wrap_copy div.comment_img_div');
    thumbnailRootElement = thumbnailRootElement?.querySelector('a > img');
    if (thumbnailRootElement != null) {
      return thumbnailRootElement.attributes['src'] ?? '';
    }

    thumbnailRootElement =
        document.querySelector('wrap_copy div.comment_img_div');
    thumbnailRootElement = thumbnailRootElement?.querySelector('img');
    if (thumbnailRootElement != null) {
      return thumbnailRootElement.attributes['src'] ?? '';
    }

    return '';
  }

  @override
  String parseSubject(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    final postSubjectElement =
        trElements?.first?.querySelector('td > span#ai_cm_title');

    return postSubjectElement?.text ?? '';
  }

  @override
  String parseAuthorIconUrl(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 2) {
      return '';
    }

    final authorIconElement = trElements[1].querySelector('img.hu_icon');
    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 2) {
      return '';
    }

    final authorNameElement = trElements[1].querySelector('span.hu_nick_txt');
    return authorNameElement?.text?.trim() ?? '';
  }

  @override
  int parseCommentCount(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 3) {
      return 0;
    }

    final commentCountElement = trElements[2].querySelector('span.re');
    var commentCount = commentCountElement?.text ?? '';

    commentCount = commentCount.replaceAll(',', '');
    return int.tryParse(commentCount) ?? 0;
  }

  @override
  int parseViewCount(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 3) {
      return 0;
    }

    final spanElements =
        trElements[2].querySelectorAll('div#content_info > span');
    if (spanElements == null) {
      return 0;
    }

    var viewCount = spanElements.last?.text ?? '';
    viewCount = viewCount.replaceAll(',', '');
    return int.tryParse(viewCount) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 3) {
      return 0;
    }

    final goodCountElement = trElements[2].querySelector('span#ok_div');
    var goodCount = goodCountElement?.text ?? '';
    goodCount = goodCount.replaceAll(',', '');

    return int.tryParse(goodCount) ?? 0;
  }

  @override
  int parseBadCount(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 3) {
      return 0;
    }

    final badCountElement = trElements[2].querySelector('span#not_ok_span');
    var badCount = badCountElement?.text ?? '';
    badCount = badCount.replaceAll(',', '');

    return int.tryParse(badCount) ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    var trElements = element.querySelectorAll('tbody > tr');
    if (trElements == null || trElements.length < 3) {
      return null;
    }

    final timeRootElement = trElements[2].querySelector('div#if_date');
    final writeDatetimeElement = timeRootElement?.querySelector('span');
    final writeDateTime = writeDatetimeElement?.text?.trim() ?? '';

    return DateTime.tryParse(writeDateTime)?.toString() ?? '';
  }
}

/// 웃긴대학 게시글 Parsing 결과
class HumorunivPostElement extends PostElement {
  @override
  PostElement createPostElement({
    PostContentType contentType = PostContentType.none,
  }) {
    return HumorunivPostElement()..setElementData(contentType: contentType);
  }

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    var targetId = targetElement.id.toLowerCase();
    if (tag == 'div' && targetId.startsWith('racy_show') == true) {
      return PrefixParseResult.ignore;
    }

    if (tag == 'div' && targetId.startsWith('racy_hidden') == false) {
      return super.prefixParseDefaultTag(tag, targetElement);
    }

    final imgElement =
        targetElement.querySelector('div[id^=\'comment_\'] > div > a > img');

    if (imgElement != null) {
      final imgUrl = imgElement.attributes['src'];
      if (imgUrl.isNotEmpty == true) {
        setElementData(
            tag: 'img', contentType: PostContentType.img, content: imgUrl);
        return PrefixParseResult.skip_child_parse;
      }
    }

    return super.prefixParseDefaultTag(tag, targetElement);
  }

  @override
  PrefixParseResult prefixParseTableTag(Element targetElement) {
    // table -> div로 단순화 한다....

    //return super._prefixParseTableTag(targetElement);

    final resourceElement = targetElement
        .querySelector('tbody > tr > td > div[id^=\'comment_file_\']');

    if (resourceElement != null) {
      setElementData(tag: 'div', contentType: PostContentType.container);

      //case1.1. 이미지 일경우 체크
      final imageElement =
          resourceElement.querySelector('a > div.comment_img_div > img');

      if (imageElement != null) {
        var imgeUrl = imageElement.attributes['src'] ?? '';
        if (imgeUrl.isNotEmpty) {
          addChildPostElement(
              tag: 'img', contentType: PostContentType.img, content: imgeUrl);
          return PrefixParseResult.skip_child_parse;
        }
      }

      final videoElement =
          resourceElement.querySelector('div.comment_img_div > a');

      if (videoElement != null) {
        final videoUrlSource = videoElement.attributes['href'] ?? '';

        var videoUrl = '';
        final regExp = RegExp(r"'(?<url>.+?)'", caseSensitive: false);
        final matchVideoUrls = regExp.allMatches(videoUrlSource);
        for (var match in matchVideoUrls) {
          final findVideUrl = match.namedGroup('url');
          if (findVideUrl.toLowerCase().endsWith('.mp4') == true) {
            videoUrl = findVideUrl;
            break;
          }
        }

        if (videoUrl.isNotEmpty) {
          addChildPostElement(
              tag: 'video',
              contentType: PostContentType.video,
              content: videoUrl);
          return PrefixParseResult.skip_child_parse;
        }
      }
    }

    return super.prefixParseTableTag(targetElement);
  }
}

/// 웃긴대학 Comment Unit Parsing하기
class HumorunivPostCommentItem extends PostCommentItem {
  @override
  bool parseReComment(Element element) {
    return element.querySelector('td > div#list_best_box > img') != null
        ? true
        : false;
  }

  @override
  String parseAuthorIconUrl(Element element) {
    final authorIconImgElement = element.querySelector('td img.hu_icon');
    return authorIconImgElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorNameElement = element.querySelector('td span.hu_nick_txt');
    return authorNameElement?.text ?? '';
  }

  @override
  int parseCommentGoodCount(Element element) {
    final commentGoodCountElement =
        element.querySelector('td > span.list_ok > span');
    final commentGoodCount = commentGoodCountElement?.text ?? '';
    return int.tryParse(commentGoodCount) ?? 0;
  }

  @override
  int parseCommentBadCount(Element element) {
    final commentBadCountElement = element.querySelector('td > span.list_no');
    final commentBadCount = commentBadCountElement?.text ?? '';
    return int.tryParse(commentBadCount) ?? 0;
  }

  @override
  String parseCommentWriteDatetime(Element element) {
    final commentWriteDatetimeElement =
        element.querySelector('td > span.list_date');
    final commentWriteDatetime =
        commentWriteDatetimeElement?.text?.trim() ?? '';
    return DateTime.tryParse(commentWriteDatetime)?.toString() ?? '';
  }

  @override
  CommentContent createCommentContent() {
    return HumorunivCommentContent();
  }

  @override
  Element getCommentContentElement(Element element) {
    final tdElements = element.querySelectorAll('td');
    if (tdElements.length < 3) {
      return null;
    }
    return tdElements[2];
  }
}

class HumorunivCommentContent extends CommentContent {
  @override
  CommentContent createPostElement({PostContentType contentType}) {
    return HumorunivCommentContent()..setContentData(contentType: contentType);
  }

  String _findVideoUrl(Element element) {
    var videoElement = element.querySelector('> a');
    if (videoElement == null) {
      return '';
    }

    final hrefSource = videoElement.attributes['href'] ?? '';

    final regExp = RegExp(r"'(?<url>.+?)'", caseSensitive: false);
    final matchVideoUrls = regExp.allMatches(hrefSource);
    for (var match in matchVideoUrls) {
      final findVideUrl = match.namedGroup('url');
      if (findVideUrl.toLowerCase().endsWith('.mp4') == true) {
        return findVideUrl;
      }
    }
    return '';
  }

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    if (targetElement.classes.contains('comment_img_div')) {
      // case 1. 동영상인지 체크
      final videoUrl = _findVideoUrl(targetElement);
      if (videoUrl != null && videoUrl.isNotEmpty == true) {
        setContentData(
          tag: 'video',
          contentType: PostContentType.video,
          content: videoUrl,
        );
        return PrefixParseResult.skip_child_parse;
      }
    }

    return super.prefixParseDefaultTag(tag, targetElement);
  }

  String _findAudioUrl(String onclickSource) {
    if (onclickSource == null) {
      return '';
    }

    final sourceRegexp =
        RegExp(r'^javascript:comment_mp3\([0-9]+,(?<url>.+)\);$');

    final matched = sourceRegexp.firstMatch(onclickSource);
    if (matched == null) {
      return '';
    }

    var audioUrlSource = matched.namedGroup('url');
    final alphabetRegexp = RegExp(r'"(?<alphabet>.?)\+?"');
    final alphabetMaches = alphabetRegexp.allMatches(audioUrlSource);
    if (alphabetMaches == null) {
      return '';
    }

    var audioUrl = '';
    for (var alphabetMache in alphabetMaches) {
      audioUrl += alphabetMache.namedGroup('alphabet');
    }
    return audioUrl;
  }

  @override
  PrefixParseResult prefixParseImgTag(Element targetElement) {
    var onclickSource = targetElement.attributes['onclick'] ?? '';
    var audioUrl = _findAudioUrl(onclickSource);
    if (audioUrl.isNotEmpty == true) {
      setContentData(
          tag: 'audio', contentType: PostContentType.audio, content: audioUrl);
      return PrefixParseResult.skip_child_parse;
    }

    return super.prefixParseImgTag(targetElement);
  }

  @override
  void postfixRoot(CommentContent rootCommentContent) {
    final exist = rootCommentContent.isExistContentType(
      contentType: PostContentType.audio,
    );

    if (exist == false) {
      return;
    }

    var contents = rootCommentContent
        .findCommentContentAllFromContentType(PostContentType.text);

    final targetRegexp = RegExp(r'원본용량.?:.?([0-9]+)KB');
    for (var content in contents) {
      if (targetRegexp.hasMatch(content.content) == true) {
        content.removeSelf();
        break;
      }
    }
  }
}
