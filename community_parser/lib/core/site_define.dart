import 'package:html/dom.dart';

import 'package:community_parser/humoruniv/model.dart' as humoruniv;
import 'package:community_parser/humoruniv/model_p1.dart' as humoruniv_p1;
import 'package:community_parser/humoruniv/model_p2.dart' as humoruniv_p2;
import 'package:community_parser/humoruniv/model_p4.dart' as humoruniv_p4;
import 'package:community_parser/dogdrip/model.dart' as dogdrip;
import 'package:community_parser/todayhumor/model.dart' as todayhumor;
import 'package:community_parser/clien/model.dart' as clien;

import 'parser.dart';
import 'site_meta.dart';
import 'content_element.dart';

/// SiteType
/// - 사이트 도메인을 표현한다.
/// - 도메인별로 표현하는 페이지. Url이 다를 수 있으므로 여러개 가 있을 수 있다.
enum SiteType {
  none,
  humoruniv,
  humoruniv_p1,
  humoruniv_p2,
  humoruniv_p4,
  dogdrip,
  todayHumor,
  clien,
}

/// 사이트 도메인에 맞는 구현체 SiteMeta를 등록한다.
Map<SiteType, SiteMeta> _siteMetaMap = {
  SiteType.humoruniv: humoruniv.HumorunivSiteMeta(),
  SiteType.humoruniv_p1: humoruniv_p1.HumorunivP1SiteMeta(),
  SiteType.humoruniv_p2: humoruniv_p2.HumorunivP2SiteMeta(),
  SiteType.humoruniv_p4: humoruniv_p4.HumorunivP4SiteMeta(),
  SiteType.dogdrip: dogdrip.DogdripSiteMeta(),
  SiteType.todayHumor: todayhumor.TodayHumorSiteMeta(),
  SiteType.clien: clien.ClienSiteMeta(),
};

/// SiteType으로 부터 SiteMeta 정보 가져오기
SiteMeta? getSiteMeta({
  required SiteType siteType,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    return null;
  }

  return _siteMetaMap[siteType];
}

