import 'package:html/parser.dart' as html_parser;

import 'package:community_parser/community_parser.dart';

Future _parsePostListItems<T extends PostListItemParser>() async {
  var list = await PostListParser.parse<T>(
    subUrl: 'board/park',
    pageIndex: 0,
  );

  print('list count = ${list.length}');

  final index = 0;
  if (list.isNotEmpty) {
    print('postId = ${list[index].postId}');
    print('postBodyUrl = ${list[index].postBodyUrl}');
    print('thumbnailUrl = ${list[index].thumbnailUrl}');
    print('subject = ${list[index].subject}');
    print('authorIconUrl = ${list[index].authorIconUrl}');
    print('authorName = ${list[index].authorName}');
    print('commentCount = ${list[index].commentCount}');
    print('viewCount = ${list[index].viewCount}');
    print('goodCount = ${list[index].goodCount}');
    print('badCount = ${list[index].badCount}');
    print('writeDateTime = ${list[index].writeDateTime}');
  }
}

Future _parsePostListItemFromBody<T extends PostListItemParser>() async {
  //var targetUrl = 'read.html?table=pds&pg=0&number=1057811';
  //var targetUrl = 'read.html?table=pds&number=1057769';
  //var targetUrl = 'read.html?table=pds&number=1057784';
  var targetUrl = '16062550';

  var result = await PostListParser.parseFromPostBody<T>(
    targetUrl,
    subUrl: 'board/park',
  );
  if (result == null) {
    return;
  }

  print('postId = ${result.postId}');
  print('postBodyUrl = ${result.postBodyUrl}');
  print('thumbnailUrl = ${result.thumbnailUrl}');
  print('subject = ${result.subject}');
  print('authorIconUrl = ${result.authorIconUrl}');
  print('authorName = ${result.authorName}');
  print('commentCount = ${result.commentCount}');
  print('viewCount = ${result.viewCount}');
  print('goodCount = ${result.goodCount}');
  print('badCount = ${result.badCount}');
  print('writeDateTime = ${result.writeDateTime}');
}

Future _parserPostBody<T extends PostElement>() async {
  // case 1. 그림 + 글
  //var targetBodyUrl = '325071246';

  // case 2. 단순 글 blockquote 태그 있음..
  //var targetBodyUrl = '325043232';

  // case 3. youtube 첨부 (<p>youtube 주소만 표시??</p>)
  //var targetBodyUrl = '325087309';
  var targetBodyUrl = '16062550';

  // case 4. youtube 첨부
  //var targetBodyUrl = '325076082';
  //var targetBodyUrl = '324912392';
  //var targetBodyUrl = '324926766';

  // case 5. link
  //var targetBodyUrl = '325008443';

  var result = await PostParser.parse<T>(
    targetBodyUrl,
    subUrl: 'board/park',
  );
  result?.printContent();
}

Future _parsePostComments<T extends PostCommentItem>() async {
  var targetPostId = '16062550';

  var sw = Stopwatch();
  sw.start();

  var result = await PostCommentParser.parseForPage<T>(
    targetPostId,
    subUrl: 'board/park',
  );

  print('comment count = ${result.length}');

  var printFunc = (PostCommentItem commentItem) {
    print('reComment = ${commentItem.reComment}');
    print('authorIconUrl = ${commentItem.authorIconUrl}');
    print('authorName = ${commentItem.authorName}');
    print('commentGoodCount = ${commentItem.commentGoodCount}');
    print('commentBadCount = ${commentItem.commentBadCount}');
    print('commentWriteDatetime = ${commentItem.commentWriteDatetime}');

    commentItem.commentContent.printContent();
  };

  for (var e in result) {
    printFunc(e);
    print('================');
  }

  print('${sw.elapsedMilliseconds} ms');
}

void exampleClienPrint() async {
  print('> parsePostListItems ======================');
  await _parsePostListItems<ClienPostListItemParser>();
  print('===========================================');

  print('> parsePostListItemFromBody ===============');
  await _parsePostListItemFromBody<ClienPostListItemFromBodyParser>();
  print('===========================================');

  print('> parserPostBody ==========================');
  await _parserPostBody<ClienPostElement>();
  print('===========================================');

  print('> parsePostComments =======================');
  await _parsePostComments<ClienPostCommentItem>();
  print('===========================================');
}
