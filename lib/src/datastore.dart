import 'dart:async';
import 'package:collection/collection.dart';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/field_result.dart';
// import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/items_parameter.dart';
// import 'package:hexabase/src/search_condition.dart';
import 'package:hexabase/src/graphql.dart';
// import 'package:hexabase/src/field.dart';
import 'package:hexabase/src/role.dart';
import 'package:hexabase/src/status.dart';

class HBDataStoreResponseWithCount {
  final int count;
  final List<HexabaseItem> items;
  HBDataStoreResponseWithCount(this.count, this.items);
}

enum HBSearchType {
  item,
  file,
  history,
}

class HexabaseDatastore extends HexabaseBase {
  String id = '';
  late Map<String, String>? _name = {};
  late HexabaseProject? project;
  late String? displayId;
  late bool? deleted;
  late bool? imported;
  late bool? uploading;

  int extendLimitTextareaLength = 2000;
  bool ignoreSaveTemplate = false;
  bool showDisplayIdToList = false;
  bool showInMenu = true;
  bool showInfoToList = false;
  bool showOnlyDevMode = false;
  bool useBoardView = false;
  bool useCsvUpdate = false;
  bool useExternalSync = false;
  bool useGridView = false;
  bool useGridViewByDefault = false;
  bool useQrDownload = false;
  bool useReplaceUpload = false;
  bool useStatusUpdate = false;

  late bool noStatus;
  late int displayOrder;
  late int unread;
  late bool invisible;
  late bool isExternalService;
  late String dataSource;
  late Map<dynamic, dynamic> externalServiceData;

  List<HexabaseField>? _fields;
  List<HexabaseRole>? _roles;
  List<HexabaseStatus>? _statuses;

