import 'package:community_parser/core/content_element.dart';
import 'package:html/dom.dart';

import '../community_parser.dart';
import 'model.dart';

class HumorunivP4SiteMeta extends HumorunivSiteMeta {
  HumorunivP4SiteMeta() : super(isRefreshCookieRequest: true);

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final rowElements = document
        .querySelectorAll('div#cnts_list_new > div > table > tbody > tr');

    var postItemElements = <Element>[];
    for (var rowElement in rowElements) {
      var columnElements = rowElement.querySelectorAll('td > div#item');
      if (columnElements == null) {
        continue;
      }

      postItemElements.addAll(columnElements);
    }

    return postItemElements;
  }

  @override
  List<Element> getCommentListRootQuery(Document document) {
    final titleCommentBestElement =
        document.body?.querySelector('div#wrap_answer_best');

    final titleCommentElement =
        document.body?.querySelector('div#wrap_answer_etc');

    if (titleCommentBestElement != null || titleCommentElement != null) {
      return _getTitleCommentListRootQuery(
        titleCommentBestElement,
        titleCommentElement,
      );
    }

    return super.getCommentListRootQuery(document);
  }

  List<Element> _getTitleCommentListRootQuery(
    Element? bestTitleCommentElement,
    Element? titleCommentElement,
  ) {
    var titleCommentElements = <Element>[];

    var bestCommentElement = bestTitleCommentElement?.querySelector('div.cnt');
    if (bestCommentElement != null) {
      bestCommentElement.classes.add('best');
      titleCommentElements.add(bestCommentElement);
    }

    var commentRootElements = titleCommentElement?.querySelectorAll('div.cnt');
    if (commentRootElements != null) {
      titleCommentElements.addAll(commentRootElements);
    }

    return titleCommentElements;
  }
}

/// 웃긴대학 4칸 그림 게시글 리스트 아이템 Parser
/// - List에서 List Unit Parsing하기
class HumorunivP4PostListItemParser extends PostListItemParser {
  static final _staticPostIdRegexp = RegExp(r'w_subject_(?<id>[0-9]+)');

  List<Element>? _extraSpanElements;

  HumorunivP4PostListItemParser(Document docuemnt) : super(docuemnt);

  bool _checkExtraSpanElements(Element element) {
    if (_extraSpanElements != null) {
      return true;
    }

    _extraSpanElements = element.querySelectorAll('span.w_extra > span');
    if (_extraSpanElements == null) {
      return false;
    }

    return true;
  }

  String _getCountText(int index) {
    if (_extraSpanElements == null) {
      return '';
    }

    if (_extraSpanElements!.length <= index) {
      return '';
    }

    var countStr = '';
    for (var child in _extraSpanElements![index].nodes) {
      if (child.nodeType == Node.TEXT_NODE) {
        countStr = child.text?.trim() ?? '';
        break;
      }
    }

    return countStr;
  }

  @override
  String parsePostId(Element element) {
    final subjectElement = element.querySelector('span.w_subject > a > span');
    if (subjectElement == null) {
      return '';
    }

    final matched = _staticPostIdRegexp.firstMatch(subjectElement.id);
    if (matched == null) {
      return '';
    }

    final id = matched.namedGroup('id') ?? '';
    return id;
  }

  @override
  String parseBodyUrl(Element element) {
    final subjectAElement = element.querySelector('span.w_subject > a');
    if (subjectAElement == null) {
      return '';
    }

    return subjectAElement.attributes['href'] ?? '';
  }

  @override
  String parseThumbnailUrl(Element element) {
    final imgElement = element.querySelector('img#thumb_img');
    if (imgElement == null) {
      return '';
    }

    return imgElement.attributes['src'] ?? '';
  }

  @override
  String parseSubject(Element element) {
    final subjectElement = element.querySelector('span.w_subject > a > span');
    return subjectElement?.text ?? '';
  }

  @override
  String parseAuthorIconUrl(Element element) {
    final authorIconElement = element.querySelector('img.hu_icon');
    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorNameElement = element.querySelector('span.hu_nick_txt');
    return authorNameElement?.text ?? '';
  }

  @override
  int parseCommentCount(Element element) {
    final commentCountElement = element.querySelector('span.list_comment_num');
    var commentCountStr = commentCountElement?.text ?? '';

    commentCountStr = commentCountStr.replaceAll('[', '');
    commentCountStr = commentCountStr.replaceAll(']', '');

    return int.tryParse(commentCountStr) ?? 0;
  }

