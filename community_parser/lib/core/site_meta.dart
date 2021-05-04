import 'package:html/dom.dart';
import 'package:meta/meta.dart';

abstract class SiteMeta {
  String getListUrl({Map<String, String> query, @required int pageIndex});
  String getPostBodyUrl(String postfixUrl);
  List<Element> getPostItemListRootQuery(Document document);
  Element getPostItemFromBodyRootQuery(Document document);
  Element getPostRootQuery(Document document);
  List<Element> getCommentListRootQuery(Document document);

  bool isErrorListPage(Document document);
  bool isErrorPostPage(Document document);
}
