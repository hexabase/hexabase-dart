import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/field_result.dart';
// import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/items_parameter.dart';
// import 'package:hexabase/src/search_condition.dart';
import 'package:hexabase/src/graphql.dart';
// import 'package:hexabase/src/field.dart';

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
  late String? id;
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
  late double unread;
  late bool invisible;
  late bool isExternalService;
  late String dataSource;
  late Map<dynamic, dynamic> externalServiceData;

  List<HexabaseField>? _fields;

  HexabaseDatastore({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseDatastore sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseDatastore set(String key, dynamic value) {
    switch (key) {
      case 'd_id':
      case 'datastore_id':
        id = value as String;
        break;
      /*
      case 'display_id':
        displayId = value as String;
        break;
      case 'deleted':
        deleted = value as bool;
        break;
      case 'imported':
        imported = value as bool;
        break;
      case 'uploading':
        uploading = value as bool;
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
      case 'show_in_menu':
        showInMenu = value as bool;
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
      case 'no_status':
        noStatus = value as bool;
        break;
      case 'display_order':
        displayOrder = value as int;
        break;
      case 'unread':
        unread = value as double;
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
        externalServiceData = value as Map;
        break;
      */
      case 'name':
        if (value is String) {
          _name = {'ja': value, 'en': value};
        } else {
          _name = value as Map<String, String>;
        }
        break;
      case '__typename':
        break;
    }
    return this;
  }

  HexabaseDatastore name(String language, String name) {
    if (!['ja', 'en'].contains(language)) {
      throw Exception('Language must be ja or en');
    }
    _name ??= {};
    _name![language] = name;
    return this;
  }

  Future<HexabaseDatastore> save({templateName = 'SEED1', lang = 'ja'}) async {
    if (id == null) {
      await create(templateName, lang);
      await HexabaseDatastore.all(project!);
      return await project!.datastore(id: id);
    } else {
      await update();
    }
    return this;
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
    if (id == null) {
      throw Exception('Datastore id is not set');
    }
    final response =
        await HexabaseBase.query(GRAPHQL_GET_DATASTORE, variables: {
      'datastoreId': id,
    });
    if (response.data != null) {
      sets(response.data as Map<String, dynamic>);
      return true;
    }
    return false;
  }

  static HexabaseDatastore fromJson(
      HexabaseProject project, Map<String, dynamic> json) {
    json['project'] = project;
    return HexabaseDatastore(params: json);
  }

  Future<HexabaseDatastore> create(String templateName, String lang) async {
    var user = await HexabaseUser.getCurrentUser();
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
    var res = await HexabaseItem.all(this, query, project!);
    return res.item2;
  }

  HexabaseItem item() {
    return HexabaseItem(datastore: this, project: project);
  }

  Future<HBDataStoreResponseWithCount> itemsWithCount(
      {HexabaseItemsParameters? query}) async {
    query = _getParams(query);
    var res = await HexabaseItem.all(this, query, project);
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

  Future<List<HexabaseField>> fields() async {
    if (_fields != null) return _fields!;
    if (project == null) throw Exception('Project is required');
    var response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_GET_FIELDS, variables: {
      'projectId': project!.id,
      'datastoreId': displayId,
    });
    var fields =
        response.data!['datastoreGetFields']['fields'] as Map<String, dynamic>;
    _fields = fields.entries
        .map((data) =>
            HexabaseField.fromJson(this, data.value as Map<String, dynamic>))
        .toList();
    return _fields!;
  }

  HexabaseField field() {
    return HexabaseField(this);
  }

  Future<List<HexabaseFieldResult>> searchConditions() async {
    var res = await HexabaseSearchCondition.all(project!, this);
    return res;
  }
}
