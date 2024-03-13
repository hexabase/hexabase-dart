import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/dslookup_info.dart';
import 'package:hexabase/src/field_option.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/file_info.dart';
import 'package:hexabase/src/data_types/base.dart';
import 'package:tuple/tuple.dart';

class HexabaseItemSubscription extends HexabaseBase {
  late HexabaseUser user;
  late HexabaseItem item;
  String id = '';
  late String actionName;
  late String comment;
  late String postMode;
  late bool postForRel;
  late bool isChanged;
  late bool isFetchreplymail;
  late List<String> fileIds;
  late DateTime createdAt;
  late int displayOrder;
  late bool isNotify;
  late bool isNotifyToSender;
  late bool isSendItemUnread;
  HexabaseItemSubscription({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseItemSubscription sets(Map<String, dynamic> params) {
    if (params.containsKey('item')) set('item', params['item']!);
    if (params.containsKey('user')) set('user', params['user']!);
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseItemSubscription set(String key, dynamic value) {
    if (value == null) return this;
    switch (key) {
      case 'item':
        item = value as HexabaseItem;
        break;
      case 'user':
        user = value as HexabaseUser;
        break;
      case '_id':
        id = value;
        break;
      case 'actionname':
        actionName = value;
        break;
      case 'comment':
        comment = value;
        break;
      case 'post_mode':
        postMode = value;
        break;
      case 'post_for_rel':
        postForRel = value;
        break;
      case 'ischanged':
        isChanged = value;
        break;
      case 'is_fetchreplymail':
        isFetchreplymail = value;
        break;
      case 'file_ids':
        fileIds = value;
        break;
      case 'created_at':
        createdAt = DateTime.parse(value);
        break;
      case 'displayorder':
        displayOrder = value;
        break;
      case 'is_notify':
        isNotify = value;
        break;
      case 'isnotifytosender':
        isNotifyToSender = value;
        break;
      case 'issenditemunread':
        isSendItemUnread = value;
        break;
      case 'workspace_id':
      case 'project_id':
      case 'datastore_id':
      case 'i_id':
      case 'user_id':
      case 'email':
      case 'username':
      case 'user_obj_id':
        break;
      default:
        throw Exception(
            'Invalid field name in HexabaseHistory, $key and $value');
    }
    return this;
  }
}
