import './base.dart';
import 'package:hexabase/src/item.dart';

class HexabaseDataTypeStatus extends HexabaseDataType {
  HexabaseDataTypeStatus(field) : super(field) {
    field = field;
    name = 'status';
    supportArray = false;
    savable = true;
  }

  @override
  bool valid(dynamic value) => value is String;

  @override
  dynamic convert(dynamic value, HexabaseItem item) => value;

  @override
  Future<dynamic> jsonValue(dynamic value) async => null;
}
