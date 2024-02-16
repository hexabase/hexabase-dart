import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/field.dart';

class HexabaseDataTypeAutonum extends HexabaseDataType {
  HexabaseDataTypeAutonum(HexabaseField field) : super(field) {
    field = field;
    name = 'autonum';
    supportArray = false;
    savable = false;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    if (RegExp(r'^[0-9]+$').hasMatch(value)) return true;
    return false;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    return value as String;
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async => value;
}
