import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:community_parser/core/parser.dart';
import 'package:community_parser/core/site_meta.dart';

import 'package:community_parser/humoruniv/model.dart' as humoruniv;

enum SiteType {
  none,
  humoruniv,
}

Map<SiteType, SiteMeta> _siteMetaMap = {
  SiteType.humoruniv: humoruniv.HumorunivSiteMeta(),
};

////////////////////////////////////////////////////////////////////////////////
/// SiteType으로 포스트 리스트 Uri 가져오기
/// @argument는 미리 정의해둔 url query 관련 매개변수 넘기면 된다.
Uri getPageUri({
  @required SiteType siteType,
  @required int pageIndex,
  Map<String, String> query,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    return null;
  }

  final url =
      _siteMetaMap[siteType].getListUrl(query: query, pageIndex: pageIndex);
  var uri = Uri.parse(url);
  return uri;
}

/// SiteType으로 포스트 본문 Uri 가져오기
Uri getPostUri({@required SiteType siteType, @required String postfixUrl}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    return null;
  }

  final url = _siteMetaMap[siteType].getPostBodyUrl(postfixUrl);

  var uri = Uri.parse(url);
  return uri;
}

/// SiteType으로 포스트 리스트 dom Elements 가져오기
List<Element> getPagePostListElements({
  @required SiteType siteType,
  @required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    return <Element>[];
  }

  return _siteMetaMap[siteType].getPostItemListRootQuery(document);
}

/// SiteType으로 포스트 리스트 dom Elements 가져오기
Element getPostAuthorElement({
  @required SiteType siteType,
  @required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    return null;
  }

  return _siteMetaMap[siteType].getPostItemFromBodyRootQuery(document);
}

/// SiteType으로 포스트 Body Root dom Elements 가져오기
Element getPostRootElement(
  SiteType siteType, {
  @required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    return null;
  }

  return _siteMetaMap[siteType].getPostRootQuery(document);
}

/// SiteType으로 포스트 Comment List Root Elements 가져오기
List<Element> getPostCommentListElements({
  @required SiteType siteType,
  @required Document document,
}) {
  if (_siteMetaMap.containsKey(siteType) == false) {
    return <Element>[];
  }

  return _siteMetaMap[siteType].getCommentListRootQuery(document);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
SiteType getSiteType<T>() {
  switch (T) {
    case humoruniv.HumorunivPostListItemParser:
    case humoruniv.HumorunivPostListItemFromBodyParser:
    case humoruniv.HumorunivPostElement:
    case humoruniv.HumorunivPostComentItem:
      return SiteType.humoruniv;
  }

  return SiteType.none;
}

PostElement getPostElementInstance(SiteType siteType) {
  switch (siteType) {
    case SiteType.none:
      break;
    case SiteType.humoruniv:
      return humoruniv.HumorunivPostElement();
  }

  return null;
}

PostListItemParser getPostListItemParser(
  SiteType siteType, {
  @required Document document,
  @required bool isFromBody,
}) {
  switch (siteType) {
    case SiteType.none:
      break;
    case SiteType.humoruniv:
      return isFromBody
          ? humoruniv.HumorunivPostListItemFromBodyParser(document)
          : humoruniv.HumorunivPostListItemParser(document);
  }

  return null;
}

PostCommentItem getPostCommentInstance(SiteType siteType) {
  switch (siteType) {
    case SiteType.none:
      break;
    case SiteType.humoruniv:
      return humoruniv.HumorunivPostComentItem();
  }

  return null;
}
