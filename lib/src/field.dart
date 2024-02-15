import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/dslookup_info.dart';
import 'package:hexabase/src/field_option.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/file_info.dart';

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
  status,
}

class HexabaseField extends HexabaseBase {
  late HexabaseDatastore datastore;
  String? id;
  late Map<String, String> _name = {};

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
  late List<HexabaseFieldOption> _options;
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
        var d = HexabaseFieldType.values.firstWhereOrNull(
            (e) => e.toString().split('.').last == value as String);
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
        _options = (value as List<dynamic>).map((params) {
          (params as Map<String, dynamic>).addAll({'field': this});
          return HexabaseFieldOption(params: params);
        }).toList();
        // options = value as List<String>;
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
    switch (dataType) {
      case HexabaseFieldType.text:
      case HexabaseFieldType.textarea:
      case HexabaseFieldType.autonum:
        if (value == null) return true;
        return value is String;
      case HexabaseFieldType.calc:
      case HexabaseFieldType.number:
        if (value == null) return true;
        if (value is int) return true;
        if (value is double) return true;
        if (RegExp(r'^[0-9\.]+$').hasMatch(value)) return true;
        break;
      case HexabaseFieldType.datetime:
        if (value == null) return true;
        if (value is DateTime) return true;
        try {
          DateTime.parse(value);
          return true;
        } catch (e) {
          return false;
        }
      case HexabaseFieldType.select:
      case HexabaseFieldType.radio:
        if (value is String) return true;
        if (value == null) return true;
        var o = option(value);
        if (o != null) return true;
        break;
      case HexabaseFieldType.checkbox:
        if (value is List) {
          for (var element in value) {
            if (element is! String) return false;
          }
          return true;
        }
        break;
      case HexabaseFieldType.file:
        if (value == null) return true;
        if (value is List) {
          for (var params in value) {
            if (params is! Map) return false;
            if (!params.containsKey('contentType') ||
                !params.containsKey('file_id')) return false;
          }
          return true;
        }
        break;
      case HexabaseFieldType.users:
        if (value == null) return true;
        if (value is List) {
          for (var params in value) {
            if (params is! Map) return false;
            if (!params.containsKey('user_name') ||
                !params.containsKey('user_id')) {
              return false;
            }
          }
          return true;
        }
        break;
      case HexabaseFieldType.dslookup:
        if (value == null) return true;
        if (value is Map) {
          if (value.containsKey('d_id') && value.containsKey('item_id')) {
            return true;
          }
        }
        break;
      case HexabaseFieldType.label:
      case HexabaseFieldType.separator:
        return true;
      case HexabaseFieldType.status:
        if (value is String) return true;
        break;
    }
    return false;
  }

  dynamic convert(dynamic value, HexabaseItem item) {
    if (value == null) return null;
    switch (dataType) {
      case HexabaseFieldType.file:
        if (value is List) {
          var files = value.map((data) {
            if (data is HexabaseFile) return data;
            if (data is Map) {
              data = data as Map<String, dynamic>;
              data.addAll({'field': this, 'item': item});
              var file = HexabaseFile(params: data);
              return file;
            } else {
              throw Exception('Invalid file data');
            }
          }).toList();
          return files;
        }
        break;
      case HexabaseFieldType.text:
      case HexabaseFieldType.textarea:
      case HexabaseFieldType.autonum:
        return value as String;
      case HexabaseFieldType.calc:
      case HexabaseFieldType.number:
        if (value is int) return value;
        if (value is double) return value;
        return double.parse(value);
      case HexabaseFieldType.datetime:
        if (value is DateTime) return value;
        return DateTime.parse(value);
      case HexabaseFieldType.select:
      case HexabaseFieldType.radio:
        return option(value);
      case HexabaseFieldType.checkbox:
        if (value is! List) {
          throw Exception('Invalid checkbox value for ${name('en')}, $value');
        }
        return options(value);
      case HexabaseFieldType.users:
        if (value is! List) {
          throw Exception('Invalid users value for ${name('en')}, $value');
        }
        return users(value);
      case HexabaseFieldType.dslookup:
        if (value is Map) {
          value = value as Map<String, dynamic>;
          var datastore =
              this.datastore.project!.datastoreSync(id: value['d_id']);
          var item = datastore.itemSync(id: value['item_id']);
          item.set('title', value['title']);
          return item;
        }
        break;
      case HexabaseFieldType.status:
      case HexabaseFieldType.label:
      case HexabaseFieldType.separator:
        return value;
    }
  }

  HexabaseFieldOption? option(dynamic value) {
    if (value == null) return null;
    if (value is HexabaseFieldOption) return value;
    return _options.firstWhereOrNull((option) =>
        option.value == value ||
        option.displayId == value ||
        option.id == value);
  }

  List<HexabaseFieldOption?> options(List<dynamic> value) {
    return value.map((v) => option(v)).toList();
  }

  HexabaseUser? user(dynamic value) {
    if (value == null) return null;
    if (value is HexabaseUser) return value;
    if (value is Map) {
      value = value as Map<String, dynamic>;
      return HexabaseUser(params: value);
    }
    throw Exception('Invalid user value for ${name('en')}, $value');
  }

  List<HexabaseUser?> users(List<dynamic> value) {
    return value.map((v) => user(v)).toList();
  }

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
