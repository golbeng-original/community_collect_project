import 'package:html/dom.dart';

import '../community_parser.dart';
import 'model.dart';

class HumorunivP1SiteMeta extends HumorunivSiteMeta {
  HumorunivP1SiteMeta() : super(isRefreshCookieRequest: true);

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final rowElements =
        document.querySelectorAll('div#item > table > tbody > tr');

    if (rowElements.isEmpty) {
      return <Element>[];
    }

    var postItemList = <Element>[];

    var rowRootElement = Element.tag('div');
    var curr = 0;

    while (curr < rowElements.length) {
      var tdElement = rowElements[curr].querySelector('td');
      if (tdElement?.nodes.length == 1 &&
          tdElement?.nodes[0].nodeType == Node.TEXT_NODE) {
        postItemList.add(rowRootElement);
        rowRootElement = Element.tag('div');
        curr++;
        continue;
      }

      rowRootElement.append(rowElements[curr]);
      curr++;
    }

    return postItemList;
  }

  @override
  Element? getPostRootQuery(Document document) {
    final divElement = document.querySelector('div#cnts');
    final postBodyElement = divElement?.querySelector('wrap_copy#wrap_copy');
    return postBodyElement;
  }
}

/// 웃긴대학 1칸 그림 게시글 리스트 아이템 Parser
/// - List에서 List Unit Parsing하기
class HumorunivP1PostListItemParser extends PostListItemParser {
  List<Element>? _trElements;
  List<Element>? _headTrElements;
  List<Element>? _extraSpanElements;

  HumorunivP1PostListItemParser(Document docuemnt) : super(docuemnt);

  final _countRegExp = RegExp(r'(?<count>[0-9]+)');

  bool _isValid() {
    return _trElements != null;
  }

  bool _isHeaderValid() {
    return _headTrElements != null && _headTrElements!.length == 3;
  }

  bool _isExtraValid() {
    return _extraSpanElements != null && _extraSpanElements!.length == 5;
  }

  void _parseThumbPostElement() {}

  @override
  void init(Element element) {
    _trElements =
        element.children.where((element) => element.localName == 'tr').toList();
    if (_isValid() == false) {
      return;
    }

    final firstTbodyElement =
        _trElements![0].querySelector('td > table > tbody');
    //
    _headTrElements = firstTbodyElement?.children
        .where((element) => element.localName == 'tr')
        .toList();
    if (_isHeaderValid() == false) {
      return;
    }

    _extraSpanElements =
        _headTrElements![1].querySelectorAll('span.w_extra > span');

    _parseThumbPostElement();
  }

  @override
  String parsePostId(Element element) {
    var bodyUrl = parseBodyUrl(element);

    final postIdRegExp = RegExp(r'number=(?<postId>[0-9]+)');
    final matched = postIdRegExp.firstMatch(bodyUrl);
    if (matched == null) {
      return '';
    }

    return matched.namedGroup('postId') ?? '';
  }

  @override
  String parseBodyUrl(Element element) {
    if (_isHeaderValid() == false) {
      return '';
    }

    final subjectRootElement =
        _headTrElements![0].querySelector('span.w_subject > a');
    if (subjectRootElement == null) {
      return '';
    }

    return subjectRootElement.attributes['href'] ?? '';
  }

  @override
  String parseSubject(Element element) {
    if (_isHeaderValid() == false) {
      return '';
    }

    final subjectRootElement =
        _headTrElements![0].querySelector('span.w_subject > a');

    if (subjectRootElement == null) {
      return '';
    }

    var textElement = subjectRootElement.nodes
        .firstWhere((element) => element.nodeType == Node.TEXT_NODE);

    return textElement.text?.trim() ?? '';
  }

  @override
  String parseThumbnailUrl(Element element) {
    return '';
  }

  @override
  String parseAuthorIconUrl(Element element) {
    if (_isHeaderValid() == false) {
      return '';
    }

    var authorIconElement = _headTrElements![0].querySelector('img.hu_icon');
    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    if (_isHeaderValid() == false) {
      return '';
    }

    var authorNameElement =
        _headTrElements![0].querySelector('span.hu_nick_txt');
    if (authorNameElement == null) {
      return '';
    }

    return authorNameElement.text;
  }

  @override
  int parseCommentCount(Element element) {
    if (_isHeaderValid() == false) {
      return 0;
    }

    final commentCountElement = _headTrElements![0]
        .querySelector('span.w_subject > a > span.list_comment_num');

    var commentCountStr = commentCountElement?.text ?? '';
    commentCountStr = commentCountStr.replaceAll('[', '');
    commentCountStr = commentCountStr.replaceAll(']', '');

    return int.tryParse(commentCountStr) ?? 0;
  }

  @override
  int parseViewCount(Element element) {
    if (_isExtraValid() == false) {
      return 0;
    }

    final viewCountStr = _extraSpanElements![4].text;
    final matched = _countRegExp.firstMatch(viewCountStr);
    if (matched == null) {
      return 0;
    }

    return int.tryParse(matched.namedGroup('count') ?? '') ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    if (_isExtraValid() == false) {
      return 0;
    }

    final goodCountStr = _extraSpanElements![0].text;
    final matched = _countRegExp.firstMatch(goodCountStr);
    if (matched == null) {
      return 0;
    }

    return int.tryParse(matched.namedGroup('count') ?? '') ?? 0;
  }