  HexabaseDatastore({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseDatastore sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseDatastore set(String key, dynamic value) {
    switch (key) {
      case 'id':
      case 'd_id':
      case 'datastore_id':
        id = value as String;
        break;
      case 'project':
        project = value as HexabaseProject;
        break;
      case 'display_id':
        displayId = value as String;
        break;
      case 'uploading':
        uploading = value as bool;
        break;
      case 'imported':
        imported = value as bool;
        break;
      case 'no_status':
        noStatus = value as bool;
        break;
      case 'show_in_menu':
        showInMenu = value as bool;
        break;
      case 'deleted':
        deleted = value as bool;
        break;
      case 'extend_limit_textarea_length':
        extendLimitTextareaLength = value as int;
        break;
      case 'ignore_save_template':
        ignoreSaveTemplate = value as bool;
        break;
      case 'show_display_id_to_list':
        showDisplayIdToList = value as bool;
        break;
      case 'show_info_to_list':
        showInfoToList = value as bool;
        break;
      case 'show_only_dev_mode':
        showOnlyDevMode = value as bool;
        break;
      case 'use_board_view':
        useBoardView = value as bool;
        break;
      case 'use_csv_update':
        useCsvUpdate = value as bool;
        break;
      case 'use_external_sync':
        useExternalSync = value as bool;
        break;
      case 'use_grid_view':
        useGridView = value as bool;
        break;
      case 'use_grid_view_by_default':
        useGridViewByDefault = value as bool;
        break;
      case 'use_qr_download':
        useQrDownload = value as bool;
        break;
      case 'use_replace_upload':
        useReplaceUpload = value as bool;
        break;
      case 'use_status_update':
        useStatusUpdate = value as bool;
        break;
      case 'display_order':
        displayOrder = value as int;
        break;
      case 'unread':
        unread = value as int;
        break;
      case 'invisible':
        invisible = value as bool;
        break;
      case 'is_external_service':
        isExternalService = value as bool;
        break;
      case 'data_source':
        dataSource = value as String;
        break;
      case 'external_service_data':
        if (value != null) {
          externalServiceData = value as Map;
        }
        break;
      case 'names':
      case 'name':
        if (value is String) {
          _name = {'ja': value, 'en': value};
        } else {
          for (var entry in (value as Map<String, dynamic>).entries) {
            _name![entry.key] = entry.value as String;
          }
        }
        break;
      case 'fields':
        _fields = (value as List<dynamic>).map((e) {
          (e as Map<String, dynamic>).addAll({'datastore': this});
          return HexabaseField(params: e);
        }).toList();
        break;
      case 'roles':
        _roles = (value as List<dynamic>).map((e) {
          (e as Map<String, dynamic>)
              .addAll({'project': project, 'datastore': this});
          return HexabaseRole(params: e);
        }).toList();
        break;
      case 'statuses':
        _statuses = (value as List<dynamic>).map((e) {
          (e as Map<String, dynamic>).addAll({'datastore': this});
          return HexabaseStatus(params: e);
        }).toList();
        break;
      case '__typename':
      case 'p_id':
      case 'w_id':
      case 'ws_name':
      case 'field_layout':
        break;
      default:
        throw Exception('Invalid field name in datastore($id), $key');
    }
    return this;
  }

  String name(String language) {
    if (!['ja', 'en'].contains(language)) {
      throw Exception('Language must be ja or en');
    }
    return _name![language]!;
  }

  Future<HexabaseDatastore> save({templateName = 'SEED1', lang = 'ja'}) async {
    if (id == '') {
      await create(templateName, lang);
    } else {
      await update();
    }
    await HexabaseDatastore.all(project!);
    return await project!.datastore(id: id);
  }

  static Future<List<HexabaseDatastore>> all(HexabaseProject project) async {
    var response = await HexabaseBase.query(GRAPHQL_DATASTORES,
        variables: {'projectId': project.id});
    var ary = response.data!['datastores'] as List<dynamic>;
    var datastores =
        ary.map((e) => HexabaseDatastore.fromJson(project, e)).toList();
    project.datastores(datastores: datastores);
    return datastores;
  }

  Future<bool> fetch() async {
    if (id == '') {
      throw Exception('Datastore id is not set');
    }
    final response =
        await HexabaseBase.query(GRAPHQL_GET_DATASTORE, variables: {
      'datastoreId': id,
    });
    if (response.data != null && response.data!['datastoreSetting'] != null) {
      sets(response.data!['datastoreSetting'] as Map<String, dynamic>);
      await fields(refresh: true);
      return true;
    }
    throw Exception('Datastore $id is not found');
  }

  static HexabaseDatastore fromJson(
      HexabaseProject project, Map<String, dynamic> json) {
    json['project'] = project;
    return HexabaseDatastore(params: json);
  }

  Future<HexabaseDatastore> create(String templateName, String lang) async {
    var user = await HexabaseUser.current();
    if (project == null) throw Exception('Project is required');
    if (project!.workspace == null) throw Exception('Workspace is required');
    var response = await HexabaseBase.mutation(
        GRAPHQL_CREATE_DATASTORE_FROM_TEMPLATE,
        variables: {
          'payload': {
            'user_id': user!.id,
            'project_id': project!.id,
            'workspace_id': project!.workspace!.id,
            'template_name': templateName,
            'lang_cd': lang,
          }
        });
    id =
        response.data!['createDatastoreFromTemplate']!['datastoreId'] as String;
    return this;
  }

  Future<bool> update() async {
    var response = await HexabaseBase.mutation(GRAPHQL_UPDATE_DATASTORE_SETTING,
        variables: {
          'payload': {
            'datastore_id': id,
            'display_id': displayId,
            'extend_limit_textarea_length': extendLimitTextareaLength,
            'ignore_save_template': ignoreSaveTemplate,
            'is_extend_limit_textarea': !(extendLimitTextareaLength == 2000),
            'name': _name,
            'show_display_id_to_list': showDisplayIdToList,
            'show_in_menu': showInMenu,
            'show_info_to_list': showInfoToList,
            'show_only_dev_mode': showOnlyDevMode,
            'use_board_view': useBoardView,
            'use_csv_update': useCsvUpdate,
            'use_external_sync': useExternalSync,
            'use_grid_view': useGridView,
            'use_grid_view_by_default': useGridViewByDefault,
            'use_qr_download': useQrDownload,
            'use_replace_upload': useReplaceUpload,
            'use_status_update': useStatusUpdate,
          }
        });
    return response.data!['updateDatastoreSetting']!['success'] as bool;
  }

  Future<bool> delete() async {
    var response = await HexabaseBase.mutation(GRAPHQL_DELETE_DATASTORE,
        variables: {'datastoreId': id});
    var success = response.data!['deleteDatastore']['success'] as bool;
    return success;
  }

  Future<List<HexabaseItem>> items({HexabaseItemsParameters? query}) async {
    query = _getParams(query);
    var res = await HexabaseItem.all(this, query);
    return res.item2;
  }

  Future<HexabaseItem> item({String? id}) async {
    if (id == null) return HexabaseItem(params: {'datastore': this});
    var item = HexabaseItem(params: {'i_id': id, 'datastore': this});
    await item.fetch();
    return item;
  }

  HexabaseItem itemSync({String? id}) {
    if (id == null) return HexabaseItem(params: {'datastore': this});
    var item = HexabaseItem(params: {'i_id': id, 'datastore': this});
    return item;
  }

  Future<HBDataStoreResponseWithCount> itemsWithCount(
      {HexabaseItemsParameters? query}) async {
    query = _getParams(query);
    var res = await HexabaseItem.all(this, query);
    return HBDataStoreResponseWithCount(res.item1, res.item2);
  }

  Future<HBDataStoreResponseWithCount> search(
    HBSearchType type,
    String query, {
    int page = 1,
    int perPage = 10,
    List<Map<String, String>>? sortFields,
    String? fieldId,
  }) async {
    Map<String, dynamic> params = {
      'page': page,
      'per_page': perPage,
    };
    if (sortFields != null) {
      params['sort_fields'] = sortFields;
    }
    var res = await HexabaseItem.search(this, type, query, params,
        project: project, fieldId: fieldId);
    return HBDataStoreResponseWithCount(res.item1, res.item2);
  }

  HexabaseItemsParameters query() {
    return HexabaseItemsParameters();
  }

  HexabaseItemsParameters _getParams(HexabaseItemsParameters? params) {
    if (params == null) {
      params = HexabaseItemsParameters();
      params.per(0).page(1);
    }
    return params;
  }

  HexabaseField fieldSync(String name) {
    if (_fields == null) throw Exception('Fields are not fetched');
    var field = _fields!.firstWhereOrNull((field) =>
        field.name('ja') == name ||
        field.name('en') == name ||
        field.displayId == name ||
        field.id == name);
    if (field == null) {
      throw Exception("Field $name is not found in datastore ($id)");
    }
    return field;
  }

  Future<List<HexabaseField>> fields({bool? refresh}) async {
    if (refresh == true) _fields = null;
    if (_fields != null) return _fields!;
    if (project == null) throw Exception('Project is required');
    _fields = await HexabaseField.all(this);
    return _fields!;
  }

  Future<HexabaseField> field(String name) async {
    if (_fields == null) {
      await fields();
    }
    return fieldSync(name);
  }

  Future<List<HexabaseFieldResult>> searchConditions() async {
    var res = await HexabaseSearchCondition.all(project!, this);
    return res;
  }
}
