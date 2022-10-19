import 'dart:async';
import 'dart:ffi';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:tuple/tuple.dart';

class HexabaseItem extends HexabaseBase {
  late String? id;
  late String? status;
  late String? statusId;
  late String? title;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late String? createdBy;
  late String? updatedBy;
  late String? datastoreId;
  late String? projectId;
  int revNo = 0;
  late int? unread;
  // For update
  late String? actionId;
  bool ensureTransaction = false;
  bool useDisplayId = true;
  bool isNotifyToSender = false;
  bool execChildrenPostProcs = false;
  bool isForceUpdate = false;
  bool returnItemResult = true;
  bool returnActionscriptLogs = false;
  bool disableLinker = false;
  List<Map<String, dynamic>> changes = [];
  Map<String, dynamic> asParams = {};
  Map<String, dynamic> relatedDsItems = {};
  // groupsToPublish
  // accessKeyUpdates
  final Map<String, dynamic> _fields = {};

  HexabaseItem({this.id, this.datastoreId, this.projectId}) : super();

  static Future<Tuple2<int, List<HexabaseItem>>> all(String datastoreId,
      HexabaseItemsParameters params, String? projectId) async {
    final response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS,
        variables: {
          'projectId': projectId,
          'datastoreId': datastoreId,
          'getItemsParameters': params.toJson()
        });
    var ary =
        response.data!['datastoreGetDatastoreItems']['items'] as List<dynamic>;
    var items = ary.map((data) {
      data = data as Map<String, dynamic>;
      var item = HexabaseItem();
      data.forEach((key, value) => item.set(key, value));
      return item;
    }).toList();
    return Tuple2(
        response.data!['datastoreGetDatastoreItems']['totalItems'] as int,
        items);
  }

  HexabaseItem set(String name, dynamic value) {
    switch (name.toLowerCase()) {
      case 'status':
        status = value as String?;
        break;
      case 'status_id':
        statusId = value as String?;
        break;
      case 'created_at':
        createdAt = DateTime.parse(value as String);
        break;
      case 'updated_at':
        updatedAt = DateTime.parse(value as String);
        break;
      case 'created_by':
        createdBy = value as String;
        break;
      case 'updated_by':
        updatedBy = value as String;
        break;
      case 'd_id':
        datastoreId = value as String;
        break;
      case 'i_id':
        id = value as String;
        break;
      case 'p_id':
        projectId = value as String;
        break;
      case 'rev_no':
        if (value is int) {
          revNo = value;
        } else {
          revNo = int.parse(value as String);
        }
        break;
      case 'title':
        title = value as String;
        break;
      case 'unread':
        unread = int.parse(value);
        break;
      default:
        _fields[name] = value;
    }
    return this;
  }

  dynamic get(String field) {
    if (_fields.containsKey(field)) {
      return _fields[field];
    }
    return null;
  }

  Future<bool> save() {
    if (id == null) {
      return create();
    } else {
      return update();
    }
  }

  Future<bool> create() async {
    var response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_CREATE_NEW_ITEM,
        variables: {
          'projectId': projectId,
          'datastoreId': datastoreId,
          'newItemActionParameters': toJson()
        });
    id = response.data!['datastoreCreateNewItem']['item_id'] as String;
    return getDetail();
  }

  Future<bool> getDetail() async {
    var response = await HexabaseBase.query(GRAPHQL_GET_DATASTORE_ITEM_DETAILS,
        variables: {
          'projectId': projectId,
          'datastoreId': datastoreId,
          'itemId': id,
          'datastoreItemDetailParams': {
            'use_display_id': true,
            'return_number_value': true,
          }
        });
    var data =
        response.data!['getDatastoreItemDetails'] as Map<String, dynamic>;
    set('title', data['title']).set('rev_no', data['rev_no']);
    var params = data['field_values'] as Map<String, dynamic>;
    params.forEach((key, value) => set(key, value['value']));
    return true;
  }

  Future<bool> update() async {
    final response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_UPDATE_ITEM, variables: {
      'projectId': projectId,
      'datastoreId': datastoreId,
      'itemId': id,
      'itemActionParameters': toJson()
    });
    var params =
        response.data!['datastoreUpdateItem']['item'] as Map<String, dynamic>;
    params.forEach((key, value) => set(key, value));
    return true;
  }

  Future<bool> delete(
      {String? uId,
      String? aId,
      bool? deleteLinkedItems,
      List<String>? targetDatastores}) async {
    Map<String, dynamic> params = {};
    if (uId != null) params['u_id'] = uId;
    if (aId != null) params['a_id'] = aId;
    if (deleteLinkedItems != null) {
      params['delete_linked_items'] = deleteLinkedItems;
    }
    if (targetDatastores != null) {
      params['target_datastores'] = targetDatastores;
    }
    final response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_DELETE_ITEM, variables: {
      'projectId': projectId,
      'datastoreId': datastoreId,
      'itemId': id,
      'deleteItemReq': params
    });
    return response.data!['datastoreDeleteItem']['error'] == null;
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    json["item"] = {};
    _fields.forEach((key, value) {
      if (value is DateTime) {
        value = value.toIso8601String();
      }
      json["item"][key] = value;
    });
    if (revNo > 0) {
      json['rev_no'] = revNo;
    }
    json['use_display_id'] = useDisplayId;
    json['is_notify_to_sender'] = isNotifyToSender;
    json['exec_children_post_procs'] = execChildrenPostProcs;
    json['is_force_update'] = isForceUpdate;
    json['return_item_result'] = returnItemResult;
    json['return_actionscript_logs'] = returnActionscriptLogs;
    json['disable_linker'] = disableLinker;
    return json;
  }
}
