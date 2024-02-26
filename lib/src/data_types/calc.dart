import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/field.dart';

class HexabaseDataTypeCalc extends HexabaseDataType {
  HexabaseDataTypeCalc(HexabaseField field) : super(field) {
    field = field;
    name = 'calc';
    supportArray = false;
    savable = false;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    if (value is int) return true;
    if (value is double) return true;
    if (RegExp(r'^[0-9\.]+$').hasMatch(value)) return true;
    return false;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    if (value is int) return value;
    if (value is double) return value;
    return double.parse(value);
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async => null;
}