/// SiteType으로 포스트 리스트 Uri 가져오기
/// - @argument는 미리 정의해둔 url query 관련 매개변수 넘기면 된다.
Uri getPageUri({
  required SiteType siteType,
  required int pageIndex,
  String subUrl = '',
  Map<String, String>? query,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  final url = _siteMetaMap[siteType]!.getListUrl(
    query: query,
    pageIndex: pageIndex,
    subUrl: subUrl,
  );

  var uri = Uri.parse(url);
  return uri;
}

/// SiteType으로 포스트 본문 Uri 가져오기
Uri getPostUri({
  required SiteType siteType,
  required String postId,
  Map<String, String>? query,
  String subUrl = '',
  bool needQuestionMark = false,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  final url = _siteMetaMap[siteType]!.getPostBodyUrl(
    postId,
    query: query,
    subUrl: subUrl,
    needQuestionMark: needQuestionMark,
  );

  return Uri.parse(url);
}

/// SiteType으로 Comment Uri 가져오기
Uri getCommentUri({
  required SiteType siteType,
  required String postId,
  String subUrl = '',
  Map<String, String>? query,
  bool needQuestionMark = false,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  var url = _siteMetaMap[siteType]!.getSpecificCommentUrl(
    postId,
    subUrl: subUrl,
    query: query,
    needQuestionMark: needQuestionMark,
  );

  if (url != null) {
    return Uri.parse(url);
  }

  return getPostUri(
    siteType: siteType,
    postId: postId,
    subUrl: subUrl,
    query: query,
    needQuestionMark: needQuestionMark,
  );
}

/// SiteType으로 포스트 리스트 dom Elements 가져오기
List<Element> getPagePostListElements({
  required SiteType siteType,
  required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  if (_siteMetaMap[siteType]!.isErrorListPage(document) == true) {
    throw ArgumentError('document is ErrorListPage');
  }

  return _siteMetaMap[siteType]!.getPostItemListRootQuery(document);
}

/// SiteType으로 포스트의 작성자 dom Elements 가져오기
Element? getPostAuthorElement({
  required SiteType siteType,
  required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  if (_siteMetaMap[siteType]!.isErrorPostPage(document) == true) {
    throw ArgumentError('document is ErrorPostPage');
  }

  return _siteMetaMap[siteType]!.getPostItemFromBodyRootQuery(document);
}

/// SiteType으로 포스트 Body Root dom Elements 가져오기
Element? getPostRootElement(
  SiteType siteType, {
  required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  if (_siteMetaMap[siteType]!.isErrorPostPage(document) == true) {
    throw ArgumentError('document is ErrorPostPage');
  }

  return _siteMetaMap[siteType]!.getPostRootQuery(document);
}

/// SiteType으로 post Comment String상태로 부터 Document가져오기
Document getPostCommentDocument({
  required SiteType siteType,
  required Document commentDocument,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  return _siteMetaMap[siteType]!.getCommentDocument(commentDocument);
}

/// SiteType으로 포스트 Comment List Root Elements 가져오기
List<Element> getPostCommentListElements({
  required SiteType siteType,
  required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    throw ArgumentError('siteType is not define');
  }

  if (_siteMetaMap[siteType]!.isErrorCommentPage(document) == true) {
    throw ArgumentError('document is ErrorPostPage');
  }

  return _siteMetaMap[siteType]!.getCommentListRootQuery(document);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/// 구현체로 부터 어떤 도메인 타입(SiteType)인지 가져온다.
SiteType getSiteType<T>() {
  switch (T) {
    case humoruniv.HumorunivPostListItemParser:
    case humoruniv.HumorunivPostListItemFromBodyParser:
    case humoruniv.HumorunivPostElement:
    case humoruniv.HumorunivPostCommentItem:
      return SiteType.humoruniv;
    case humoruniv_p1.HumorunivP1PostListItemParser:
      return SiteType.humoruniv_p1;
    case humoruniv_p2.HumorunivP2PostListItemParser:
      return SiteType.humoruniv_p2;
    case humoruniv_p4.HumorunivP4PostListItemParser:
    case humoruniv_p4.HumorunivP4PostElement:
    case humoruniv_p4.HumorunivTitlePostCommentItem:
      return SiteType.humoruniv_p4;
    case dogdrip.DogdripPostListItemParser:
    case dogdrip.DogdripPostListItemFromBodyParser:
    case dogdrip.DogdripPostElement:
    case dogdrip.DogdripPostCommentItem:
      return SiteType.dogdrip;
    case todayhumor.TodayHumorPostListItemParser:
    case todayhumor.TodayHumorPostListItemFromBodyParser:
    case todayhumor.TodayHumorPostElement:
    case todayhumor.TodayHumorPostCommentItem:
      return SiteType.todayHumor;
    case clien.ClienPostListItemParser:
    case clien.ClienPostListItemFromBodyParser:
    case clien.ClienPostElement:
    case clien.ClienPostCommentItem:
      return SiteType.clien;
  }

  return SiteType.none;
}

/// SiteType PostElement 구현체를 가져온다.
PostElement? getPostElementInstance(SiteType siteType) {
  switch (siteType) {
    case SiteType.none:
      break;
    case SiteType.humoruniv:
    case SiteType.humoruniv_p1:
    case SiteType.humoruniv_p2:
      return humoruniv.HumorunivPostElement();
    case SiteType.humoruniv_p4:
      return humoruniv_p4.HumorunivP4PostElement();
    case SiteType.dogdrip:
      return dogdrip.DogdripPostElement();
    case SiteType.todayHumor:
      return todayhumor.TodayHumorPostElement();
    case SiteType.clien:
      return clien.ClienPostElement();
  }

  return null;
}

/// SiteType으로부터 PostListItemParser 구현체를 가져온다.
PostListItemParser? getPostListItemParser(
  SiteType siteType, {
  required Document document,
  required bool isFromBody,
}) {
  switch (siteType) {
    case SiteType.none:
      break;
    case SiteType.humoruniv:
      return isFromBody
          ? humoruniv.HumorunivPostListItemFromBodyParser(document)
          : humoruniv.HumorunivPostListItemParser(document);
    case SiteType.humoruniv_p1:
      return isFromBody
          ? humoruniv.HumorunivPostListItemFromBodyParser(document)
          : humoruniv_p1.HumorunivP1PostListItemParser(document);
    case SiteType.humoruniv_p2:
      return isFromBody
          ? humoruniv.HumorunivPostListItemFromBodyParser(document)
          : humoruniv_p2.HumorunivP2PostListItemParser(document);
    case SiteType.humoruniv_p4:
      return isFromBody
          ? humoruniv.HumorunivPostListItemFromBodyParser(document)
          : humoruniv_p4.HumorunivP4PostListItemParser(document);
    case SiteType.dogdrip:
      return isFromBody
          ? dogdrip.DogdripPostListItemFromBodyParser(document)
          : dogdrip.DogdripPostListItemParser(document);
    case SiteType.todayHumor:
      return isFromBody
          ? todayhumor.TodayHumorPostListItemFromBodyParser(document)
          : todayhumor.TodayHumorPostListItemParser(document);
    case SiteType.clien:
      return isFromBody
          ? clien.ClienPostListItemFromBodyParser(document)
          : clien.ClienPostListItemParser(document);
  }

  return null;
}

PostCommentItem? getPostCommentInstance<T extends PostCommentItem>() {
  switch (T) {
    case humoruniv.HumorunivPostCommentItem:
      return humoruniv.HumorunivPostCommentItem();
    //
    case humoruniv_p4.HumorunivTitlePostCommentItem:
      return humoruniv_p4.HumorunivTitlePostCommentItem();
    //
    case dogdrip.DogdripPostCommentItem:
      return dogdrip.DogdripPostCommentItem();
    //
    case todayhumor.TodayHumorPostCommentItem:
      return todayhumor.TodayHumorPostCommentItem();
    //
    case clien.ClienPostCommentItem:
      return clien.ClienPostCommentItem();
  }

  return null;
}
