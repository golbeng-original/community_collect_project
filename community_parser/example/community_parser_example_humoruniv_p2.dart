import 'package:community_parser/community_parser.dart';

final _targetQuery = {'table': 'picture'};
final _targetPostId = '637948';

//final _targetQuery = {'table': 'fashion'};
//final _targetPostId = '637948';

Future _parsePostListItems<T extends PostListItemParser>() async {
  var list = await PostListParser.parse<T>(query: _targetQuery, pageIndex: 0);

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
  var result = await PostListParser.parseFromPostBody<T>(_targetPostId,
      query: _targetQuery);
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
  var result = await PostParser.parse<T>(_targetPostId, query: _targetQuery);
  result?.printContent();
}

Future _parsePostComments<T extends PostCommentItem>() async {
  var result = await PostCommentParser.parseForSingle<T>(_targetPostId,
      query: _targetQuery);

  print('comment count = ${result.length}');

  var printFunc = (PostCommentItem commentItem) {
    print('reComment = ${commentItem.reComment}');
    print('authorIconUrl = ${commentItem.authorIconUrl}');
    print('authorName = ${commentItem.authorName}');
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

void exampleHumorunivP2Print() async {
  print('> parsePostListItems ======================');
  await _parsePostListItems<HumorunivP2PostListItemParser>();
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
