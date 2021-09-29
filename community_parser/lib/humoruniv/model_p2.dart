import 'package:html/dom.dart';

import '../community_parser.dart';
import 'model.dart';

class HumorunivP2SiteMeta extends HumorunivSiteMeta {
  HumorunivP2SiteMeta() : super(isRefreshCookieRequest: true);

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final rowElements = document.querySelectorAll('div#cnts_list_new div.gnk');

    return rowElements;
  }
}

/// 웃긴대학 2칸 그림 게시글 리스트 아이템 Parser
/// - List에서 List Unit Parsing하기
class HumorunivP2PostListItemParser extends PostListItemParser {
  HumorunivP2PostListItemParser(Document docuemnt) : super(docuemnt);

  @override
  String parsePostId(Element element) {
    final postIdElement = element.querySelector('p.num');

    return postIdElement?.text ?? '';
  }

  @override
  String parseBodyUrl(Element element) {
    final subjectElement = element.querySelector('p.sbj > a');
    if (subjectElement == null) {
      return '';
    }

    return subjectElement.attributes['href'] ?? '';
  }

  @override
  String parseSubject(Element element) {
    final subjectRootElement = element.querySelector('p.sbj > a');
    if (subjectRootElement == null) {
      return '';
    }

    var subjectElement = subjectRootElement.nodes
        .firstWhere((element) => element.nodeType == Node.TEXT_NODE);

    return subjectElement.text ?? '';
  }

  @override
  String parseThumbnailUrl(Element element) {
    final thumbnailElement = element.querySelector('div.gnk_bd > a > img');
    if (thumbnailElement == null) {
      return '';
    }

    return thumbnailElement.attributes['src'] ?? '';
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
    final commentElement = element.querySelector('span.list_comment_num');
    var commentStr = commentElement?.text ?? '';
    commentStr = commentStr.replaceAll('[', '');
    commentStr = commentStr.replaceAll(']', '');

    return int.tryParse(commentStr) ?? 0;
  }

  @override
  int parseViewCount(Element element) {
    return -1;
  }

  @override
  int parseGoodCount(Element element) {
    final trElement =
        element.querySelector('div.gnk_info > table > tbody > tr');
    final tdElements = trElement?.querySelectorAll('td');
    if (tdElements == null || tdElements.length != 6) {
      return 0;
    }

    final goodCountElement = tdElements[3].querySelector('span');
    final goodCountStr = goodCountElement?.text ?? '';

    return int.tryParse(goodCountStr) ?? 0;
  }

  @override
  int parseBadCount(Element element) {
    final trElement =
        element.querySelector('div.gnk_info > table > tbody > tr');
    final tdElements = trElement?.querySelectorAll('td');
    if (tdElements == null || tdElements.length != 6) {
      return 0;
    }

    final badCountStr = tdElements[5].text;
    return int.tryParse(badCountStr) ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    final trElements =
        element.querySelectorAll('div.gnk_info > table > tbody > tr');

    if (trElements.length != 2) {
      return '';
    }

    final tdElements = trElements[1].querySelectorAll('td');
    if (tdElements.length != 2) {
      return '';
    }

    var writeDateTimeStr = tdElements[1].text;
    writeDateTimeStr = writeDateTimeStr.replaceAll('[', '');
    writeDateTimeStr = writeDateTimeStr.replaceAll(']', '');

    return writeDateTimeStr;
  }
}
