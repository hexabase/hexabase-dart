import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/field.dart';

class HexabaseDataTypeText extends HexabaseDataType {
  HexabaseDataTypeText(HexabaseField field) : super(field) {
    field = field;
    name = 'text';
    supportArray = false;
    savable = true;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    return value is String;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    return value as String;
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async => value;
}
