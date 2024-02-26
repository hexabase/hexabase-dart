import './base.dart';
import 'package:hexabase/src/item.dart';

class HexabaseDataTypeDatetime extends HexabaseDataType {
  HexabaseDataTypeDatetime(field) : super(field) {
    field = field;
    name = 'datetime';
    supportArray = false;
    savable = true;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    if (value is DateTime) return true;
    try {
      DateTime.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    if (value is DateTime) return value;
    return DateTime.parse(value);
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async =>
      (value as DateTime).toIso8601String();
}
