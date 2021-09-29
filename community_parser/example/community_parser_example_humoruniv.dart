import 'package:community_parser/community_parser.dart';

Future _parsePostListItems<T extends PostListItemParser>() async {
  var list =
      await PostListParser.parse<T>(query: {'table': 'pds'}, pageIndex: 1);

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
  //var targetUrl = 'read.html?table=pds&number=1056639';
  var targetPostId = '1056639';
  var targetQuery = {'table': 'pds'};

  var result = await PostListParser.parseFromPostBody<T>(targetPostId,
      query: targetQuery);
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
  // case 2. parsing
  //var targetBodyUrl = 'read.html?table=pds&pg=0&number=1055255';

  // case 1.1. parsing
  //var targetBodyUrl = 'read.html?table=pds&pg=4&number=1055187';

  // case 1.2. parsing
  //var targetBodyUrl = 'read.html?table=pds&pg=1&number=1055251';

  // case 3.
  //var targetBodyUrl = 'read.html?table=pds&pg=0&number=1055781';
  //var targetBodyUrl = 'read.html?table=pds&pg=0&number=1056309';
  //var targetBodyUrl = 'read.html?table=pds&pg=0&number=1055774';

  //var targetBodyUrl = 'read.html?table=pds&pg=0&number=1057811';

  //var targetBodyUrl = 'read.html?table=pds&pg=2&number=1057489';

  //case 4. 사운드 파일
  //var targetPostId = '1065088';

  //case 5. 숨김 콘텐츠
  var targetPostId = '1066984';
  var targetQuery = {'table': 'pds'};

  var result = await PostParser.parse<T>(targetPostId, query: targetQuery);
  result?.printContent();
}

Future _parsePostComments<T extends PostCommentItem>() async {
  //var targetBodyUrl = 'read.html?table=pds&pg=0&number=1057811';
  var targetPostId = '1064687';
  var targetQuery = {'table': 'pds'};

  var result = await PostCommentParser.parseForSingle<T>(targetPostId,
      query: targetQuery);

  print('comment count = ${result.length}');

  var printFunc = (PostCommentItem commentItem) {
    print('reComment = ${commentItem.reComment}');
    print('authorIconUrl = ${commentItem.authorIconUrl}');
    print('reComment = ${commentItem.authorName}');
    print('commentGoodCount = ${commentItem.commentGoodCount}');
    print('commentBadCount = ${commentItem.commentBadCount}');
    print('commentWriteDatetime = ${commentItem.commentWriteDatetime}');

    commentItem.commentContent?.printContent();
  };

  for (var e in result) {
    printFunc(e);
    print('================');
  }
}

void exampleHumorunivPrint() async {
  print('> parsePostListItems ======================');
  await _parsePostListItems<HumorunivPostListItemParser>();
  print('===========================================');

  print('> parsePostListItemFromBody ===============');
  await _parsePostListItemFromBody<HumorunivPostListItemFromBodyParser>();
  print('===========================================');

  print('> parserPostBody ==========================');
  await _parserPostBody<HumorunivPostElement>();
  print('===========================================');

  print('> parsePostComments =======================');
  await _parsePostComments<HumorunivPostCommentItem>();
  print('===========================================');
}
