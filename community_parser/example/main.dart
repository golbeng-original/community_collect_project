import 'dart:convert';

import 'package:community_parser/todayhumor/model.dart';
import 'package:html/dom.dart' as dom;
import 'package:test/expect.dart';

import 'community_parser_example_humoruniv.dart';
import 'community_parser_example_humoruniv_p1.dart';
import 'community_parser_example_humoruniv_p2.dart';
import 'community_parser_example_humoruniv_p4.dart';
import 'community_parser_example_dogdrip.dart';
import 'community_parser_example_todayhumor.dart';
import 'community_parser_example_clien.dart';

import 'package:community_parser/community_parser.dart';

void main() async {
  //exampleHumorunivPrint();
  exampleHumorunivP1Print();
  //exampleHumorunivP2Print();
  //exampleHumorunivP4Print();
  //exampleDogDripPrint();
  //exampleTodayHumorPrint();
  //exampleClienPrint();

  //_dogdripRegExpPostId();
  //_youtubeUrlMatch();
  //_dogdripRegExpImge();
  //_todayhumorCommentGet();
}

void _youtubeUrlMatch() {
  //final url = 'https://youtu.be/dv_e_XAlU4s';
  //final url = 'https://youtu.be/200ui2_xXvQ';
  //final url = 'https://www.youtube.com/watch?v=79tGxVrbK50';
  final url = 'https://www.youtube.com/watch?v=kk03Dm9Z2zY';

  var regExp = RegExp(r'^https?://(www.)?(youtu.be|youtube.com)?/(.+)');
  var machted = regExp.firstMatch(url);
  print('matched url = ${machted?.group(0)}');
}

void _dogdripRegExpPostId() {
  print('start');
  final url = 'https://www.dogdrip.net/325043232';

  //final regExp = RegExp(r'https\:\/\/www.dogdrip.net\/(<?postId>[0-9]+)');
  final regExp = RegExp(r'https://www.dogdrip.net/(?<postId>.+)');
  var matched = regExp.firstMatch(url);
  if (matched != null) {
    final result = matched.namedGroup('postId');
    print(result);
  }

  final url_2 =
      '/index.php?mid=doc&category=18567755&document_srl=316127246&page=1';

  final regExp_2 = RegExp(r'document_srl=(?<postId>[0-9]+)');
  matched = regExp_2.firstMatch(url_2);
  if (matched != null) {
    final result = matched.namedGroup('postId');
    print(result);
  }
}

void _dogdripRegExpImge() {
  final value =
      'display:inline-block;background-image:url(./dvs/d/21/04/24/1fd8a1dc7130272da90b92fc2b4d5bf4.jpg);background-size:cover;background-position:50% 50%;width:100px !important;height:100px !important;border-radius:3px;';

  final regexp = RegExp(r'background-image:url\((?<url>.+)\);');
  final matched = regexp.firstMatch(value);
  if (matched != null) {
    print(matched.namedGroup('url'));
  }
}

class TodayHumorComment {
  int id = 0;
  int parentId = 0;
  String authorName = '';
  String authorIcon = '';
  String content = '';

  int goodCount = 0;
  String writeDateTime = '';

  TodayHumorComment();

  dom.Element toElement(dom.Document document) {
    var wrapperDiv = document.createElement('div');
    wrapperDiv.classes.add('memoWrapperDiv');

    if (parentId != 0) {
      wrapperDiv.classes.add('rereMemoWrapperDiv');
    }

    var contentRootDiv = document.createElement('div');
    contentRootDiv.classes.add('memoDiv');
    if (parentId != 0) {
      contentRootDiv.classes.add('rereMemoDiv');
    }
    // Author관련
    var authorDiv = document.createElement('div');
    authorDiv.classes.add('memoInfoDiv');

    authorDiv.append(_toAuthorName(document));

    var authorIconElement = _toAuthorIcon(document);
    if (authorIconElement != null) {
      authorDiv.append(authorIconElement);
    }

    authorDiv.append(_toWriteDateTime(document));
    authorDiv.append(_toGoodCount(document));

    contentRootDiv.append(authorDiv);
    contentRootDiv.append(_toContent(document));

    wrapperDiv.append(contentRootDiv);

    return wrapperDiv;
  }

  dom.Element _toAuthorName(dom.Document document) {
    var memoNameSpan = document.createElement('span');
    memoNameSpan.classes.add('memoNameSpan');

    var aTag = document.createElement('a');
    aTag.append(dom.Text(authorName));

    memoNameSpan.append(aTag);

    return memoNameSpan;
  }

