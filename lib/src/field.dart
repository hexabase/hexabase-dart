import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/dslookup_info.dart';
import 'package:hexabase/src/field_option.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/file_info.dart';
import 'package:hexabase/src/data_types/base.dart';

class HexabaseField extends HexabaseBase {
  late HexabaseDatastore datastore;
  String? id;
  late Map<String, String> _name = {};

  late String displayId;
  late HexabaseDataType dataType;
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
  late List<HexabaseFieldOption> options;
  late HexabaseFileInfo fileInfo;
  late HexabaseDSLookupInfo dslookupInfo;

  HexabaseField({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseField sets(Map<String, dynamic> params) {
    if (params.containsKey('datastore')) set('datastore', params['datastore']!);
    params.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseField set(String key, dynamic value) {
    switch (key) {
      case 'datastore':
        datastore = value as HexabaseDatastore;
        break;
      case 'as_title':
        asTitlte = value as bool;
        break;
      case 'dataType':
      case 'data_type':
        var d = HexabaseDataType.find(value as String, this);
        if (d == null) {
          throw Exception('Invalid data type $value');
        }
        dataType = d;
        break;
      case 'display_id':
        displayId = value as String;
        break;
      case 'display_name':
      case 'names':
      case 'name':
        if (value is String) {
          _name['ja'] = value;
          _name['en'] = value;
        } else {
          (value as Map<String, dynamic>).forEach((key, value) {
            _name[key] = value as String;
          });
        }
        break;
      case 'fieldIndex':
      case 'field_index':
        fieldIndex = value as int;
        break;
      case 'full_text':
        fullText = value as bool;
        break;
      case 'id':
      case 'field_id':
        id = value as String;
        break;
      case 'max_value':
        if (value != null) {
          maxValue = value as String;
        }
        break;
      case 'min_value':
        if (value != null) {
          minValue = value as String;
        }
        break;
      case 'options':
        if (value == null) break;
        options = (value as List<dynamic>).map((params) {
          (params as Map<String, dynamic>).addAll({'field': this});
          return HexabaseFieldOption(params: params);
        }).toList();
        break;
      case 'search':
        search = value as bool;
        break;
      case 'show_list':
        showList = value as bool;
        break;
      case 'status':
        status = value as bool;
        break;
      case 'title_order':
        titleOrder = value as int;
        break;
      case 'unique':
        unique = value as bool;
        break;
      case 'hide_from_api':
        hideFromApi = value as bool;
        break;
      case 'has_index':
        hasIndex = value as bool;
        break;
      case '__typename':
      case 'workspace_id':
      case 'project_id':
      case 'datastore_id':
        break;
      case 'file_info':
        fileInfo = HexabaseFileInfo(params: value as Map<String, dynamic>);
        break;
      case 'dslookup_info':
        dslookupInfo =
            HexabaseDSLookupInfo(params: value as Map<String, dynamic>);
        break;
      default:
        throw Exception("Invalid field name in HexabaseField, $key and $value");
    }
    return this;
  }

  String? name(String language) {
    if (!['ja', 'en'].contains(language)) {
      throw Exception('Language must be ja or en');
    }
    return _name[language];
  }

  bool valid(dynamic value) {
    return dataType.valid(value);
  }

  bool supportArray() => dataType.supportArray;

  dynamic convert(dynamic value, HexabaseItem item) {
    if (!valid(value)) {
      throw Exception('Invalid value for ${name('en')}, $value');
    }
    if (value == null) return null;
    return dataType.convert(value, item);
  }

  Future<dynamic> jsonValue(dynamic value) async {
    if (!valid(value)) {
      throw Exception('Invalid value for ${name('en')}, $value');
    }
    if (value == null) return null;
    return dataType.jsonValue(value);
  }

  bool savable() => dataType.savable;

  Future<bool> save() async {
    if (id == null) return create();
    return update();
  }

  Future<bool> create() async {
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

  static Future<List<HexabaseField>> all(HexabaseDatastore datastore) async {
    var response =
        await HexabaseBase.mutation(GRAPHQL_DATASTORE_GET_FIELDS, variables: {
      'projectId': datastore.project!.id,
      'datastoreId': datastore.id,
    });
    var fields =
        response.data!['datastoreGetFields']['fields'] as Map<String, dynamic>;
    return fields.entries.map((data) {
      (data.value as Map<String, dynamic>).addAll({'datastore': datastore});
      return HexabaseField(params: data.value);
    }).toList();
  }
}
