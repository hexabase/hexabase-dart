import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

enum HexabaseFieldType {
  text,
  textarea,
  select,
  radio,
  checkbox,
  autonum,
  number,
  calc,
  datetime,
  file,
  users,
  dslookup,
  label,
  separator,
}

class HexabaseField extends HexabaseBase {
  final HexabaseDatastore datastore;
  String? id;
  final Map<String, String> _name = {};

  late String displayId;
  late HexabaseFieldType dataType;
  late bool status;
  late int fieldIndex;
  late int titleOrder;
  bool search = true;
  bool showList = true;
  bool asTitlte = false;
  bool fullText = false;
  bool unique = false;
  bool hideFromApi = false;
  bool hasIndex = false;
  late String minValue;
  late String maxValue;

  HexabaseField(this.datastore) : super();

  HexabaseField name(String language, String name) {
    if (!['ja', 'en'].contains(language)) {
      throw Exception('Language must be ja or en');
    }
    _name[language] = name;
    return this;
  }

  Future<bool> save() async {
    if (id == null) return create();
    return update();
  }

  Future<bool> create() async {
    print(showList);
    var payload = {
      'name': _name,
      // 'displayid': displayId,
      'dataType': dataType.toString().split('.').last,
      'search': search,
      'show_list': showList,
      'as_title': asTitlte,
      'full_text': fullText,
      'hide_from_api': hideFromApi,
      'has_index': hasIndex,
      'roles': ['ADMIN'],
    };
    var response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_CREATE_FIELD, variables: {
      'payload': payload,
      'datastoreId': datastore.id,
    });
    id = response.data!['datastoreCreateField']['field_id'] as String;
    return true;
  }

  Future<bool> update() async {
    return true;
  }

  static HexabaseField fromJson(
      HexabaseDatastore datastore, Map<String, dynamic> json) {
    final field = HexabaseField(datastore);
    field.id = json['field_id'] as String;
    field.displayId = json['display_id'] as String;
    field.dataType = HexabaseFieldType.values.firstWhere(
        (e) => e.toString() == json['dataType'] as String,
        orElse: () => HexabaseFieldType.text);
    field.search = json['search'] as bool;
    field.showList = json['show_list'] as bool;
    field.asTitlte = json['as_title'] as bool;
    field.status = json['status'] as bool;
    field.fieldIndex = json['fieldIndex'] as int;
    field.titleOrder = json['title_order'] as int;
    field.fullText = json['full_text'] as bool;
    field.unique = json['unique'] as bool;
    field.hideFromApi = json['hide_from_api'] as bool;
    field.hasIndex = json['has_index'] as bool;
    field.minValue = json['min_value'] as String;
    field.maxValue = json['max_value'] as String;
    return field;
  }
}
