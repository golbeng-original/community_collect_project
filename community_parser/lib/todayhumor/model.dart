import 'dart:convert';

import 'package:community_parser/core/parser.dart';
import 'package:community_parser/core/content_element.dart';
import 'package:html/dom.dart';
import 'package:community_parser/core/site_meta.dart';

/// 오늘의 유머 Comment Json으로부터 parsing한 commentItem
class TodayHumorComment {
  int id = 0;
  int parentId = 0;
  String authorName = '';
  String authorIcon = '';
  String content = '';

  int goodCount = 0;
  String writeDateTime = '';

  bool isDelete = false;

  TodayHumorComment();

  Element toElement(Document document) {
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

  Element _toAuthorName(Document document) {
    var memoNameSpan = document.createElement('span');
    memoNameSpan.classes.add('memoName');

    var aTag = document.createElement('a');
    aTag.append(Text(authorName));

    memoNameSpan.append(aTag);

    return memoNameSpan;
  }

  Element _toAuthorIcon(Document document) {
    Element tag;
    if (authorIcon == 'null' || authorIcon == 'default') {
      tag = document.createElement('span');
      tag.classes.add('memoMemberStar');
      tag.append(Text('★'));
    } else if (authorIcon == 'sewol') {
      tag = document.createElement('img');
      tag.classes.add('memoMemberIcon');
      tag.attributes['src'] =
          'http://www.todayhumor.co.kr/member/images/icon_ribbon.gif';
    }

    return tag;
  }

  Element _toWriteDateTime(Document document) {
    var memoRegisterInfoSpan = document.createElement('span');
    memoRegisterInfoSpan.classes.add('memoDate');

    memoRegisterInfoSpan.append(Text('($writeDateTime)'));
    return memoRegisterInfoSpan;
  }

  Element _toGoodCount(Document document) {
    var memoOkNokSpan = document.createElement('span');
    memoOkNokSpan.classes.add('memoOkNok');

    memoOkNokSpan.append(Text('추천 $goodCount'));
    return memoOkNokSpan;
  }

  Element _toContent(Document document) {
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

    todayHumorComment.isDelete = json['is_del'];

    return todayHumorComment;
  }
}

/// 오늘의 유머 SiteMeta
class TodayHumorSiteMeta extends SiteMeta {
  TodayHumorSiteMeta() : super(startPageIndex: 1);

  @override
  bool isErrorListPage(Document document) {
    final trElements =
        document.querySelectorAll('table.table_list > tbody > tr');
    final trCount = trElements?.length ?? 0;

    return trCount <= 4 ? true : false;
  }

  @override
  bool isErrorPostPage(Document document) {
    return document.body.children.length <= 1 ? true : false;
  }

  @override
  bool isErrorCommentPage(Document document) {
    return false;
  }

  @override
  String getAdjustListUrl(int pageIndex, {String subUrl}) {
    // query list
    // table={string}

    return 'http://www.todayhumor.co.kr/board/list.php?page=$pageIndex';
  }

  @override
  String getAdjustPostBodyUrl(
    String postId, {
    String subUrl,
  }) {
    return 'http://www.todayhumor.co.kr/board/view.php?no=$postId';
  }

  @override
  String getSpecificCommentUrl(
    String postId, {
    String subUrl = '',
    Map<String, String> query,
    bool needQuestionMark = false,
  }) {
    var parentTable = '';
    if (query.containsKey('table')) {
      parentTable = query['table'];
    }

    var url =
        'http://www.todayhumor.co.kr/board/ajax_memo_list.php?parent_table=$parentTable&parent_id=$postId&get_all_memo=Y';
    return url;
  }

  @override
  List<Element> getPostItemListRootQuery(Document document) {
    final tableListElement = document.querySelector('table.table_list > tbody');

    final trElements =
        tableListElement?.querySelectorAll('tr.list_tr_humordata');
    return trElements ?? <Element>[];
  }

  @override
  Element getPostRootQuery(Document document) {
    final postBodyElement =
        document.querySelector('div.contentContainer > div.viewContent');

    return postBodyElement;
  }

