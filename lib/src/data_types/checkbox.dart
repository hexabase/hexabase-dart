import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/field_option.dart';

class HexabaseDataTypeCheckbox extends HexabaseDataType {
  HexabaseDataTypeCheckbox(field) : super(field) {
    field = field;
    name = 'checkbox';
    supportArray = true;
    savable = true;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    if (value is List) {
      for (var element in value) {
        var o = option(element);
        if (o == null) return false;
      }
      return true;
    }
    return false;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    if (value is! List) {
      throw Exception('Invalid checkbox value for ${field.name('en')}, $value');
    }
    return super.options(value: value);
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async {
    return (value as List)
        .map((v) => (v as HexabaseFieldOption).displayId)
        .toList();
  }
}
