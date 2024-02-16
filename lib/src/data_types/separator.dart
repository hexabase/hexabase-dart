import './base.dart';
import 'package:hexabase/src/item.dart';

class HexabaseDataTypeSeparator extends HexabaseDataType {
  HexabaseDataTypeSeparator(field) : super(field) {
    field = field;
    name = 'separator';
    supportArray = false;
    savable = false;
  }

  @override
  bool valid(dynamic value) => true;

  @override
  dynamic convert(dynamic value, HexabaseItem item) => value;

  @override
  Future<dynamic> jsonValue(dynamic value) async => null;
}
