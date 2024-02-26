import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseStatus extends HexabaseBase {
  late String id;
  late String displayId;
  late Map<String, String> names = {};
  late HexabaseDatastore datastore;

  HexabaseStatus({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseStatus sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseStatus set(String key, dynamic value) {
    switch (key) {
      case 'datastore':
        datastore = value as HexabaseDatastore;
        break;
      case 'names':
        if (value is String) {
          names = {
            'ja': value,
            'en': value,
          };
          break;
        } else {
          (value as Map<String, dynamic>).forEach((key, value) {
            names[key] = value as String;
          });
        }
        break;
      case 'id':
        id = value as String;
        break;
      case 'display_id':
        displayId = value as String;
        break;
      case '__typename':
        break;
      default:
        throw Exception("Invalid field name in HexabaseStatus, $key");
    }
    return this;
  }
}