  @override
  Document getCommentDocument(String documentString) {
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

    var document = Document.html(commentHtml);

    var commentList = <TodayHumorComment>[];

    try {
      var commentJson = jsonDecode(documentString);

      var memos = commentJson['memos'];
      for (var memo in memos) {
        commentList.add(TodayHumorComment.fromJson(memo));
      }
    } catch (e) {
      print('getCommentDocument Exception : $e');
      return document;
    }

    var commentConatiner = document.querySelector('#memoContainerDiv');

    var parentElements = <int, Element>{};
    var removeComments = <TodayHumorComment>[];

    // 1단 댓글 생성
    for (var comment in commentList) {
      if (comment.authorName == 'SYSTEM' || comment.isDelete == true) {
        removeComments.add(comment);
        continue;
      }

      if (comment.parentId == 0) {
        try {
          var element = comment.toElement(document);
          parentElements[comment.id] = element;
        } catch (e) {
          print('commentId = ${comment.id} toElement Exception $e');
        } finally {
          removeComments.add(comment);
        }
      }
    }

    // 1단 내용 제거
    for (var removeComment in removeComments) {
      commentList.remove(removeComment);
    }

    // 2단 댓글 생성
    for (var comment in commentList) {
      if (comment.parentId == 0) {
        print('depth memo wrong!!');
        continue;
      }

      if (parentElements.containsKey(comment.parentId) == false) {
        print('depth memo wrong!!');
        continue;
      }

      var parentElement = parentElements[comment.parentId];

      try {
        var element = comment.toElement(document);
        parentElement.append(element);
      } catch (e) {
        print('commentId = ${comment.id} toElement Exception $e');
      }
    }

    // 정렬 후 element 추가
    var sortKeys = parentElements.keys.toList();
    sortKeys.sort();
    for (var key in sortKeys) {
      var element = parentElements[key];

      commentConatiner.append(element);
    }

    return document;
  }

  @override
  List<Element> getCommentListRootQuery(Document document) {
    final commentRootElement = document.querySelector('div#memoContainerDiv');
    if (commentRootElement == null) {
      return <Element>[];
    }

    var commentList = <Element>[];
    var firstCommentElements =
        commentRootElement.querySelectorAll('div.memoWrapperDiv');
    if (firstCommentElements == null) {
      return <Element>[];
    }

    for (var firstCommentElement in firstCommentElements) {
      final commentBodyElement =
          firstCommentElement.querySelector('div.memoDiv');
      if (commentBodyElement != null) {
        commentList.add(commentBodyElement);
      }
    }

    return commentList;
  }

  @override
  Element getPostItemFromBodyRootQuery(Document document) {
    return document
        .querySelector('div.writerInfoContainer > div.writerInfoContents');
  }
}

/// 오늘의 유머 게시글 리스트 아이템 Parser
/// - List에서 List Unit Parsing하기
class TodayHumorPostListItemParser extends PostListItemParser {
  TodayHumorPostListItemParser(Document docuemnt) : super(docuemnt);

  @override
  String parseAuthorIconUrl(Element element) {
    // AuhorIcon이 존재하지 않는다.
    return '';
  }

  @override
  String parseAuthorName(Element element) {
    final authorNameElement = element.querySelector('td.name > a');
    return authorNameElement?.text ?? '';
  }

  @override
  String parseThumbnailUrl(Element element) {
    // Thumbnail이 존재하지 않는다.
    return '';
  }

  @override
  String parsePostId(Element element) {
    var bodyUrl = parseBodyUrl(element);

    final postIdRegexp = RegExp(r'&no=(?<postId>[0-9]+)');
    final matched = postIdRegexp.firstMatch(bodyUrl);
    if (matched == null) {
      return '';
    }

    return matched.namedGroup('postId');
  }

  @override
  String parseBodyUrl(Element element) {
    final subjectElement = element.querySelector('td.subject > a');
    if (subjectElement == null) {
      return '';
    }

    return subjectElement.attributes['href'] ?? '';
  }

  @override
  String parseSubject(Element element) {
    final subjectElement = element.querySelector('td.subject > a');
    if (subjectElement == null) {
      return '';
    }

    return subjectElement?.text ?? '';
  }

  @override
  int parseCommentCount(Element element) {
    final commentCountElement =
        element.querySelector('td.subject > span.list_memo_count_span');

    var commentCountStr = commentCountElement?.text?.trim() ?? '';
    commentCountStr = commentCountStr.replaceAll('[', '');
    commentCountStr = commentCountStr.replaceAll(']', '');

    return int.tryParse(commentCountStr) ?? 0;
  }

  @override
  int parseViewCount(Element element) {
    final viewCountElement = element.querySelector('td.hits');
    final viewCountStr = viewCountElement?.text ?? '';

    return int.tryParse(viewCountStr) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    final goodCountElement = element.querySelector('td.oknok');
    final goodCountStr = goodCountElement?.text ?? '';

    return int.tryParse(goodCountStr) ?? 0;
  }

  @override
  int parseBadCount(Element element) {
    // BadCount가 존재하지 않느다.
    return -1;
  }

