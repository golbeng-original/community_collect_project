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

  var targetBodyUrl = 'read.html?table=pds&pg=2&number=1057489';

  var result = await PostParser.parse<T>(targetBodyUrl);
  result?.printPost();
}

Future _parsePostComments<T extends PostCommentItem>() async {
  var targetBodyUrl = 'read.html?table=pds&pg=0&number=1057811';

  var result = await PostCommentParser.parse<T>(targetBodyUrl);

  print('comment count = ${result.length}');

  var printFunc = (PostCommentItem commentItem) {
    print('reComment = ${commentItem.reComment}');
    print('authorIconUrl = ${commentItem.authorIconUrl}');
    print('reComment = ${commentItem.authorName}');
    print('commentImgUrl = ${commentItem.commentImgUrl}');
    print('commentText = ${commentItem.commentText}');
    print('commentGoodCount = ${commentItem.commentGoodCount}');
    print('commentBadCount = ${commentItem.commentBadCount}');
    print('commentWriteDatetime = ${commentItem.commentWriteDatetime}');
  };

  for (var e in result) {
    printFunc(e);
    print('================');
  }
}

Future _parsePostListItemFromBody<T extends PostListItemParser>() async {
  //var targetUrl = 'read.html?table=pds&pg=0&number=1057811';
  //var targetUrl = 'read.html?table=pds&number=1057769';
  //var targetUrl = 'read.html?table=pds&number=1057784';
  var targetUrl = 'read.html?table=pds&number=1056639';

  var result = await PostListParser.parseFromPostBody<T>(targetUrl);
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

void exampleHumorunivPrint() async {
  print('> parsePostListItems ======================');
  await _parsePostListItems<HumorunivPostListItemParser>();
  print('===========================================');

  print('> parserPostBody ==========================');
  await _parserPostBody<HumorunivPostElement>();
  print('===========================================');

  print('> parsePostComments =======================');
  await _parsePostComments<HumorunivPostComentItem>();
  print('===========================================');

  print('> parsePostListItemFromBody ===============');
  await _parsePostListItemFromBody<HumorunivPostListItemFromBodyParser>();
  print('===========================================');
}
