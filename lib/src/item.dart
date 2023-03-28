import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:tuple/tuple.dart';
import 'package:eventsource/eventsource.dart';

class HexabaseItem extends HexabaseBase {
  late String? id;
  late String? status;
  late String? statusId;
  late String? title;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late String? createdBy;
  late String? updatedBy;
  late HexabaseProject? project;
  late HexabaseDatastore? datastore;
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
  HexabaseItem({this.id, this.datastore, this.project}) : super();

  static Future<Tuple2<int, List<HexabaseItem>>> all(
      HexabaseDatastore datastore,
      HexabaseItemsParameters params,
      HexabaseProject? project) async {
    var variables = {
      'datastoreId': datastore.id,
      'getItemsParameters': await params.toJson()
    };
    if (project != null) {
      variables['projectId'] = project.id;
    }
    final response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS,
        variables: variables);
    // print(response);
    var ary =
        response.data!['datastoreGetDatastoreItems']['items'] as List<dynamic>;
    var items = ary.map((data) {
      data = data as Map<String, dynamic>;
      var item = HexabaseItem(datastore: datastore, project: project);
      data.forEach((key, value) => item.set(key, value));
      return item;
    }).toList();
    return Tuple2(
        response.data!['datastoreGetDatastoreItems']['totalItems'] as int,
        items);
  }

  static Future<Tuple2<int, List<HexabaseItem>>> search(
      HexabaseDatastore datastore,
      HBSearchType type,
      String query,
      Map<String, dynamic> itemSearchParams,
      {HexabaseProject? project,
      String? fieldId}) async {
    var category = '';
    switch (type) {
      case HBSearchType.item:
        category = 'items';
        break;
      case HBSearchType.file:
        category = 'files';
        break;
      case HBSearchType.history:
        category = 'histories';
        break;
    }
    var payload = {
      'datastore_id': datastore.id,
      'query': query,
      'return_item_list': true,
      'category': category,
      'item_search_params': itemSearchParams,
    };
    if (fieldId != null) {
      payload['field_id'] = fieldId;
    }
    if (project != null) {
      payload['app_id'] = project.id;
    }
    final response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORES_GLOBAL_SEARCH,
        variables: {
          'payload': payload,
        });
    var ary = response.data!['datastoresGlobalSearch']['item_list']['items']
        as List<dynamic>;
    var items = ary.map((data) {
      data = data as Map<String, dynamic>;
      var item = HexabaseItem(datastore: datastore, project: project);
      data.forEach((key, value) => item.set(key, value));
      return item;
    }).toList();
    return Tuple2(
        response.data!['datastoresGlobalSearch']['item_list']['totalItems']
            as int,
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
        datastore = HexabaseDatastore(id: value as String);
        break;
      case 'i_id':
        id = value as String;
        break;
      case 'p_id':
        project = HexabaseProject(id: value as String);
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
      case 'lookup_items':
        var params = value as Map<String, dynamic>;
        params.forEach((key, value) {
          var item = HexabaseItem();
          item.sets(value);
          _fields[key] = item;
        });
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

  HexabaseItem getAsItem(String field) {
    if (_fields.containsKey(field)) {
      return _fields[field] as HexabaseItem;
    }
    return HexabaseItem();
  }

  Future<bool> save({String? comment = ""}) {
    if (id == null) {
      return create();
    } else {
      return update(comment: comment);
    }
  }

  Future<bool> create() async {
    var response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_CREATE_NEW_ITEM,
        variables: {
          'projectId': project!.id,
          'datastoreId': datastore!.id,
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
          'projectId': project!.id,
          'datastoreId': datastore!.id,
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

  List<HexabaseItemAction> actions() {
    return _actions;
  }

  List<HexabaseItemAction> statues() {
    return _statuses;
  }

  Future<bool> update({String? comment = ""}) async {
    if (_updateStatus) {
      return updateStatus();
    }
    final response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_UPDATE_ITEM, variables: {
      'projectId': project!.id,
      'datastoreId': datastore!.id,
      'itemId': id,
      'itemActionParameters': await toJson(),
      'is_notify_to_sender': true,
      'comment': comment ?? ''
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
          'projectId': project!.id,
          'datastoreId': datastore!.id,
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
      'projectId': project!.id,
      'datastoreId': datastore!.id,
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
      } else if (value is HexabaseItem) {
        // ignore
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
    print(json);
    return json;
  }

  void subscribe(Function(Event) f) async {
    final channel = "datastore_${HexabaseBase.client.currentUser!.id}_$id";
    print(channel);
    HexabaseBase.subscribe(channel, (p0) => print(p0));
  }
}