  @override
  int parseBadCount(Element element) {
    if (_isExtraValid() == false) {
      return 0;
    }

    final badCountStr = _extraSpanElements![1].text;
    final matched = _countRegExp.firstMatch(badCountStr);
    if (matched == null) {
      return 0;
    }

    return int.tryParse(matched.namedGroup('count') ?? '') ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    if (_isHeaderValid() == false) {
      return '';
    }

    final dateElement = _headTrElements![1].querySelector('span.w_date');
    final timeElement = _headTrElements![1].querySelector('span.w_time');

    if (dateElement == null || timeElement == null) {
      return '';
    }

    return '${dateElement.text} ${timeElement.text}';
  }

  @override
  dynamic parseExtraData_1(Element element) {
    if (_isValid() == false || _isHeaderValid() == false) {
      return;
    }

    final rootElement = Element.html('<table><tbody></tbody></table>');
    var tbodyElement = rootElement.querySelector('tbody')!;

    tbodyElement.append(_headTrElements![2]);
    tbodyElement.append(_trElements![1]);

    //
    var thumbnailPostElement = HumorunivP1ThumbPostElement();
    thumbnailPostElement.parseRoot(rootElement);

    return thumbnailPostElement;
  }

  @override
  dynamic parseExtraData_2(Element element) {
    if (_isValid() == false || _isHeaderValid() == false) {
      return;
    }

    final rootElement = Element.html('<table><tbody></tbody></table>');
    var tbodyElement = rootElement.querySelector('tbody')!;

    Element? commentAuthor;
    var contentElements = <Element>[];

    var currIndex = 2;
    while (currIndex < _trElements!.length) {
      final currTrElement = _trElements![currIndex];

      final iconElement = currTrElement.querySelector('img.hu_icon');
      if (iconElement != null) {
        commentAuthor = currTrElement;
        break;
      }

      contentElements.add(currTrElement);
      currIndex++;
    }

    if (commentAuthor != null) {
      tbodyElement.append(commentAuthor);
      contentElements.forEach((element) {
        tbodyElement.append(element);
      });
    }

    var thumbnailPostCommentItem = HumorunivP1ThumbnailPostCommentItem();
    thumbnailPostCommentItem.parseRoot(rootElement);

    return thumbnailPostCommentItem;
  }
}

/// 웃긴대학 1칸 웃긴제목 내용
class HumorunivP1ThumbPostElement extends HumorunivPostElement {
  @override
  PostElement createPostElement({
    PostContentType contentType = PostContentType.none,
  }) {
    return HumorunivP1ThumbPostElement()
      ..setElementData(contentType: contentType);
  }
}

/// 웃긴대학 1칸 웃긴제목 베스트제목 Comment 정보
/// 웃긴대학 Comment Unit Parsing하기
class HumorunivP1ThumbnailPostCommentItem extends PostCommentItem {
  var _trElements = <Element>[];

  bool _isValid() {
    return _trElements.isNotEmpty ? true : false;
  }

  @override
  void init(Element element) {
    final tbodyElement = element.querySelector('table > tbody');

    if (tbodyElement != null) {
      _trElements = tbodyElement.children.toList();
    }
  }

  @override
  bool parseReComment(Element element) {
    return false;
  }

  @override
  String parseAuthorIconUrl(Element element) {
    if (_isValid() == false) {
      return '';
    }

    final authorIconElement = _trElements[0].querySelector('img.hu_icon');
    if (authorIconElement == null) {
      return '';
    }

    return authorIconElement.attributes['src'] ?? '';
  }

  @override
  String parseAuthorName(Element element) {
    if (_isValid() == false) {
      return '';
    }

    final authorIconElement = _trElements[0].querySelector('img.hu_icon');
    if (authorIconElement == null || authorIconElement.parent == null) {
      return '';
    }

    if (authorIconElement.parent!.localName != 'td') {
      return '';
    }

    final authorNameElement = authorIconElement.parent!.nextElementSibling;
    return authorNameElement?.text ?? '';
  }

  @override
  int parseCommentGoodCount(Element element) {
    if (_isValid() == false) {
      return 0;
    }

    final goodCountElement =
        _trElements[0].querySelector('span[id^=\'ans_ok_div\']');
    final goodCountStr = goodCountElement?.text ?? '';

    return int.tryParse(goodCountStr) ?? 0;
  }

  @override
  int parseCommentBadCount(Element element) {
    if (_isValid() == false) {
      return 0;
    }

    final goodCountElement =
        _trElements[0].querySelector('span[id^=\'ans_ok_div\']');

    if (goodCountElement == null) {
      return 0;
    }

    final badCountElement = goodCountElement.nextElementSibling;
    if (badCountElement == null) {
      return 0;
    }

    final badCountRegexp = RegExp(r'(?<count>[0-9]+)');
    final matched = badCountRegexp.firstMatch(badCountElement.text);
    if (matched == null) {
      return 0;
    }

    final badCountStr = matched.namedGroup('count') ?? '';
    return int.tryParse(badCountStr) ?? 0;
  }

  @override
  String parseCommentWriteDatetime(Element element) {
    return '';
  }

  @override
  CommentContent createCommentContent() {
    return HumorunivP1ThumbCommentContent();
  }

  @override
  Element getCommentContentElement(Element element) {
    final rootElement = Element.html('<table><tbody></tbody></table>');
    var tbodyElement = rootElement.querySelector('tbody')!;

    var contentTrElements = _trElements.skip(1);
    for (var contentTrElement in contentTrElements) {
      tbodyElement.append(contentTrElement);
    }

    return rootElement;
  }
}

/// 웃긴대학 1칸 웃긴제목 베스트제목 내용
class HumorunivP1ThumbCommentContent extends HumorunivCommentContent {
  @override
  @override
  CommentContent createCommentContent({
    PostContentType contentType = PostContentType.none,
  }) {
    return HumorunivP1ThumbCommentContent()
      ..setContentData(contentType: contentType);
  }
}
