import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:html/parser.dart' as http_parser;

import 'package:community_parser/community_parser.dart';
import 'package:community_parser/util/get_document.dart';
import 'package:community_parser/core/site_define.dart' as site_define;
import 'package:html/dom.dart';

void main() {
  group('todayhumor siteMeta test group', () {
    var siteMeta = TodayHumorSiteMeta();

    var testListPageIndex = 0;
    var testListPageQuery = {'table': 'humordata'};
    var testListWrongPageQuery = {'table': 'xxx'};
    var testPostId = '1905117';
    var testWrongPostId = '19051171xxvx';

    Future<Document> _getDocunemt(Uri uri) async {
      final documentResult = await getDocument(uri);
      if (documentResult.statueType != StatusType.OK) {
        throw ArgumentError('getDocument failed');
      }

      return http_parser.parse(documentResult.documentBody);
    }

    test('isErrorListPage success test', () async {
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      try {
        var document = await _getDocunemt(Uri.parse(postListUrl));

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
        var document = await _getDocunemt(Uri.parse(postListWrongUrl));

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
      var postBodyUrl;
      var document;
      try {
        postBodyUrl =
            siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);
        document = await _getDocunemt(Uri.parse(postBodyUrl));
      } catch (e) {
        expect(e, isNull, reason: '_getDocunemt($postBodyUrl) throws Error');
      }

      expect(
        siteMeta.isErrorPostPage(document),
        false,
        reason: 'siageMeta.isErrorPage(testBodyUrl) = false (normal page)',
      );
    });

    test('isErrorPostPage fail test', () async {
      final postBodyWrongUrl =
          siteMeta.getPostBodyUrl(testWrongPostId, query: testListPageQuery);

      var document;
      try {
        document = await _getDocunemt(Uri.parse(postBodyWrongUrl));
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

      final document = await _getDocunemt(Uri.parse(postListUrl));
      expect(
        siteMeta.isErrorListPage(document),
        false,
        reason: 'internal error page',
      );
    });

    test('getPostBodyUrl test', () async {
      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      final document = await _getDocunemt(Uri.parse(postBodyUrl));
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
      final document = await _getDocunemt(uri);

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

      if (postItemList?.isNotEmpty ?? false) {
        print('postItemList count = ${postItemList?.length}');
      }
    });

    test('getPostRootQuery', () async {
      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      final uri = Uri.parse(postBodyUrl);
      final document = await _getDocunemt(uri);

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
      final postBodyUrl =
          siteMeta.getPostBodyUrl(testPostId, query: testListPageQuery);

      final uri = Uri.parse(postBodyUrl);
      final document = await _getDocunemt(uri);

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
      final commentUrl =
          siteMeta.getSpecificCommentUrl(testPostId, query: testListPageQuery);

      final uri = Uri.parse(commentUrl);
      final documentResult = await getDocument(uri);
      expect(
        documentResult.statueType,
        StatusType.OK,
        reason: '$commentUrl is not ok',
      );

      var document = siteMeta.getCommentDocument(documentResult.documentBody);
      expect(
        siteMeta.getCommentListRootQuery(document),
        allOf(
          isNotNull,
          isNotEmpty,
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

  group('todayHumor parse test group', () {
    final testListPageQuery = {'table': 'humordata'};
    final testListWroungPageQuery = {'table': 'xxx'};

    final testPostBodyUrl = '1905579';
    final testPostBodyWrongUrl = '1905579xxx';

    test('getSiteType', () {
      expect(
        site_define.getSiteType<TodayHumorPostListItemParser>(),
        site_define.SiteType.todayHumor,
        reason: 'find SiteType is wrong [TodayHumorPostListItemParser]',
      );

      expect(
        site_define.getSiteType<TodayHumorPostListItemFromBodyParser>(),
        site_define.SiteType.todayHumor,
        reason: 'find SiteType is wrong [TodayHumorPostListItemFromBodyParser]',
      );

      expect(
        site_define.getSiteType<TodayHumorPostElement>(),
        site_define.SiteType.todayHumor,
        reason: 'find SiteType is wrong [TodayHumorPostElement]',
      );

      expect(
        site_define.getSiteType<TodayHumorPostCommentItem>(),
        site_define.SiteType.todayHumor,
        reason: 'find SiteType is wrong [TodayHumorPostElement]',
      );
    });

    test('PostListParser success test', () async {
      List<PostListItem> postListItems;
      try {
        postListItems =
            await PostListParser.parse<TodayHumorPostListItemParser>(
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
        PostListParser.parse<TodayHumorPostListItemParser>(
            pageIndex: 0, query: testListWroungPageQuery),
        throwsA(isA<Error>()),
        reason: 'wrong page query is wrong',
      );
    });

    test('PostListParser from body success test', () async {
      PostListItem postListItem;
      try {
        postListItem = await PostListParser.parseFromPostBody<
                TodayHumorPostListItemFromBodyParser>(testPostBodyUrl,
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

      expect(postListItem.postId, isNotEmpty);
      expect(postListItem.authorName, isNotEmpty);
      expect(postListItem.subject, isNotEmpty);
    });

    test('PostListParser from body fail test', () async {
      expect(
        PostListParser.parseFromPostBody<TodayHumorPostListItemFromBodyParser>(
          testPostBodyWrongUrl,
          query: testListWroungPageQuery,
        ),
        throwsA(isA<Error>()),
        reason: 'PostListParser.parseFromPostBody not throws Error',
      );
    });

    test('PostParser success test', () async {
      TodayHumorPostElement element;
      try {
        element = await PostParser.parse<TodayHumorPostElement>(
          testPostBodyUrl,
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
        element.isExistContent(),
        true,
        reason: 'post result existContent',
      );
    });

    test('PostParser fail test', () {
      expect(
        PostParser.parse<TodayHumorPostElement>(testPostBodyWrongUrl),
        throwsA(isA<Error>()),
        reason: 'PostParser.parse not throws Excpetion or Error',
      );
    });

    test('PostCommentParser success test', () async {
      try {
        final postCommentItems =
            await PostCommentParser.parseForSingle<TodayHumorPostCommentItem>(
                testPostBodyUrl,
                query: testListPageQuery);

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
            postCommentItem.commentContent.isExistContent(),
            true,
            reason: 'authorIconUrl is empty index = $index',
          );
        }
      } catch (e) {
        expect(e, isNull, reason: 'PostCommentParser.parse throws Error');
      }
    });

    test('PostCommentParser fail test', () async {
      expect(
        PostCommentParser.parseForSingle<TodayHumorPostCommentItem>(
            testPostBodyWrongUrl),
        throwsA(isA<Error>()),
        reason: 'PostCommentParser.parse not throws Error',
      );
    });
  });
}
