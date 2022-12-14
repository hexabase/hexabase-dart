import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/item_action.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:hexabase/src/file.dart';
import 'package:tuple/tuple.dart';
import 'package:eventsource/eventsource.dart';
// import "package:http/browser_client.dart";

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
  Map<String, dynamic> _uploadFile = {};

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
  final Map<String, String> _fieldTypes = {};
  final List<HexabaseItemAction> _statuses = [];
  late String _action = "";
  final List<HexabaseItemAction> _actions = [];
  // private
  var _updateStatus = false;
  HexabaseItem({this.id, this.datastoreId, this.projectId}) : super();

  static Future<Tuple2<int, List<HexabaseItem>>> all(String datastoreId,
      HexabaseItemsParameters params, String? projectId) async {
    final response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS,
        variables: {
          'projectId': projectId,
          'datastoreId': datastoreId,
          'getItemsParameters': await params.toJson()
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

  HexabaseItem sets(Map<String, dynamic> fields) {
    fields.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseItem action(String actionName) {
    _action = actionName;
    _updateStatus = true;
    return this;
  }

  HexabaseItem add(String name, dynamic value) {
    if (!_fields.containsKey(name)) {
      _fields[name] = [_transValue(name, value)];
      return this;
    }
    final val = _fields[name];
    if (val is List) {
      val.add(_transValue(name, value));
      _fields[name] = val;
    } else if (val == null) {
      _fields[name] = [_transValue(name, value)];
    } else {
      _fields[name] = [val, _transValue(name, value)];
    }
    return this;
  }

  HexabaseItem remove(String name, dynamic value) {
    if (!_fields.containsKey(name)) {
      return this;
    }
    var val = _fields[name];
    if (val is List) {
      val = val.where((v) {
        if (v is HexabaseFile) {
          return v.id != value.id;
        }
        return v != value;
      }).toList();
      _fields[name] = val;
    }
    return this;
  }

  dynamic _transValue(String name, dynamic value) {
    if (value is HexabaseFile) {
      value.fieldId = name;
      value.item = this;
      return value;
    }
    return value;
  }

  HexabaseItem set(String name, dynamic value) {
    value = _transValue(name, value);
    if (value == null) return this;
    switch (name.toLowerCase()) {
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
        if (value is Map && value.containsKey('file_id')) {
          var file = HexabaseFile();
          file.sets(value as Map<String, dynamic>);
          file.set('item', this);
          _fields[name] = file;
        } else if (value is List &&
            value.isNotEmpty &&
            value[0] is Map &&
            value[0].containsKey('file_id')) {
          var files = value.map((data) {
            var file = HexabaseFile();
            file.sets(data as Map<String, dynamic>);
            file.set('item', this);
            return file;
          }).toList();
          _fields[name] = files;
        } else {
          _fields[name] = value;
        }
    }
    return this;
  }

  dynamic get(String field) {
    if (_fields.containsKey(field)) {
      return _fields[field];
    }
    return null;
  }

  String getAsString(String field, {String? defaultValue}) {
    if ((!_fields.containsKey(field) || _fields[field] == null) &&
        defaultValue != null) {
      return defaultValue;
    }
    return _fields[field]! as String;
  }

  bool getAsBool(String field, {bool? defaultValue}) {
    if ((!_fields.containsKey(field) || _fields[field] == null) &&
        defaultValue != null) {
      return defaultValue;
    }
    return _fields[field]! as bool;
  }

  int getAsInt(String field, {int? defaultValue}) {
    if ((!_fields.containsKey(field) || _fields[field] == null) &&
        defaultValue != null) {
      return defaultValue;
    }
    return int.parse(_fields[field]);
  }

  double getAsDouble(String field, {double? defaultValue}) {
    if ((!_fields.containsKey(field) || _fields[field] == null) &&
        defaultValue != null) {
      return defaultValue;
    }
    return double.parse(_fields[field]);
  }

  DateTime getAsDateTime(String field, {DateTime? defaultValue}) {
    if ((!_fields.containsKey(field) || _fields[field] == null) &&
        defaultValue != null) {
      return defaultValue;
    }
    if (_fields[field] is DateTime) {
      return _fields[field] as DateTime;
    }
    return DateTime.parse(_fields[field]);
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
          'newItemActionParameters': await toJson()
        });
    id = response.data!['datastoreCreateNewItem']['item_id'] as String;
    await getDetail();
    await uploadFile();
    return true;
  }

  Future<bool> uploadFile() async {
    if (_uploadFile.isEmpty) return true;
    List<Future<bool>> futureList = [];
    _uploadFile.forEach((key, value) async {
      if (value is List) {
        for (var file in value) {
          file = file as HexabaseFile;
          file.set('item', this);
          futureList.add(file.save());
        }
      } else {
        value = value as HexabaseFile;
        value.set('item', this);
        futureList.add(value.save());
      }
    });
    await Future.wait(futureList);
    _uploadFile.forEach((key, value) {
      if (value is List) {
        set(
            key,
            value.map((e) {
              e = e as HexabaseFile;
              return e.id;
            }).toList());
      } else {
        value = value as HexabaseFile;
        set(key, value.id);
      }
    });
    await update();
    _uploadFile = {}; // Reset
    return true;
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
    // _setStatusList(data['status_list'] as Map<String, dynamic>);
    // set actions
    _setStatusActions(data['status_actions'] as Map<String, dynamic>);
    var params = data['field_values'] as Map<String, dynamic>;
    params.forEach((key, value) {
      value = value as Map<String, dynamic>;
      if (value['dataType'] == 'status') {
        status = value['value'];
      } else {
        set(key, value['value']);
      }
      _fieldTypes[key] = value['dataType'] as String;
    });
    return true;
  }

  void _setStatusActions(Map<String, dynamic> statusActions) {
    _actions.clear();
    statusActions.forEach((key, value) {
      _actions.add(HexabaseItemAction(
        id: value["a_id"],
        idLabel: value["status_id"],
        name: key,
        nameLabel: value["action_name"],
        description: value["description"],
        displayOrder: value["display_order"],
        crudType: int.parse(value["crud_type"]),
        nextStatusId: value["next_status_id"],
      ));
    });
  }

  /*
  void _setStatusList(Map<String, dynamic> statuses) {
    statuses.forEach((key, value) {
      _statuses.add(HexabaseItemAction(
          id: value["s_id"],
          idLabel: value["status_id"],
          name: key,
          nameLabel: value["status_name"]));
    });
  }
  */

  List<HexabaseItemAction> actions() {
    return _actions;
  }

  List<HexabaseItemAction> statues() {
    return _statuses;
  }

  Future<bool> update() async {
    if (_updateStatus) {
      return updateStatus();
    }
    final response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_UPDATE_ITEM, variables: {
      'projectId': projectId,
      'datastoreId': datastoreId,
      'itemId': id,
      'itemActionParameters': await toJson()
    });
    var params =
        response.data!['datastoreUpdateItem']['item'] as Map<String, dynamic>;
    sets(params);
    return true;
  }

  Future<bool> updateStatus() async {
    var action = _actions.firstWhere((a) =>
        a.name == _action ||
        a.id == _action ||
        a.idLabel == _action ||
        a.nameLabel == _action);
    var response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_EXECUTE_ITEM_ACTION,
        variables: {
          'projectId': projectId,
          'datastoreId': datastoreId,
          'itemId': id,
          'actionId': action.id,
          'itemActionParameters': await toJson()
        });
    _updateStatus = false;
    var params = response.data!['datastoreExecuteItemAction']['item']
        as Map<String, dynamic>;
    sets(params);
    return getDetail();
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
    return true;
  }

  Future<Map<String, dynamic>> toJson() async {
    var json = <String, dynamic>{};
    json["item"] = {};
    _fields.forEach((key, value) async {
      if (value is DateTime) {
        value = value.toIso8601String();
      } else if (value is HexabaseFile) {
        _uploadFile[key] = value;
      } else if (value is List &&
          value.isNotEmpty &&
          value[0] is HexabaseFile) {
        _uploadFile[key] = value;
      } else {
        json["item"][key] = value;
      }
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

  void subscribe(Function(Event) f) async {
    final channel = "item_view_${id}_${HexabaseBase.client.currentUser!.id}";
    final url = "https://sse.hexabase.com/sse?channel=${channel}";
    final eventSource = await EventSource.connect(url);
    /*
    final eventSource = await (kIsWeb
        ? EventSource.connect(url, client: BrowserClient())
        : EventSource.connect(url));
    */
    eventSource.listen(f);
    return;
  }
}
