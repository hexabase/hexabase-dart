import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/field.dart';

class HexabaseDataTypeTextarea extends HexabaseDataType {
  HexabaseDataTypeTextarea(HexabaseField field) : super(field) {
    field = field;
    name = 'textarea';
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
