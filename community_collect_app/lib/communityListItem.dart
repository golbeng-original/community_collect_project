import 'package:flutter/material.dart';
import 'package:community_parser/community_parser.dart';

class CommunityListItem extends StatelessWidget {
  PostListItem _postListItem;

  CommunityListItem({Key key, @required postItemlist}) : super(key: key) {
    _postListItem = postItemlist;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
