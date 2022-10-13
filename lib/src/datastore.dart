import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/field_result.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:hexabase/src/search_condition.dart';
import 'package:tuple/tuple.dart';

class HBDataStoreResponseWithCount {
  final int count;
  final List<HexabaseItem> items;
  HBDataStoreResponseWithCount(this.count, this.items);
}

class HexabaseDatastore extends HexabaseBase {
  late String? id;
  late String? name;
  late String? projectId;
  HexabaseDatastore({this.id, this.projectId}) : super();

  Future<List<HexabaseItem>> items(HexabaseItemsParameters? params) async {
    params = _getParams(params);
    var res = await HexabaseItem.all(id!, params, projectId);
    return res.item2;
  }

  Future<HBDataStoreResponseWithCount> itemsWithCount(
      HexabaseItemsParameters? params) async {
    params = _getParams(params);
    var res = await HexabaseItem.all(id!, params, projectId);
    return HBDataStoreResponseWithCount(res.item1, res.item2);
  }

  HexabaseItemsParameters params() {
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
