import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:tuple/tuple.dart';

class HexabaseItem extends HexabaseBase {
  late String? id;
  late String? status;
  late String? statusId;
  late String? title;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late String? createdBy;
  late String? updatedBy;
  late String? dId;
  late String? iId;
  late String? pId;
  late int revNo;
  late int unread;
  final Map<String, dynamic> _fields = {};

  HexabaseItem({this.id}) : super();

  static Future<Tuple2<int, List<HexabaseItem>>> all(String datastoreId,
      HexabaseItemsParameters params, String? projectId) async {
    final response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS,
        variables: {
          'projectId': projectId,
          'datastoreId': datastoreId,
          'getItemsParameters': params.toJson()
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

  HexabaseItem set(String name, dynamic value) {
    switch (name.toLowerCase()) {
      case 'status':
        status = value as String?;
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
      case 'd_id':
        dId = value as String;
        break;
      case 'i_id':
        iId = value as String;
        break;
      case 'p_id':
        pId = value as String;
        break;
      case 'rev_no':
        revNo = int.parse(value);
        break;
      case 'title':
        title = value as String;
        break;
      case 'unread':
        unread = int.parse(value);
        break;
      default:
        _fields[name] = value;
    }
    return this;
  }

  dynamic get(String field) {
    if (_fields.containsKey(field)) {
      return _fields[field];
    }
    return null;
  }
  // Future<bool> save() {}
}
