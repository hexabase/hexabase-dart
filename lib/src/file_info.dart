import 'package:collection/collection.dart';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/field_option.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseFileInfo extends HexabaseBase {
  late HexabaseField field;
  late bool showImg;
  late bool openPublic;

  HexabaseFileInfo({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseFileInfo sets(Map<String, dynamic> params) {
    if (params.containsKey('field')) set('field', params['field']!);
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseFileInfo set(String key, dynamic value) {
    switch (key) {
      case 'field':
        field = value as HexabaseField;
        break;
      case 'show_img':
        showImg = value as bool;
        break;
      case 'open_public':
        openPublic = value as bool;
        break;
      default:
        throw Exception("Invalid field name in HexabaseFileInfo, $key");
    }
    return this;
  }
}
