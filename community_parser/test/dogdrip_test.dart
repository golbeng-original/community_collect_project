import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:html/parser.dart' as http_parser;

import 'package:community_parser/community_parser.dart';
import 'package:community_parser/util/get_document.dart';
import 'package:community_parser/core/site_define.dart' as site_define;
import 'package:html/dom.dart';

void main() {
  group('dogdrip siteMeta test group', () {
    var siteMeta = DogdripSiteMeta();

    var testListPageIndex = 0;
    var testListPageQuery = {'mid': 'dogdrip'};
    var testListWrongPageQuery = {'mid': 'xxx'};
    var testPostId = '324178320';
    var testWrongPostId = '324167939xxvx';

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
        postBodyUrl = siteMeta.getPostBodyUrl(
          testPostId,
          query: testListPageQuery,
          needQuestionMark: true,
        );
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
      final postBodyWrongUrl = siteMeta.getPostBodyUrl(
        testWrongPostId,
        query: testListPageQuery,
        needQuestionMark: true,
      );

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
      final postBodyUrl = siteMeta.getPostBodyUrl(
        testPostId,
        query: testListPageQuery,
        needQuestionMark: true,
      );

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
      final postBodyUrl = siteMeta.getPostBodyUrl(
        testPostId,
        query: testListPageQuery,
        needQuestionMark: true,
      );

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
      final postBodyUrl = siteMeta.getPostBodyUrl(
        testPostId,
        query: testListPageQuery,
        needQuestionMark: true,
      );

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
      final postBodyUrl = siteMeta.getPostBodyUrl(
        testPostId,
        query: testListPageQuery,
        needQuestionMark: true,
      );

      final uri = Uri.parse(postBodyUrl);
      final document = await _getDocunemt(uri);

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
      final postBodyUrl = siteMeta.getPostBodyUrl(
        testPostId,
        query: testListPageQuery,
        needQuestionMark: true,
      );

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

  group('dogdrip parse test group', () {
    final testListPageQuery = {'mid': 'dogdrip'};
    final testListWroungPageQuery = {'mid': 'xxx'};

    final testPostId = '325087542';
    final testWrongPostId = '325087542xxx';

    test('getSiteType', () {
      expect(
        site_define.getSiteType<DogdripPostListItemParser>(),
        site_define.SiteType.dogdrip,
        reason: 'find SiteType is wrong [DogdripPostListItemParser]',
      );

      expect(
        site_define.getSiteType<DogdripPostListItemFromBodyParser>(),
        site_define.SiteType.dogdrip,
        reason: 'find SiteType is wrong [DogdripPostListItemFromBodyParser]',
      );

      expect(
        site_define.getSiteType<DogdripPostElement>(),
        site_define.SiteType.dogdrip,
        reason: 'find SiteType is wrong [DogdripPostElement]',
      );

      expect(
        site_define.getSiteType<DogdripPostCommentItem>(),
        site_define.SiteType.dogdrip,
        reason: 'find SiteType is wrong [DogdripPostCommentItem]',
      );
    });

    test('PostListParser success test', () async {
      List<PostListItem> postListItems;
      try {
        postListItems = await PostListParser.parse<DogdripPostListItemParser>(
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
        PostListParser.parse<DogdripPostListItemParser>(
            pageIndex: 0, query: testListWroungPageQuery),
        throwsA(isA<Error>()),
        reason: 'wrong page query is wrong',
      );
    });

    test('PostListParser from body success test', () async {
      PostListItem postListItem;
      try {
        postListItem = await PostListParser.parseFromPostBody<
            DogdripPostListItemFromBodyParser>(
          testPostId,
          query: testListPageQuery,
          needQuestionMark: true,
        );

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

      expect(postListItem.authorIconUrl, isNotEmpty);
      expect(postListItem.authorName, isNotEmpty);
      expect(postListItem.subject, isNotEmpty);
    });

    test('PostListParser from body fail test', () async {
      expect(
        PostListParser.parseFromPostBody<DogdripPostListItemFromBodyParser>(
          testWrongPostId,
          query: testListPageQuery,
          needQuestionMark: true,
        ),
        throwsA(isA<Error>()),
        reason: 'PostListParser.parseFromPostBody not throws Error',
      );
    });

    test('PostParser success test', () async {
      DogdripPostElement element;
      try {
        element = await PostParser.parse<DogdripPostElement>(
          testPostId,
          query: testListPageQuery,
          needQuestionMark: true,
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
        PostParser.parse<DogdripPostElement>(
          testWrongPostId,
          query: testListPageQuery,
          needQuestionMark: true,
        ),
        throwsA(isA<Error>()),
        reason: 'PostParser.parse not throws Excpetion or Error',
      );
    });

    test('PostCommentParser success test', () async {
      try {
        final postCommentItems =
            await PostCommentParser.parseForSingle<DogdripPostCommentItem>(
          testPostId,
          query: testListPageQuery,
          needQuestionMark: true,
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
            postCommentItem.commentContent.isExistContent(),
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
        PostCommentParser.parseForSingle<DogdripPostCommentItem>(
          testWrongPostId,
          query: testListPageQuery,
          needQuestionMark: true,
        ),
        throwsA(isA<Error>()),
        reason: 'PostCommentParser.parse not throws Error',
      );
    });
  });
}
