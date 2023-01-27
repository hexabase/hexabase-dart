import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/field_result.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:hexabase/src/search_condition.dart';

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
  late String? name;
  late String? projectId;
  HexabaseDatastore({this.id, this.projectId}) : super();

  Future<List<HexabaseItem>> items({HexabaseItemsParameters? query}) async {
    query = _getParams(query);
    var res = await HexabaseItem.all(id!, query, projectId);
    return res.item2;
  }

  HexabaseItem item() {
    return HexabaseItem(datastoreId: id, projectId: projectId);
  }

  Future<HBDataStoreResponseWithCount> itemsWithCount(
      {HexabaseItemsParameters? query}) async {
    query = _getParams(query);
    var res = await HexabaseItem.all(id!, query, projectId);
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
    var res = await HexabaseItem.search(id!, type, query, params,
        projectId: projectId, fieldId: fieldId);
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
    var res = await HexabaseSearchCondition.all(projectId!, id!);
    return res;
  }
}
