import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/user.dart';
import 'package:hexabase/src/field.dart';

class HexabaseDataTypeUsers extends HexabaseDataType {
  HexabaseDataTypeUsers(HexabaseField field) : super(field) {
    field = field;
    name = 'users';
    supportArray = true;
    savable = true;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    if (value is List) {
      for (var params in value) {
        if (params is! Map) return false;
        if (!params.containsKey('user_name') ||
            !params.containsKey('user_id')) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    if (value is! List) {
      throw Exception('Invalid users value for ${field.name('en')}, $value');
    }
    return users(value);
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async =>
      (value as List).map((v) => (v as HexabaseUser).id).toList();
}
