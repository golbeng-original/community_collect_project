import 'package:test/test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as http_parser;

import 'package:community_parser/community_parser.dart';
import 'package:community_parser/core/site_define.dart' as site_define;

void main() {
  group('clien siteMeta test group', () {
    var siteMeta = ClienSiteMeta();

    var testListPageIndex = 0;
    var testListPageSubUrl = 'board/park';
    var testListPageWroungSubUrl = 'board/park_xxx';
    var testPostId = '16169025';
    var testWrongPostId = '16169025xcs';

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
        subUrl: testListPageSubUrl,
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
        subUrl: testListPageWroungSubUrl,
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
          subUrl: testListPageSubUrl,
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
        subUrl: testListPageWroungSubUrl,
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
        subUrl: testListPageSubUrl,
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
        subUrl: testListPageSubUrl,
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
        subUrl: testListPageSubUrl,
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
        subUrl: testListPageSubUrl,
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
        subUrl: testListPageSubUrl,
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
        subUrl: testListPageSubUrl,
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
        subUrl: testListPageSubUrl,
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

  group('clien parse test group', () {
    var testListPageIndex = 0;
    var testListPageSubUrl = 'board/park';
    var testListPageWroungSubUrl = 'board/park_xxx';
    var testPostId = '16169025';
    var testWrongPostId = '16169025xcs';

    test('getSiteType', () {
      expect(
        site_define.getSiteType<ClienPostListItemParser>(),
        site_define.SiteType.clien,
        reason: 'find SiteType is wrong [ClienPostListItemParser]',
      );

      expect(
        site_define.getSiteType<ClienPostListItemFromBodyParser>(),
        site_define.SiteType.clien,
        reason: 'find SiteType is wrong [ClienPostListItemFromBodyParser]',
      );

      expect(
        site_define.getSiteType<ClienPostElement>(),
        site_define.SiteType.clien,
        reason: 'find SiteType is wrong [ClienPostElement]',
      );

      expect(
        site_define.getSiteType<ClienPostCommentItem>(),
        site_define.SiteType.clien,
        reason: 'find SiteType is wrong [ClienPostCommentItem]',
      );
    });

    test('PostListParser success test', () async {
      List<PostListItem> postListItems;
      try {
        postListItems = await PostListParser.parse<ClienPostListItemParser>(
          pageIndex: 0,
          subUrl: testListPageSubUrl,
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
        PostListParser.parse<ClienPostListItemParser>(
          pageIndex: 0,
          subUrl: testListPageWroungSubUrl,
        ),
        throwsA(isA<Error>()),
        reason: 'wrong page query is wrong',
      );
    });

    test('PostListParser from body success test', () async {
      PostListItem postListItem;
      try {
        postListItem = await PostListParser.parseFromPostBody<
            ClienPostListItemFromBodyParser>(
          testPostId,
          subUrl: testListPageSubUrl,
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
        PostListParser.parseFromPostBody<ClienPostListItemFromBodyParser>(
          testWrongPostId,
          subUrl: testListPageSubUrl,
        ),
        throwsA(isA<Error>()),
        reason: 'PostListParser.parseFromPostBody not throws Error',
      );
    });

    test('PostParser success test', () async {
      ClienPostElement element;
      try {
        element = await PostParser.parse<ClienPostElement>(
          testPostId,
          subUrl: testListPageSubUrl,
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
        PostParser.parse<ClienPostElement>(testWrongPostId,
            subUrl: testListPageSubUrl),
        throwsA(isA<Error>()),
        reason: 'PostParser.parse not throws Excpetion or Error',
      );
    });

    test('PostCommentParser success test', () async {
      try {
        final postCommentItems =
            await PostCommentParser.parseForSingle<ClienPostCommentItem>(
          testPostId,
          subUrl: testListPageSubUrl,
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
        PostCommentParser.parseForSingle<HumorunivPostCommentItem>(
          testWrongPostId,
          subUrl: testListPageSubUrl,
        ),
        throwsA(isA<Error>()),
        reason: 'PostCommentParser.parse not throws Error',
      );
    });
  });
}
