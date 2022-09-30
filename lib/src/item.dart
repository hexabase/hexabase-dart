import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/items_parameter.dart';

class HexabaseItem extends HexabaseBase {
  late String? id;
  HexabaseItem({this.id}) : super();

  static Future<List<HexabaseItem>> all(String datastoreId,
      HexabaseItemsParameters params, String? projectId) async {
    final response = await HexabaseBase.query(
        GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS,
        variables: {
          'projectId': projectId,
          'datastoreId': datastoreId,
          'getItemsParameters': params.toJson()
        });
    print(response.data);
    return [HexabaseItem()].toList();
  }

  // Future<bool> save() {}
}