  @override
  int parseViewCount(Element element) {
    if (_checkExtraSpanElements(element) == false) {
      return 0;
    }

    var viewCountStr = '';
    if (_extraSpanElements!.length == 2) {
      viewCountStr = _getCountText(1);
    } else if (_extraSpanElements!.length == 3) {
      viewCountStr = _getCountText(2);
    }

    return int.tryParse(viewCountStr) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    if (_checkExtraSpanElements(element) == false) {
      return 0;
    }

    var viewCountStr = '';
    if (_extraSpanElements!.length == 2) {
      viewCountStr = _getCountText(0);
    } else if (_extraSpanElements!.length == 3) {
      viewCountStr = _getCountText(0);
    }
    return int.tryParse(viewCountStr) ?? 0;
  }

  @override
  int parseBadCount(Element element) {
    if (_checkExtraSpanElements(element) == false) {
      return 0;
    }

    if (_extraSpanElements!.length != 3) {
      return -1;
    }

    var viewCountStr = _getCountText(0);
    return int.tryParse(viewCountStr) ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    final dateElement = element.querySelector('span.w_date');
    final timeElement = element.querySelector('span.w_time');

    if (dateElement == null || timeElement == null) {
      return '';
    }

    return '${dateElement.text} ${timeElement.text}';
  }
}

/// 웃긴대학 4칸 그림 게시글 Parsing 결과
class HumorunivP4PostElement extends HumorunivPostElement {
  @override
  PostElement createPostElement({
    PostContentType contentType = PostContentType.none,
  }) {
    return HumorunivP4PostElement()..setElementData(contentType: contentType);
  }

  void _faceElementOrganize(Element targetElement) {
    final trElement = targetElement.querySelector('table > tbody > tr');

    final tdElements = trElement?.children
        .where((element) => element.nodeType == Node.ELEMENT_NODE);

    if (tdElements != null && tdElements.length == 3) {
      tdElements.elementAt(1).remove();
      tdElements.elementAt(2).remove();
    }
  }

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    var targetId = targetElement.id.toLowerCase();

    // face 게시물에 대해 처리 해야 한다.
    if (tag == 'div' && targetId == 'face') {
      _faceElementOrganize(targetElement);
      return super.prefixParseDefaultTag(tag, targetElement);
    }

    return super.prefixParseDefaultTag(tag, targetElement);
  }

  @override
  PrefixParseResult prefixParseTableTag(Element targetElement) {
    // fasion post 에서 걸러내야 할 부분
    if (targetElement.classes.contains('bd2') == true) {
      return PrefixParseResult.ignore;
    }

    return super.prefixParseTableTag(targetElement);
  }
}

class HumorunivTitlePostCommentItem extends PostCommentItem {
  var bestComment = false;

  @override
  String parseAuthorIconUrl(Element element) {
    final authorIconElement = element.querySelector('img.hu_icon');
    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorName = element.querySelector('span.hu_nick_txt');
    return authorName?.text ?? '';
  }

  @override
  CommentContent createCommentContent() {
    return HumorunivCommentContent();
  }

  @override
  Element getCommentContentElement(Element element) {
    var rootElement = Element.tag('div');

    for (var child in element.children) {
      if (child.localName == 'style') {
        continue;
      }

      if (child.classes.contains('w_info') == true) {
        continue;
      }

      if (child.classes.contains('answer_btn') == true) {
        continue;
      }

      rootElement.append(child);
    }

    return rootElement;
  }

  @override
  int parseCommentBadCount(Element element) {
    final countElements = element.querySelectorAll('dd.und');
    if (countElements == null || countElements.length != 2) {
      return 0;
    }
    var badCountStr = countElements[0].text;

    final badCountRegexp = RegExp(r'(?<count>[0-9]+)');
    final matched = badCountRegexp.firstMatch(badCountStr);
    if (matched == null) {
      return 0;
    }

    return int.tryParse(matched.namedGroup('count') ?? '') ?? 0;
  }

  @override
  int parseCommentGoodCount(Element element) {
    final countElements = element.querySelectorAll('dd.und');
    if (countElements == null || countElements.length != 2) {
      return 0;
    }

    final goodCountElement = countElements[1].querySelector('span.r');
    final goodCountStr = goodCountElement?.text ?? '';

    return int.tryParse(goodCountStr) ?? 0;
  }

  @override
  String parseCommentWriteDatetime(Element element) {
    final writeDatetimeElement = element.querySelector('dd.date');
    var writeDateTimeStr = writeDatetimeElement?.text ?? '';
    writeDateTimeStr = writeDateTimeStr.replaceAll('[', '');
    writeDateTimeStr = writeDateTimeStr.replaceAll(']', '');

    return writeDateTimeStr;
  }

  @override
  bool parseReComment(Element element) {
    return false;
  }

  @override
  void parseCommentEtc(Element element) {
    bestComment = element.classes.contains('best') ? true : false;
  }
}
