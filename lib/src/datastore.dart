import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/field_result.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:hexabase/src/search_condition.dart';
import 'package:hexabase/src/graphql.dart';

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

  HexabaseDatastore({this.id, this.project}) : super();

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
    } else {
      await update();
    }
    return this;
  }

  Future<HexabaseDatastore> create(String templateName, String lang) async {
    var user = await HexabaseUser.getCurrentUser();
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

  Future<List<HexabaseFieldResult>> searchConditions() async {
    var res = await HexabaseSearchCondition.all(project!, this);
    return res;
  }
}
