import 'package:community_parser/community_parser.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:community_parser/util/get_document.dart';

Future parsePostListItems<T extends PostListItemParser>() async {
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

Future parserPostBody<T extends PostElement>() async {
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

Future parsePostComments<T extends PostCommentItem>() async {
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

Future parsePostListItemFromBody<T extends PostListItemParser>() async {
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

void main() async {
  print('> parsePostListItems ======================');
  await parsePostListItems<HumorunivPostListItemParser>();
  print('===========================================');

  print('> parserPostBody ==========================');
  await parserPostBody<HumorunivPostElement>();
  print('===========================================');

  print('> parsePostComments =======================');
  await parsePostComments<HumorunivPostComentItem>();
  print('===========================================');

  print('> parsePostListItemFromBody ===============');
  await parsePostListItemFromBody<HumorunivPostListItemFromBodyParser>();
  print('===========================================');

  //parsePostListItemFromBodyTest();

  //parseTest();
}

void parsePostListItemFromBodyTest() async {
  var targetUrl =
      'http://web.humoruniv.com/board/humor/read.html?table=pds&pg=0&number=1057811';

  var uri = Uri.parse(targetUrl);
  var documentResult = await getDocument(uri);
  var document = parse(documentResult.documentBody);

  var postAuthorInfoRootElement = document.querySelector('table#profile_table');
  if (postAuthorInfoRootElement == null) {
    return;
  }

  postAuthorInfoRootElement =
      postAuthorInfoRootElement.querySelector('td > table');
  if (postAuthorInfoRootElement == null) {
    return;
  }

  var postRowElement = postAuthorInfoRootElement.querySelector('tbody > tr');
  if (postRowElement == null) {
    return;
  }

  final postTitleElement =
      postRowElement.querySelector('td > span#ai_cm_title');
  final postTitle = postTitleElement?.text ?? '';
  print('postTitle = $postTitle');

  postRowElement = postRowElement.nextElementSibling;
  final authorIconElement = postRowElement?.querySelector('img.hu_icon');

  var authorIconUrl = '';
  if (authorIconElement != null) {
    authorIconUrl = authorIconElement.attributes['src'] ?? '';
  }

  print('authorIconUrl = $authorIconUrl');

  final authorNameElement = postRowElement?.querySelector('span.hu_nick_txt');
  final authorName = authorNameElement?.text ?? '';
  print('authorNameElement = $authorName');

  postRowElement = postRowElement.nextElementSibling;

  final goodCountElement = postRowElement?.querySelector('span#ok_div');
  final goodCount = goodCountElement?.text ?? '';
  print('goodCount = $goodCount');

  final badCountElement = postRowElement?.querySelector('span#not_ok_span');
  final badCount = badCountElement?.text ?? '';
  print('badCount = $badCount');

  final commentCountElement = postRowElement?.querySelector('span.re');
  final commentCount = commentCountElement?.text ?? '';
  print('commentCount = $commentCount');

  final spanElements =
      postRowElement?.querySelectorAll('div#content_info > span');

  final postId = spanElements.first?.text ?? '';
  print('postId = $postId');

  final viewCount = spanElements.last?.text ?? '';
  print('viewCount = $viewCount');

  final timeRootElement = postRowElement?.querySelector('div#if_date');
  final writeDatetimeElement = timeRootElement?.querySelector('span');

  final writeDateTime = writeDatetimeElement?.text?.trim() ?? '';
  final dt = DateTime.tryParse(writeDateTime);
  print('writeDateTime = $dt');
}

void parseTest() async {
  //var targetUrl =
  //    'http://web.humoruniv.com/board/humor/read.html?table=pds&pg=0&number=1057808';

  //var targetUrl =
  //    'http://web.humoruniv.com/board/humor/read.html?table=pds&pg=1&number=1057766';

  var targetUrl =
      'http://web.humoruniv.com/board/humor/read.html?table=pds&pg=0&number=1057811';

  var uri = Uri.parse(targetUrl);
  var documentResult = await getDocument(uri);

  var document = parse(documentResult.documentBody);

  var commentRootElement = document.querySelector('div.cmt_area');
  if (commentRootElement == null) {
    return;
  }

  var listElements = commentRootElement
      .querySelectorAll('table > tbody > tr[id^=\'comment_\']');
  print('tr count = ${listElements.length}');

  if (listElements.isEmpty) {
    return;
  }

  for (var listElement in listElements) {
    _parseCommentElement(listElement);
    print('------------------');
  }
}

void _parseCommentElement(Element element) {
  // 2단 댓글 판단
  final isReCommentElement =
      element.querySelector('td > div#list_best_box > img') != null
          ? true
          : false;
  print('isReCommentElement = $isReCommentElement');

  final authorIconImgElement = element.querySelector('td img.hu_icon');
  final authorIconUrl = authorIconImgElement.attributes['src'];
  print('authorIconUrl = $authorIconUrl');

  final authorNameElement = element.querySelector('td span.hu_nick_txt');
  final authorName = authorNameElement?.text;
  print('author = $authorName');

  // commentImgUrl 3가지 케이스가 있다..
  ////////////////////////////////////////////////////////////
  var commentImgUrl = '';

  // case 1. 동영상인지 체크
  var commentImgRootElement =
      element.querySelector('td div.comment_img_div > a');

  if (commentImgRootElement != null) {
    final hrefSource = commentImgRootElement.attributes['href'] ?? '';

    final regExp = RegExp(r"'(?<url>.+?)'", caseSensitive: false);
    final matchVideoUrls = regExp.allMatches(hrefSource);
    for (var match in matchVideoUrls) {
      final findVideUrl = match.namedGroup('url');
      if (findVideUrl.toLowerCase().endsWith('.mp4') == true) {
        commentImgUrl = findVideUrl;
        break;
      }
    }
  }

  // 사진 체크
  if (commentImgUrl.isEmpty) {
    commentImgRootElement =
        element.querySelector('td div.comment_img_div > img');

    if (commentImgRootElement != null) {
      commentImgUrl = commentImgRootElement.attributes['src'] ?? '';
    }
  }

  // case 2.
  if (commentImgUrl.isEmpty) {
    commentImgRootElement =
        element.querySelector('td div.comment_img_origin > a > img');
    if (commentImgRootElement != null) {
      commentImgUrl = commentImgRootElement.attributes['src'] ?? '';
    }
  }
  print('commentImgUrl = $commentImgUrl');

  ////////////////////////////////////////////////////////////

  final commentTextElement = element.querySelector('td > div > span.cmt_list');
  final commentText = commentTextElement.text.trim();
  print('commentText = $commentText');

  final commentGoodCountElement =
      element.querySelector('td > span.list_ok > span');
  final commentGoodCount = commentGoodCountElement?.text ?? '';
  print('commentGoodCount = $commentGoodCount');

  final commentBadCountElement = element.querySelector('td > span.list_no');
  final commentBadCount = commentBadCountElement?.text ?? '';
  print('commentBadCount = $commentBadCount');

  final commentWriteDatetimeElement =
      element.querySelector('td > span.list_date');
  final commentWriteDatetime = commentWriteDatetimeElement.text.trim();
  print('commentWriteDatetime = $commentWriteDatetime');
}
