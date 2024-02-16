import 'package:collection/collection.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/field.dart';
import 'package:hexabase/src/user.dart';
import 'package:hexabase/src/field_option.dart';
import './text.dart';
import './users.dart';
import './status.dart';
import './select.dart';
import './radio.dart';
import './textarea.dart';
import './number.dart';
import './separator.dart';
import './label.dart';
import './file.dart';
import './dslookup.dart';
import './checkbox.dart';
import './datetime.dart';
import './autonum.dart';
import './calc.dart';

class HexabaseDataType {
  late String name = '';
  late bool supportArray = false;
  late bool savable = false;
  final HexabaseField field;
  HexabaseDataType(this.field);

  static HexabaseDataType? find(String name, HexabaseField field) {
    List<HexabaseDataType> ary = [
      HexabaseDataTypeText(field),
      HexabaseDataTypeTextarea(field),
      HexabaseDataTypeSelect(field),
      HexabaseDataTypeRadio(field),
      HexabaseDataTypeCheckbox(field),
      HexabaseDataTypeAutonum(field),
      HexabaseDataTypeNumber(field),
      HexabaseDataTypeCalc(field),
      HexabaseDataTypeDatetime(field),
      HexabaseDataTypeFile(field),
      HexabaseDataTypeUsers(field),
      HexabaseDataTypeDSlookup(field),
      HexabaseDataTypeLabel(field),
      HexabaseDataTypeSeparator(field),
      HexabaseDataTypeStatus(field),
    ];
    return ary.firstWhereOrNull((element) => element.name == name);
  }

  bool valid(dynamic value) => true;
  dynamic convert(dynamic value, HexabaseItem item) => value;
  Future<dynamic> jsonValue(dynamic value) async => value;

  HexabaseFieldOption? option(dynamic value) {
    if (value == null) return null;
    if (value is HexabaseFieldOption) return value;
    return field.options.firstWhereOrNull((option) =>
        option.value == value ||
        option.displayId == value ||
        option.id == value);
  }

  List<HexabaseFieldOption?> options({List<dynamic>? value}) {
    if (value == null) return field.options;
    return value.map((v) => option(v)).toList();
  }

  HexabaseUser? user(dynamic value) {
    if (value == null) return null;
    if (value is HexabaseUser) return value;
    if (value is Map) {
      value = value as Map<String, dynamic>;
      return HexabaseUser(params: value);
    }
    throw Exception('Invalid user value for ${field.name('en')}, $value');
  }

  List<HexabaseUser?> users(List<dynamic> value) {
    return value.map((v) => user(v)).toList();
  }
}
