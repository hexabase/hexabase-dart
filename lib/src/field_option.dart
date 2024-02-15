import 'package:collection/collection.dart';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/field.dart';

class HexabaseFieldOption extends HexabaseBase {
  late HexabaseField field;
  String? id;
  late int sortId;
  late String value;
  late bool enabled;
  late String color;
  late String displayId;

  HexabaseFieldOption({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseFieldOption sets(Map<String, dynamic> params) {
    if (params.containsKey('field')) set('field', params['field']!);
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseFieldOption set(String key, dynamic value) {
    switch (key) {
      case 'field':
        field = value as HexabaseField;
        break;
      case 'option_id':
        id = value as String;
        break;
      case 'sort_id':
        sortId = value as int;
        break;
      case 'value':
        this.value = value as String;
        break;
      case 'enabled':
        enabled = value as bool;
        break;
      case 'color':
        color = value as String;
        break;
      case 'display_id':
        displayId = value as String;
        break;
      case '__typename':
        break;
      default:
        throw Exception("Invalid field name in HexabaseFieldOption, $key");
    }
    return this;
  }
}
