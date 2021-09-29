import 'package:community_parser/community_parser.dart';

final _targetQuery = {'table': 'funtitle'};
final _targetPostId = '16744';

//final _targetQuery = {'table': 'fashion'};
//final _targetPostId = '637948';

Future _parsePostListItems<T extends PostListItemParser>() async {
  var list = await PostListParser.parse<T>(query: _targetQuery, pageIndex: 0);

  print('list count = ${list.length}');

  final index = 1;
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

    final p1PostListItemPostElement =
        list[index].extraData_1 as HumorunivP1ThumbPostElement?;
    if (p1PostListItemPostElement != null) {
      print('=========== content ==========');
      p1PostListItemPostElement.printContent();
    }

    final p1CommentItem =
        list[index].extraData_2 as HumorunivP1ThumbnailPostCommentItem?;
    if (p1CommentItem != null) {
      print('========== comment ===========');

      print('authorIconUrl = ${p1CommentItem.authorIconUrl}');
      print('authorName = ${p1CommentItem.authorName}');
      print('commentGoodCount = ${p1CommentItem.commentGoodCount}');
      print('commentBadCount = ${p1CommentItem.commentBadCount}');

      p1CommentItem.commentContent?.printContent();
    }
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

void exampleHumorunivP1Print() async {
  print('> parsePostListItems ======================');
  await _parsePostListItems<HumorunivP1PostListItemParser>();
  print('===========================================');

  print('> parsePostListItemFromBody ===============');
  await _parsePostListItemFromBody<HumorunivPostListItemFromBodyParser>();
  print('===========================================');

  print('> parserPostBody ==========================');
  await _parserPostBody<HumorunivPostElement>();
  print('===========================================');

  print('> parsePostComments =======================');
  await _parsePostComments<HumorunivTitlePostCommentItem>();
  await _parsePostComments<HumorunivPostCommentItem>();
  print('===========================================');
}
