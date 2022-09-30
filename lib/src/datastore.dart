import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/items_parameter.dart';

class HexabaseDatastore extends HexabaseBase {
  late String? id;
  late String? name;
  late String? projectId;
  HexabaseDatastore({this.id, this.projectId}) : super();

  Future<List<HexabaseItem>> items({HexabaseItemsParameters? params}) {
    if (params == null) {
      params = HexabaseItemsParameters();
      params.per(0).page(1);
    }
    return HexabaseItem.all(id!, params, projectId);
  }
}
