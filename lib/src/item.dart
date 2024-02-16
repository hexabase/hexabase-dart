import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:tuple/tuple.dart';
import 'package:eventsource/eventsource.dart';
import 'package:hexabase/src/field.dart';

class HexabaseItem extends HexabaseBase {
  late String id = '';
  late String? status;
  late String? statusId;
  late String? title;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late String? createdBy;
  late String? updatedBy;
  late HexabaseDatastore? datastore;
  Map<String, dynamic> _uploadFile = {};

  int revNo = 0;
  late int? unread;
  late int? relatedKey;
  late String? seedId;

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
  late List<HexabaseItemAction> _statuses = [];
  late String _action = "";
  late List<HexabaseItemAction> _actions = [];
  late List<String> statusOrder = [];

  // private
  var _updateStatus = false;
  HexabaseItem({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  static Future<Tuple2<int, List<HexabaseItem>>> all(
      HexabaseDatastore datastore, HexabaseItemsParameters params) async {
    var variables = {
      'datastoreId': datastore.id,
      'getItemsParameters': await params.toJson()
    };

    if (datastore.project != null) {
      variables['projectId'] = datastore.project!.id;
    }
    await datastore.fields();
    final response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS,
        variables: variables);
    var ary =
        response.data!['datastoreGetDatastoreItems']['items'] as List<dynamic>;
    var items = ary.map((data) {
      data = data as Map<String, dynamic>;
      data.addAll({'datastore': datastore});
      return HexabaseItem(params: data);
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
      data.addAll({'datastore': datastore});
      return HexabaseItem(params: data);
    }).toList();
    return Tuple2(
        response.data!['datastoresGlobalSearch']['item_list']['totalItems']
            as int,
        items);
  }

  HexabaseItem sets(Map<String, dynamic> params) {
    if (params.containsKey("datastore")) {
      datastore = params['datastore'] as HexabaseDatastore;
    }
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseItem action(String actionName) {
    _action = actionName;
    _updateStatus = true;
    return this;
  }

  HexabaseItem add(String name, dynamic value) {
    var field = datastore!.fieldSync(name);
    if (!field.supportArray()) {
      throw Exception('Field $name does not support array');
    }
    if (!_fields.containsKey(name)) {
      _fields[name] = [];
    }
    (_fields[name] as List).add(value);
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

  HexabaseItem set(String key, dynamic value) {
    if (value == null) return this;
    switch (key) {
      case 'datastore':
        datastore = value as HexabaseDatastore;
        break;
      case 'Status':
        status = value as String;
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
      case 'i_id':
        id = value as String;
        break;
      case 'related_key':
        if (value != '') {
          relatedKey = int.parse(value);
        }
        break;
      case 'seed_i_id':
        seedId = value as String;
        break;
      case 'rev_no':
        if (value is int) {
          revNo = value;
        } else {
          revNo = int.parse(value as String);
        }
        break;
      case 'title':
      case 'Title':
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
      case 'item_actions':
        var params = value as Map<String, dynamic>;
        _actions = params.keys.map((key) {
          var data = params[key] as Map<String, dynamic>;
          data.addAll({'item': this});
          return HexabaseItemAction(params: data);
        }).toList();
        break;
      case 'status_actions':
        var params = value as Map<String, dynamic>;
        _statuses = params.keys.map((key) {
          var data = params[key] as Map<String, dynamic>;
          data.addAll({'item': this});
          return HexabaseItemAction(params: data);
        }).toList();
        break;
      case 'status_order':
        var params = value as List<dynamic>;
        statusOrder = params.map((e) => e as String).toList();
        break;
      case 'field_values':
        var params = value as Map<String, dynamic>;
        for (var key in params.keys) {
          setFieldValue(key, params[key]['value']);
        }
        break;
      case '__typename':
      case 'd_id':
      case 'p_id':
      case 'w_id':
      case 'status_list':
      case 'status_action_order':
      case 'item_action_order':
        break;
      default:
        setFieldValue(key, value);
    }
    return this;
  }

  HexabaseItem setFieldValue(String key, dynamic value) {
    var field = datastore!.fieldSync(key);
    if (field.dataType.name == 'status') {
      status = value;
    } else {
      _fields[key] = field.convert(value, this);
    }
    return this;
  }

  dynamic get<T>(String field) {
    if (field == 'title') {
      return title;
    }
    if (_fields.containsKey(field)) {
      return _fields[field] as T;
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

  bool isNew() {
    return id == '';
  }

  Future<bool> save({String? comment = ""}) {
    if (id == '') {
      return create();
    } else {
      return update(comment: comment);
    }
  }

  Future<bool> create() async {
    var response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_CREATE_NEW_ITEM,
        variables: {
          'projectId': datastore!.project!.id,
          'datastoreId': datastore!.id,
          'newItemActionParameters': await toJson()
        });
    id = response.data!['datastoreCreateNewItem']['item_id'] as String;
    await fetch();
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

  Future<bool> fetch() async {
    var response = await HexabaseBase.query(GRAPHQL_GET_DATASTORE_ITEM_DETAILS,
        variables: {
          'projectId': datastore!.project!.id,
          'datastoreId': datastore!.id,
          'itemId': id,
          'datastoreItemDetailParams': {
            'use_display_id': true,
            'return_number_value': true,
          }
        });
    var data =
        response.data!['getDatastoreItemDetails'] as Map<String, dynamic>;
    await datastore?.project?.datastores();
    sets(data);
    return true;
  }

  Future<List<HexabaseItemAction>> actions() async {
    if (_actions.isNotEmpty) {
      return _actions;
    }
    await fetch();
    return _actions;
  }

  Future<List<HexabaseItemAction>> statues() async {
    if (_statuses.isNotEmpty) {
      return _statuses;
    }
    await fetch();
    return _statuses;
  }

  Future<bool> update({String? comment = ""}) async {
    if (_updateStatus) {
      return updateStatus();
    }
    var itemActionParameters = await toJson();
    itemActionParameters['comment'] = comment ?? '';
    final response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_UPDATE_ITEM, variables: {
      'projectId': datastore!.project!.id,
      'datastoreId': datastore!.id,
      'itemId': id,
      'itemActionParameters': itemActionParameters,
      'is_notify_to_sender': true,
      'comment': comment ?? ''
    });
    var params =
        response.data!['datastoreUpdateItem']['item'] as Map<String, dynamic>;
    sets(params);
    return true;
  }

  Future<bool> updateStatus() async {
    var action = _actions.firstWhere(
        (a) => a.name == _action || a.id == _action || a.actionId == _action);
    var response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_EXECUTE_ITEM_ACTION,
        variables: {
          'projectId': datastore!.project!.id,
          'datastoreId': datastore!.id,
          'itemId': id,
          'actionId': action.id,
          'itemActionParameters': await toJson()
        });
    _updateStatus = false;
    var params = response.data!['datastoreExecuteItemAction']['item']
        as Map<String, dynamic>;
    sets(params);
    return fetch();
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
      'projectId': datastore!.project!.id,
      'datastoreId': datastore!.id,
      'itemId': id,
      'deleteItemReq': params
    });
    return true;
  }

  Future<HexabaseFile> file() async {
    if (!isNew() && _fields.isEmpty) {
      await fetch();
    }
    return HexabaseFile(params: {'item': this});
  }

  Future<Map<String, dynamic>> toJson() async {
    var json = <String, dynamic>{};
    json["item"] = {};
    for (var entry in _fields.entries) {
      var field = datastore!.fieldSync(entry.key);
      if (!field.savable()) continue;
      json["item"][entry.key] = await field.jsonValue(entry.value);
    }
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
    final channel = "datastore_${HexabaseBase.client.currentUser!.id}_$id";
    print(channel);
    HexabaseBase.subscribe(channel, (p0) => print(p0));
  }
}
