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

class HexabaseHistory extends HexabaseBase {
  late HexabaseItem item;
  late HexabaseUser user;
  String id = '';
  late int displayOrder;
  late String comment;
  late bool isUnread;
  late DateTime createdAt;
  late String actionId;
  late String actionName;
  late String transactionId;
  late String actionOperation;
  late bool isStatusAction;
  late String updatedBy;
  late DateTime updatedAt;
  late String mediaLink;
  late bool isUpdated;
  late bool isFetchreplymail;
  late bool isChanged;
  late bool postForRel;
  late String postMode;
  late bool isNotify;
  late bool isNotifyToSender;
  late bool isSendItemUnread;

  HexabaseHistory({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  static Future<List<HexabaseHistory>> all(HexabaseItem item,
      [Map<String, dynamic>? params]) async {
    var res = await allWithUnread(item, params);
    return res.item2;
  }

  static Future<Tuple2<int, List<HexabaseHistory>>> allWithUnread(
      HexabaseItem item,
      [Map<String, dynamic>? queries]) async {
    var params = {
      'projectId': item.datastore!.project!.id,
      'datastoreId': item.datastore!.id,
      'itemId': item.id,
      'getHistoryParamQueries': queries,
    };
    var user = HexabaseUser();
    var response =
        await HexabaseBase.query(GRAPHQL_ITEM_HISTORIES, variables: params);
    if (response.data == null || response.data!['getHistories'] == null) {
      throw Exception('Failed to get histories');
    }
    var res = response.data!['getHistories'] as Map<String, dynamic>;
    final histories = res['histories'].map<HexabaseHistory>((history) {
      (history as Map<String, dynamic>).addAll({
        'item': item,
        'user': user,
      });
      return HexabaseHistory(params: history);
    }).toList();
    return Tuple2(res['unread'] as int, histories);
  }

  HexabaseHistory sets(Map<String, dynamic> params) {
    if (params.containsKey('item')) set('item', params['item']!);
    if (params.containsKey('user')) set('user', params['user']!);
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseHistory set(String key, dynamic value) {
    if (value == null) return this;
    switch (key) {
      case 'history_id':
      case '_id':
        id = value;
        break;
      case 'item':
        item = value as HexabaseItem;
        break;
      case 'display_order':
      case 'displayorder':
        displayOrder = value;
        break;
      case 'comment':
        comment = value;
        break;
      case 'issenditemunread':
        isSendItemUnread = value;
        break;
      case 'is_unread':
        isUnread = value;
        break;
      case 'created_at':
        createdAt = DateTime.parse(value as String);
        break;
      case 'action_id':
        actionId = value;
        break;
      case 'action_name':
      case 'actionname':
        actionName = value;
        break;
      case 'transaction_id':
        transactionId = value;
        break;
      case 'action_operation':
        actionOperation = value;
        break;
      case 'is_status_action':
        isStatusAction = value;
        break;
      case 'UserObjID':
      case 'user_obj_id':
        user.set('id', value);
        break;
      case 'user':
        user = value as HexabaseUser;
        break;
      case 'isnotifytosender':
        isNotifyToSender = value;
        break;
      case 'updated_by':
        updatedBy = value;
        break;
      case 'updated_at':
        updatedAt = DateTime.parse(value as String);
        break;
      case 'media_link':
        mediaLink = value;
        break;
      case 'is_updated':
        isUpdated = value;
        break;
      case 'user_id':
        user.set('id', value);
        break;
      case 'email':
        user.set('email', value);
        break;
      case 'username':
        user.set('userName', value);
        break;
      case 'is_fetchreplymail':
        isFetchreplymail = value;
        break;
      case 'IsChanged':
      case 'ischanged':
        isChanged = value;
        break;
      case 'post_for_rel':
        postForRel = value;
        break;
      case 'post_mode':
        postMode = value;
        break;
      case 'is_notify':
        isNotify = value as bool;
        break;
      case 'datastore_name':
      case 'datastore_id':
      case 'i_id':
      case 'item_id':
      case 'project_id':
      case 'workspace_id':
      case '__typename':
        break;
      default:
        throw Exception(
            'Invalid field name in HexabaseHistory, $key and $value');
    }
    return this;
  }

  Future<bool> save() async {
    if (id != '') return update();
    return create();
  }

  Future<bool> create([bool? unread]) async {
    Map<String, dynamic> payload = {
      'workspace_id': HexabaseBase.client.currentWorkspace.id,
      'project_id': item.datastore!.project!.id,
      'datastore_id': item.datastore!.id,
      'item_id': item.id,
      'post_mode': '',
      'comment': comment,
    };
    if (unread != null && !unread) {
    } else {
      payload['is_send_item_unread'] = true;
    }
    var response =
        await HexabaseBase.mutation(GRAPHQL_POST_NEW_ITEM_HISTORY, variables: {
      'payload': payload,
    });
    if (response.data == null || response.data!['postNewItemHistory'] == null) {
      throw Exception('Failed to create history');
    }
    var res = response.data!['postNewItemHistory'] as Map<String, dynamic>;
    if (res['item_history'] == null) {
      throw Exception('Failed to create history');
    }
    sets(res['item_history'] as Map<String, dynamic>);
    return true;
  }

  Future<bool> update() async {
    var payload = {
      'p_id': item.datastore!.project!.id,
      'd_id': item.datastore!.id,
      'i_id': item.id,
      'h_id': id,
      'comment': comment,
    };
    var response = await HexabaseBase.mutation(GRAPHQL_POST_UPDATE_ITEM_HISTORY,
        variables: {
          'payload': payload,
        });
    if (response.data == null ||
        response.data!['postUpdateItemHistory'] == null) {
      throw Exception('Failed to update history');
    }
    return response.data!['postUpdateItemHistory']['error'] == null;
  }

  Future<bool> delete() async {
    var payload = {
      'p_id': item.datastore!.project!.id,
      'd_id': item.datastore!.id,
      'i_id': item.id,
      'h_id': id,
    };
    var response = await HexabaseBase.mutation(GRAPHQL_POST_DELETE_ITEM_HISTORY,
        variables: {
          'payload': payload,
        });
    if (response.data == null || response.data!['archiveItemHistory'] == null) {
      throw Exception('Failed to update history');
    }
    return response.data!['archiveItemHistory']['error'] == null;
  }
}