  @override
  String parseWriteDateTime(Element element) {
    final writeDateTimeElement = element.querySelector('td.date');
    if (writeDateTimeElement == null) {
      return '';
    }

    final datetimeRegexp = RegExp(
        r'(?<y>[0-9]+)/(?<m>[0-9]+)/(?<d>[0-9]+).?(?<h>[0-9]+):(?<M>[0-9]+)');
    final matched = datetimeRegexp.firstMatch(writeDateTimeElement.text);
    if (matched == null) {
      return '';
    }

    final year = int.tryParse(matched.namedGroup('y'));
    final month = int.tryParse(matched.namedGroup('m'));
    final day = int.tryParse(matched.namedGroup('d'));
    final hour = int.tryParse(matched.namedGroup('h'));
    final minute = int.tryParse(matched.namedGroup('M'));

    //final dateTime = DateTime(2000 + year, month, day, hour, minute);
    return '${2000 + year}-$month=$day $hour:$minute';
  }
}

/// 오늘의 유머 게시글 리스트 아이템 Parser
/// - 게시글 본문에서 List Unit 요소 Parsing 하기
class TodayHumorPostListItemFromBodyParser extends PostListItemParser {
  TodayHumorPostListItemFromBodyParser(Document docuemnt) : super(docuemnt);

  bool _isFoundItemInfoDivs = false;
  List<Element> _postItemInfoDivElements;

  void _findPostItemInfoDivs(Element element) {
    if (_isFoundItemInfoDivs == true) {
      return;
    }

    _isFoundItemInfoDivs = true;

    _postItemInfoDivElements = element.querySelectorAll('div');
    _postItemInfoDivElements ??= <Element>[];
  }

  bool _isEnableParsing() {
    return _postItemInfoDivElements.length == 9;
  }

  @override
  String parseThumbnailUrl(Element element) {
    // Thumbnail은 존재하지 않는다.
    return '';
  }

  @override
  String parseAuthorIconUrl(Element element) {
    // 작성자 Icon 존재하지 않음
    return '';
  }

  @override
  String parseAuthorName(Element element) {
    _findPostItemInfoDivs(element);

    if (_isEnableParsing() == false) {
      return '';
    }

    final authorNameElement = _postItemInfoDivElements[1]
        .querySelector('span#viewPageWriterNameSpan');

    if (authorNameElement == null) {
      return '';
    }

    return authorNameElement.attributes['name'] ?? '';
  }

  @override
  String parsePostId(Element element) {
    _findPostItemInfoDivs(element);

    if (_isEnableParsing() == false) {
      return '';
    }

    final postIdStr = _postItemInfoDivElements[0].text;
    final postIdRegexp = RegExp(r'humordata_(?<postId>[0-9]+)');

    final matched = postIdRegexp.firstMatch(postIdStr);
    if (matched == null) {
      return '';
    }

    return matched.namedGroup('postId');
  }

  @override
  String parseBodyUrl(Element element) {
    _findPostItemInfoDivs(element);

    if (_isEnableParsing() == false) {
      return '';
    }

    var aElement = _postItemInfoDivElements[8].querySelector('a');
    if (aElement == null) {
      return '';
    }

    return aElement.attributes['href'] ?? '';
  }

  @override
  String parseSubject(Element element) {
    var subjectElement =
        document.querySelector('div.containerInner > div.viewSubjectDiv > div');
    return subjectElement.text ?? '';
  }

  @override
  int parseCommentCount(Element element) {
    _findPostItemInfoDivs(element);

    if (_isEnableParsing() == false) {
      return 0;
    }

    final commentCountStr = _postItemInfoDivElements[5].text;
    final commentCountRegexp = RegExp(r': (?<commentCount>[0-9]+)개');
    final matched = commentCountRegexp.firstMatch(commentCountStr);
    if (matched == null) {
      return 0;
    }

    return int.tryParse(matched.namedGroup('commentCount')) ?? 0;
  }

  @override
  int parseGoodCount(Element element) {
    _findPostItemInfoDivs(element);

    if (_isEnableParsing() == false) {
      return 0;
    }

    final goodCountElement =
        _postItemInfoDivElements[2].querySelector('span.view_ok_nok');
    final goodCountStr = goodCountElement?.text ?? '';

    return int.tryParse(goodCountStr) ?? 0;
  }

  @override
  int parseBadCount(Element element) {
    // badCount는 존재하지 않는다.
    return -1;
  }

  @override
  int parseViewCount(Element element) {
    _findPostItemInfoDivs(element);

    if (_isEnableParsing() == false) {
      return 0;
    }

    final viewCountStr = _postItemInfoDivElements[3].text;
    final viewCountRegexp = RegExp(r': (?<viewCount>[0-9]+)');
    final matched = viewCountRegexp.firstMatch(viewCountStr);
    if (matched == null) {
      return 0;
    }

    return int.tryParse(matched.namedGroup('viewCount')) ?? 0;
  }

