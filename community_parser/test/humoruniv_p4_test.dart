import 'package:community_parser/core/site_cookie.dart';
import 'package:community_parser/core/site_meta.dart';
import 'package:test/test.dart';
import 'package:html/parser.dart' as http_parser;

import 'package:community_parser/community_parser.dart';
import 'package:community_parser/util/get_document.dart';
import 'package:community_parser/core/site_define.dart' as site_define;
import 'package:html/dom.dart';

//import '../lib/community_parser.dart';

var _siteCookie = SiteCookie();

Future<Document> _getDocunemt(
  Uri uri, {
  required SiteMeta siteMeta,
}) async {
  var cookieValue = _siteCookie.getCookieValue(siteMeta.siteDomain);

  var headers = <String, String>{'cookie': cookieValue};

  final documentResult = await getDocument(uri, headers: headers);
  if (documentResult.statueType != StatusType.OK) {
    throw ArgumentError('getDocument failed');
  }

  _siteCookie.updateCookie(siteMeta.siteDomain, documentResult.cookies);

  return http_parser.parse(documentResult.documentBody);
}

Future _headRequest(
  Uri uri, {
  required SiteMeta siteMeta,
}) async {
  final documentResult = await headRequest(uri);
  if (documentResult.statueType != StatusType.OK) {
    throw ArgumentError('getDocument failed');
  }

  _siteCookie.updateCookie(siteMeta.siteDomain, documentResult.cookies);
}

