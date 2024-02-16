import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/field.dart';
import 'package:hexabase/src/field_option.dart';

class HexabaseDataTypeRadio extends HexabaseDataType {
  HexabaseDataTypeRadio(HexabaseField field) : super(field) {
    field = field;
    name = 'radio';
    supportArray = false;
    savable = true;
  }

  @override
  bool valid(dynamic value) {
    if (value is String) return true;
    if (value == null) return true;
    var o = option(value);
    if (o != null) return true;
    return false;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) => option(value);

  @override
  Future<dynamic> jsonValue(dynamic value) async =>
      (value as HexabaseFieldOption).displayId;
}
