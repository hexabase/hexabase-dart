import 'package:collection/collection.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/item.dart';

class HexabaseItemAction extends HexabaseBase {
  late HexabaseItem item;
  late String? name;
  late String? id;
  late String? actionId;
  // final String? idLabel;
  // final String? nameLabel;
  // final String? description;
  late int? crudType;
  late String? nextStatusId;
  late int? displayOrder;

  HexabaseItemAction({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseItemAction sets(Map<String, dynamic> params) {
    if (params.containsKey('item')) set('item', params['item']!);
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseItemAction set(String key, dynamic value) {
    switch (key) {
      case 'item':
        item = value as HexabaseItem;
        break;
      case 'action_id':
        actionId = value as String;
        break;
      case 'a_id':
        id = value as String;
        break;
      case 'action_name':
        name = value as String;
        break;
      case 'display_order':
        displayOrder = value;
        break;
      case 'crud_type':
        crudType = int.parse(value);
        break;
      case 'next_status_id':
        nextStatusId = value as String;
        break;
      default:
        throw Exception("Invalid field name in HexabaseItemAction, $key");
    }
    return this;
  }
}
