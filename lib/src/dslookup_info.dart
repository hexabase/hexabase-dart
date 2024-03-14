// import 'package:collection/collection.dart';
// import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
// import 'package:hexabase/src/field_option.dart';
// import 'package:hexabase/src/graphql.dart';

class HexabaseDSLookupInfo extends HexabaseBase {
  late String dslookupFieldId;
  late String dslookupProjectId;
  late String dslookupDatastoreId;

  HexabaseDSLookupInfo({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseDSLookupInfo sets(Map<String, dynamic> params) {
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseDSLookupInfo set(String key, dynamic value) {
    switch (key) {
      case 'dslookup_field_id':
        dslookupFieldId = value as String;
        break;
      case 'dslookup_project_id':
        dslookupProjectId = value as String;
        break;
      case 'dslookup_datastore_id':
        dslookupDatastoreId = value as String;
        break;
      default:
        throw Exception("Invalid field name in HexabaseDSLookupInfo, $key");
    }
    return this;
  }
}