  dom.Element? _toAuthorIcon(dom.Document document) {
    dom.Element? tag;
    if (authorIcon == 'null' || authorIcon == 'default') {
      tag = document.createElement('span');
      tag.classes.add('memoMemberStar');
      tag.append(dom.Text('★'));
    } else if (authorIcon == 'sewol') {
      tag = document.createElement('img');
      tag.classes.add('memoMemberIcon');
      tag.attributes['src'] =
          'http://www.todayhumor.co.kr/member/images/icon_ribbon.gif';
    }

    return tag;
  }

  dom.Element _toWriteDateTime(dom.Document document) {
    var memoRegisterInfoSpan = document.createElement('span');
    memoRegisterInfoSpan.classes.add('memoDate');

    memoRegisterInfoSpan.append(dom.Text('($writeDateTime)'));
    return memoRegisterInfoSpan;
  }

  dom.Element _toGoodCount(dom.Document document) {
    var memoOkNokSpan = document.createElement('span');
    memoOkNokSpan.classes.add('memoOkNok');

    memoOkNokSpan.append(dom.Text('추천 $goodCount'));
    return memoOkNokSpan;
  }

  dom.Element _toContent(dom.Document document) {
    var memoContentDiv = document.createElement('div');
    memoContentDiv.classes.add('memoContent');

    memoContentDiv.innerHtml = content;

    //memoContentDiv.append(dom.Text(content));

    return memoContentDiv;
  }

  factory TodayHumorComment.fromJson(json) {
    var todayHumorComment = TodayHumorComment();

    todayHumorComment.id = int.tryParse(json['no']) ?? 0;

    var parentId = json['parent_memo_no'];
    if (parentId is String) {
      todayHumorComment.parentId = int.tryParse(parentId) ?? 0;
    }

    todayHumorComment.authorName = json['name'];
    todayHumorComment.authorIcon = json['ms_icon'];

    todayHumorComment.goodCount = int.tryParse(json['ok']) ?? 0;
    todayHumorComment.writeDateTime = json['date'];

    todayHumorComment.content = json['memo'];

    return todayHumorComment;
  }
}

void _todayhumorCommentGet() async {
  var siteMeta = TodayHumorSiteMeta();

  final postId = '1905117';
  final query = {'table': 'humordata'};
  final commentUrl = siteMeta.getSpecificCommentUrl(postId, query: query);

  print(commentUrl);

  var sw = Stopwatch();
  sw.start();

  final documentResult = await getDocument(Uri.parse(commentUrl));

  if (documentResult.statueType != StatusType.OK) {
    return;
  }

  var result = jsonDecode(documentResult.documentBody);
  //print(result);

  var commentList = <TodayHumorComment>[];

  var memos = result['memos'];
  for (var memo in memos) {
    commentList.add(TodayHumorComment.fromJson(memo));
  }

  final commentHtml = '''
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body>
  <div id=\"memoContainerDiv\"></div>
  </body>
  </html>
  ''';

  var document = dom.Document.html(commentHtml);
  var commentConatiner = document.querySelector('#memoContainerDiv')!;

  var parentElements = <int, dom.Element>{};
  var removeComments = <TodayHumorComment>[];

  // 1단 댓글 생성
  for (var comment in commentList) {
    //print(
    //    'id = ${comment.id}, name = ${comment.authorName}, icon = ${comment.authorIcon}');

    if (comment.authorName == 'SYSTEM') {
      removeComments.add(comment);
      continue;
    }

    if (comment.parentId == 0) {
      var element = comment.toElement(document);
      parentElements[comment.id] = element;

      removeComments.add(comment);
    }
  }

  // 1단 내용 제거
  for (var removeComment in removeComments) {
    commentList.remove(removeComment);
  }

  // 2단 댓글 생성
  for (var comment in commentList) {
    print(
        'id = ${comment.id}, name = ${comment.authorName}, icon = ${comment.authorIcon}');

    if (comment.parentId == 0) {
      print('depth memo wrong!!');
      continue;
    }

    if (parentElements.containsKey(comment.parentId) == false) {
      print('depth memo wrong!!');
      continue;
    }

    var parentElement = parentElements[comment.parentId];
    if (parentElement == null) {
      print('parentElement is null wrong!! [id : ${comment.parentId}');
      continue;
    }

    var element = comment.toElement(document);
    parentElement.append(element);
  }

  var sortKeys = parentElements.keys.toList();
  sortKeys.sort();
  for (var key in sortKeys) {
    var element = parentElements[key]!;

    commentConatiner.append(element);
  }

  //print(document.body.innerHtml);
  print('${sw.elapsedMilliseconds} ms');
}
