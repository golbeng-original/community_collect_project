import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:html/parser.dart' as http_parser;

import 'package:community_parser/community_parser.dart';
import 'package:community_parser/humoruniv/model.dart';
import 'package:community_parser/util/get_document.dart';
import 'package:html/dom.dart';

void main() {
  group('humoruniv siteMeta test group', () {
    var siteMeta = HumorunivSiteMeta();

    var testListPageIndex = 0;
    var testListPageQuery = {'table': 'pds'};
    var testListWroungPageQuery = {'table': 'xxx'};
    var testBodyUrl = 'read.html?table=pds&pg=0&number=1057811';
    var testBodyWrongUrl = 'read.html?table=pds&pg=0&number=1057811234234xx';

    Future<Document> _getDocunemt(Uri uri) async {
      final documentResult = await getDocument(uri);
      expect(
        documentResult.statueType,
        StatusType.OK,
        reason: 'getDocument is Error',
      );

      var document = null;
      expect(
        document = http_parser.parse(documentResult.documentBody),
        allOf(
          isNot(throwsException),
          isNot(isA<Error>()),
        ),
        reason: 'dom parser error',
      );

      return document;
    }

    test('isErrorListPage', () async {
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      var document = await _getDocunemt(Uri.parse(postListUrl));
      expect(
        siteMeta.isErrorListPage(document),
        false,
        reason: 'siageMeta.isErrorPage(PostListUrl) = false (normal page)',
      );

      final postListWrongUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListWroungPageQuery,
      );

      var wroungDocument = await _getDocunemt(Uri.parse(postListWrongUrl));
      expect(
        siteMeta.isErrorListPage(wroungDocument),
        true,
        reason: 'siageMeta.isErrorPage(postListWrongUrl) = true (wrong page)',
      );
    });

    test('isErrorPostPage', () async {
      final postBodyUrl = siteMeta.getPostBodyUrl(testBodyUrl);
      var document = await _getDocunemt(Uri.parse(postBodyUrl));
      expect(
        siteMeta.isErrorPostPage(document),
        false,
        reason: 'siageMeta.isErrorPage(testBodyUrl) = false (normal page)',
      );

      final postBodyWrongUrl = siteMeta.getPostBodyUrl(testBodyWrongUrl);
      document = await _getDocunemt(Uri.parse(postBodyWrongUrl));
      expect(
        siteMeta.isErrorPostPage(document),
        true,
        reason: 'siageMeta.isErrorPage(testBodyWrongUrl) = true (wrong page)',
      );
    });

    test('getListUrl test', () async {
      final postListUrl = siteMeta.getListUrl(
        pageIndex: testListPageIndex,
        query: testListPageQuery,
      );

      http.Response response;
      expect(
        response = await http.head(Uri.parse(postListUrl)),
        allOf(
          isNotNull,
          isNot(throwsException),
          isNot(isA<Error>()),
        ),
        reason: 'response is error',
      );

      expect(
        response.statusCode,
        200,
        reason: 'response status code not 200',
      );

      final document = await _getDocunemt(Uri.parse(postListUrl));
      expect(
        siteMeta.isErrorListPage(document),
        false,
        reason: 'internal error page',
      );
    });

    test('getPostBodyUrl test', () async {
      final postBodyUrl = siteMeta.getPostBodyUrl(testBodyUrl);

      http.Response response;
      expect(
        response = await http.head(Uri.parse(postBodyUrl)),
        allOf(
          isNotNull,
          isNot(throwsException),
          isNot(isA<Error>()),
        ),
        reason: 'http.head is Error',
      );

      expect(
        response.statusCode,
        200,
        reason: 'response code not 200',
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
      final postBodyUrl = siteMeta.getPostBodyUrl(testBodyUrl);

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
      final postBodyUrl = siteMeta.getPostBodyUrl(testBodyUrl);

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
      final postBodyUrl = siteMeta.getPostBodyUrl(testBodyUrl);

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
  });

  group('humoruniv parse test group', () {
    test('PostListParser test', () {});

    test('PostParser test', () {});

    test('PostCommentParser test', () {});
  });
}