  @override
  String parseWriteDateTime(Element element) {
    _findPostItemInfoDivs(element);

    if (_isEnableParsing() == false) {
      return '';
    }

    final writeDateTimeStr = _postItemInfoDivElements[6].text;
    final writeDateTimeRegexp = RegExp(
        r'.?:.?(?<y>[0-9]+)/(?<M>[0-9]+)/(?<d>[0-9]+) (?<h>[0-9]+):(?<m>[0-9]+)');
    final matched = writeDateTimeRegexp.firstMatch(writeDateTimeStr);

    final year = matched.namedGroup('y');
    final month = matched.namedGroup('M');
    final day = matched.namedGroup('d');
    final hour = matched.namedGroup('h');
    final minute = matched.namedGroup('m');

    return '$year-$month-$day $hour:$minute';
  }
}

/// 오늘의 유머 게시글 Parsing 결과
class TodayHumorPostElement extends PostElement {
  @override
  PostElement createPostElement({PostContentType contentType}) {
    return TodayHumorPostElement()..setElementData(contentType: contentType);
  }

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    if (tag == 'video') {
      var sourceElement = targetElement.querySelector('source');
      if (sourceElement == null) {
        return PrefixParseResult.ignore;
      }

      var viedeoSource = sourceElement.attributes['src'] ?? '';
      setElementData(
        tag: 'video',
        contentType: PostContentType.video,
        content: viedeoSource,
      );

      return PrefixParseResult.skip_child_parse;
    }

    return super.prefixParseDefaultTag(tag, targetElement);
  }
}

/// 오늘의 유머 Comment Unit parsing하기
class TodayHumorPostCommentItem extends PostCommentItem {
  @override
  String parseAuthorIconUrl(Element element) {
    // authorIcon이 존재하지 않는다.
    return '';
  }

  @override
  String parseAuthorName(Element element) {
    final authNameElement =
        element.querySelector('div.memoInfoDiv > span.memoName > a');

    return authNameElement?.text ?? '';
  }

  @override
  int parseCommentBadCount(Element element) {
    // badCount가 존재하지 않는다.
    return -1;
  }

  @override
  int parseCommentGoodCount(Element element) {
    final goodCountElement =
        element.querySelector('div.memoInfoDiv > span.memoOkNok');
    final goodCountStr = goodCountElement?.text ?? '';

    final goodCountRegexp = RegExp(r'(?<goodCount>[0-9]+)');
    final matched = goodCountRegexp.firstMatch(goodCountStr);
    if (matched == null) {
      return 0;
    }

    return int.tryParse(matched.namedGroup('goodCount')) ?? 0;
  }

  @override
  String parseCommentWriteDatetime(Element element) {
    final memoDateElement =
        element.querySelector('div.memoInfoDiv > span.memoDate');
    var dateTimeStr = memoDateElement?.text?.trim() ?? '';
    dateTimeStr = dateTimeStr.replaceAll('(', '');
    dateTimeStr = dateTimeStr.replaceAll(')', '');

    return dateTimeStr;
  }

  @override
  bool parseReComment(Element element) {
    return element.classes.contains('rereMemoDiv') ? true : false;
  }

  @override
  CommentContent createCommentContent() {
    return TodayHumorCommentContent();
  }

  @override
  Element getCommentContentElement(Element element) {
    return element.querySelector('div.memoContent');
  }
}

class TodayHumorCommentContent extends CommentContent {
  @override
  CommentContent createPostElement({PostContentType contentType}) {
    return TodayHumorCommentContent()..setContentData(contentType: contentType);
  }

  String _findVideoUrl(Element element) {
    final videoSourceElement = element.querySelector('source');
    if (videoSourceElement == null) {
      return '';
    }

    return videoSourceElement.attributes['src'] ?? '';
  }

  @override
  PrefixParseResult prefixParseDefaultTag(String tag, Element targetElement) {
    if (tag == 'video') {
      final videoUrl = _findVideoUrl(targetElement);
      if (videoUrl.isNotEmpty) {
        setContentData(
          tag: 'vidoe',
          contentType: PostContentType.video,
          content: videoUrl,
        );
        return PrefixParseResult.skip_child_parse;
      }
    }

    return super.prefixParseDefaultTag(tag, targetElement);
  }

  @override
  void postfixRoot(CommentContent rootCommentContent) {
    while (rootCommentContent.children.length > 1 &&
        rootCommentContent.children.last.tag == 'br') {
      rootCommentContent.children.remove(rootCommentContent.children.last);
    }
  }
}
