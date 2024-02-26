import './base.dart';
import 'package:hexabase/src/item.dart';

class HexabaseDataTypeDSlookup extends HexabaseDataType {
  HexabaseDataTypeDSlookup(field) : super(field) {
    field = field;
    name = 'dslookup';
    supportArray = false;
    savable = true;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    if (value is String) return true;
    if (value is HexabaseItem) return true;
    if (value is Map) {
      if (value.containsKey('d_id') && value.containsKey('item_id')) {
        return true;
      }
    }
    return false;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    if (value is Map) {
      value = value as Map<String, dynamic>;
      var datastore = field.datastore.project!.datastoreSync(id: value['d_id']);
      var item = datastore.itemSync(id: value['item_id']);
      item.set('title', value['title']);
      return item;
    }
    return value;
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async {
    if (value is HexabaseItem) {
      return value.id;
    }
    return null;
  }
}