void main() {
  group('humoruniv p4 siteMeta test group', () {
    var siteMeta = HumorunivP4SiteMeta();

    var testListPageIndex = 0;
    var testListPageQuery = {'table': 'fashion'};
    var testListWrongPageQuery = {'table': 'xxx'};
    var testPostId = '8941';
    var testWrongPostId = '6981xx';

    test('isErrorListPage success test', () async {
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      try {
        var document =
            await _getDocunemt(Uri.parse(postListUrl), siteMeta: siteMeta);

        expect(
          siteMeta.isErrorListPage(document),
          false,
          reason:
              'siageMeta.isErrorPage(PostListUrl) expect false (wrong page)',
        );
      } catch (e) {
        expect(
          e,
          isNull,
          reason: '_getDocunemt($postListUrl) throws Error',
        );
      }
    });

    test('isErrorListPage fail test', () async {
      final postListWrongUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListWrongPageQuery,
      );

      try {
        var document =
            await _getDocunemt(Uri.parse(postListWrongUrl), siteMeta: siteMeta);

        expect(
          siteMeta.isErrorListPage(document),
          true,
          reason: 'siageMeta.isErrorPage(PostListUrl) expect true (wrong page)',
        );
      } catch (e) {
        return;
      }
    });

    test('isErrorPostPage success test', () async {
      late String postBodyUrl;
      late Document document;
      try {
        // Cookie를 얻어와야 해서 선행해야 한다.
        final postListUrl = siteMeta.getListUrl(
          pageIndex: testListPageIndex,
          query: testListPageQuery,
        );

        var uri = Uri.parse(postListUrl);
        await _headRequest(uri, siteMeta: siteMeta);

        postBodyUrl =
            siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

        document = await _getDocunemt(
          Uri.parse(postBodyUrl),
          siteMeta: siteMeta,
        );
      } catch (e) {
        expect(e, isNull, reason: '_getDocunemt($postBodyUrl) throws Error');
      }

      expect(
        siteMeta.isErrorPostPage(document),
        false,
        reason: 'siteMeta.isErrorPage(testBodyUrl) = false (normal page)',
      );
    });

    test('isErrorPostPage fail test', () async {
      final postBodyWrongUrl =
          siteMeta.getPostBodyUrl(testWrongPostId, query: testListPageQuery);

      var document;
      try {
        document =
            await _getDocunemt(Uri.parse(postBodyWrongUrl), siteMeta: siteMeta);
      } catch (e) {
        return;
      }

      expect(
        siteMeta.isErrorPostPage(document),
        true,
        reason: 'siageMeta.isErrorPage(testBodyUrl) = true (wrong page)',
      );
    });

    test('getListUrl test', () async {
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      final document =
          await _getDocunemt(Uri.parse(postListUrl), siteMeta: siteMeta);
      expect(
        siteMeta.isErrorListPage(document),
        false,
        reason: 'internal error page',
      );
    });

    test('getPostBodyUrl test', () async {
      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      final document =
          await _getDocunemt(Uri.parse(postBodyUrl), siteMeta: siteMeta);
      expect(
        siteMeta.isErrorListPage(document),
        false,
        reason: 'internal error page',
      );
    });

    test('getPostItemListRootQuery test', () async {
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      var uri = Uri.parse(postListUrl);
      final document = await _getDocunemt(uri, siteMeta: siteMeta);

      List<Element> postItemList;
      expect(
        postItemList = siteMeta.getPostItemListRootQuery(document),
        allOf(
          isNotNull,
          isNotEmpty,
          isNot(throwsException),
          isNot(isA<Error>()),
        ),
        reason: 'getPostItemListRootQuery is empry',
      );

      if (postItemList.isNotEmpty) {
        print('postItemList count = ${postItemList.length}');
      }
    });

    test('getPostRootQuery', () async {
      // Cookie를 얻어와야 해서 선행해야 한다.
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      var uri = Uri.parse(postListUrl);
      await _headRequest(uri, siteMeta: siteMeta);

      //
      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      uri = Uri.parse(postBodyUrl);
      var document = await _getDocunemt(uri, siteMeta: siteMeta);

      expect(
        siteMeta.getPostRootQuery(document),
        allOf(
          isNotNull,
          isNot(throwsException),
          isNot(isA<Error>()),
        ),
      );
    });

    test('getPostItemFromBodyRootQuery', () async {
      // Cookie를 얻어와야 해서 선행해야 한다.
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      var uri = Uri.parse(postListUrl);
      await _headRequest(uri, siteMeta: siteMeta);

      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      uri = Uri.parse(postBodyUrl);
      final document = await _getDocunemt(uri, siteMeta: siteMeta);

      expect(
        siteMeta.getPostItemFromBodyRootQuery(document),
        allOf(
          isNotNull,
          isNot(throwsException),
          isNot(isA<Error>()),
        ),
      );
    });

    test('getCommentListRootQuery', () async {
      // Cookie를 얻어와야 해서 선행해야 한다.
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      var uri = Uri.parse(postListUrl);
      await _headRequest(uri, siteMeta: siteMeta);

      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      uri = Uri.parse(postBodyUrl);
      final document = await _getDocunemt(uri, siteMeta: siteMeta);

      expect(
        siteMeta.getCommentListRootQuery(document),
        allOf(
          isNotNull,
          isNot(throwsException),
          isNot(isA<Error>()),
        ),
      );
    });

    test('pageComment test', () async {
      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      if (siteMeta.isExistCommentPage == true) {
        var pageInfoTuple =
            await siteMeta.getCommentPageCount(Uri.parse(postBodyUrl));

        expect(
          pageInfoTuple.item2 > 0,
          true,
          reason: 'pageComment exists wrong getCommentPageCount()',
        );
      } else {
        var pageInfoTuple =
            await siteMeta.getCommentPageCount(Uri.parse(postBodyUrl));

        expect(
          pageInfoTuple.item2 == 0,
          true,
          reason: 'pageComment not exists wrong getCommentPageCount()',
        );
      }
    });
  });

  group('humoruniv p4 parse test group', () {
    final testListPageQuery = {'table': 'fashion'};
    final testListWroungPageQuery = {'table': 'xxx'};

    final testPostId = '8941';
    final testWrongPostId = '6883xxx23';

    test('getSiteType', () {
      expect(
        site_define.getSiteType<HumorunivP4PostListItemParser>(),
        site_define.SiteType.humoruniv_p4,
        reason: 'find SiteType is wrong [HumorunivPostListItemParser]',
      );

      expect(
        site_define.getSiteType<HumorunivPostListItemFromBodyParser>(),
        site_define.SiteType.humoruniv,
        reason: 'find SiteType is wrong [HumorunivPostListItemFromBodyParser]',
      );

      expect(
        site_define.getSiteType<HumorunivP4PostElement>(),
        site_define.SiteType.humoruniv_p4,
        reason: 'find SiteType is wrong [HumorunivPostElement]',
      );

      expect(
        site_define.getSiteType<HumorunivPostCommentItem>(),
        site_define.SiteType.humoruniv,
        reason: 'find SiteType is wrong [HumorunivPostComentItem]',
      );

      expect(
        site_define.getSiteType<HumorunivTitlePostCommentItem>(),
        site_define.SiteType.humoruniv_p4,
        reason: 'find SiteType is wrong [HumorunivTitlePostCommentItem]',
      );
    });

    test('PostListParser success test', () async {
      late List<PostListItem> postListItems;
      try {
        postListItems =
            await PostListParser.parse<HumorunivP4PostListItemParser>(
          pageIndex: 0,
          query: testListPageQuery,
        );

        expect(
          postListItems,
          allOf(
            isNotNull,
            isNotEmpty,
          ),
          reason: 'PostListParser.parse result is null',
        );
      } catch (e) {
        expect(
          e,
          isNull,
          reason: 'PostListParser.parse throws Error',
        );
      }

      for (var postItemList in postListItems) {
        final index = postListItems.indexOf(postItemList);
        expect(
          postItemList.postId,
          isNotEmpty,
          reason: 'authorIconUrl is Empty index = $index',
        );
        expect(
          postItemList.authorName,
          isNotEmpty,
          reason: 'authorName is Empty index = $index',
        );
        expect(
          postItemList.subject,
          isNotEmpty,
          reason: 'subject is Empty index = $index',
        );
      }
    });

    test('postListParser fail test', () async {
      expect(
        PostListParser.parse<HumorunivP4PostListItemParser>(
            pageIndex: 0, query: testListWroungPageQuery),
        throwsA(isA<Error>()),
        reason: 'wrong page query is wrong',
      );
    });

    test('PostListParser from body success test', () async {
      PostListItem? postListItem;
      try {
        postListItem = await PostListParser.parseFromPostBody<
                HumorunivPostListItemFromBodyParser>(testPostId,
            query: testListPageQuery);

        expect(
          postListItem,
          isNotNull,
          reason: 'PostListParser.parseFromPostBody result is null',
        );
      } catch (e) {
        expect(
          e,
          isNull,
          reason: 'PostListParser.parseFromPostBody throws Error',
        );
      }

      expect(postListItem?.authorIconUrl, isNotEmpty);
      expect(postListItem?.authorName, isNotEmpty);
      expect(postListItem?.subject, isNotEmpty);
    });

    test('PostListParser from body fail test', () async {
      expect(
        PostListParser.parseFromPostBody<HumorunivPostListItemFromBodyParser>(
          testWrongPostId,
          query: testListPageQuery,
        ),
        throwsA(isA<Error>()),
        reason: 'PostListParser.parseFromPostBody not throws Error',
      );
    });

    test('PostParser success test', () async {
      HumorunivPostElement? element;
      try {
        element = await PostParser.parse<HumorunivP4PostElement>(
          testPostId,
          query: testListPageQuery,
        );

        expect(
          element,
          isNotNull,
          reason: 'PostParser.paser result is null',
        );
      } catch (e) {
        expect(e, isNull, reason: 'PostParser.parse throws Error');
      }

      expect(
        element?.isExistContent(),
        true,
        reason: 'post result existContent',
      );
    });

    test('PostParser fail test', () {
      expect(
        PostParser.parse<HumorunivP4PostElement>(
          testWrongPostId,
          query: testListPageQuery,
        ),
        throwsA(isA<Error>()),
        reason: 'PostParser.parse not throws Excpetion or Error',
      );
    });

    test('PostCommentParser success test', () async {
      try {
        final postCommentItems =
            await PostCommentParser.parseForSingle<HumorunivPostCommentItem>(
          testPostId,
          query: testListPageQuery,
        );

        expect(
          postCommentItems,
          isNotNull,
          reason: 'PostCommentParser.paser result is null',
        );

        for (var postCommentItem in postCommentItems) {
          final index = postCommentItems.indexOf(postCommentItem);

          expect(
            postCommentItem.authorName,
            isNotEmpty,
            reason: 'authorName is empty index = $index',
          );
          expect(
            postCommentItem.commentContent?.isExistContent(),
            true,
            reason: 'commentContent is empty index = $index',
          );
        }
      } catch (e) {
        expect(e, isNull, reason: 'PostCommentParser.parse throws Error');
      }
    });

    test('PostCommentParser fail test', () async {
      expect(
        PostCommentParser.parseForSingle<HumorunivPostCommentItem>(
          testWrongPostId,
          query: testListPageQuery,
        ),
        throwsA(isA<Error>()),
        reason: 'PostCommentParser.parse not throws Error',
      );
    });
  });
}
