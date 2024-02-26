import './base.dart';
import 'package:hexabase/src/item.dart';
import 'package:hexabase/src/file.dart';

class HexabaseDataTypeFile extends HexabaseDataType {
  HexabaseDataTypeFile(field) : super(field) {
    field = field;
    name = 'file';
    supportArray = true;
    savable = true;
  }

  @override
  bool valid(dynamic value) {
    if (value == null) return true;
    if (value is String) {
      value = value.split(",");
    }
    if (value is List) {
      for (var params in value) {
        if (params is HexabaseFile) continue;
        if (params is String) continue;
        if (params is! Map) return false;
        if (!params.containsKey('contentType') ||
            !params.containsKey('file_id')) return false;
      }
      return true;
    }
    return false;
  }

  @override
  dynamic convert(dynamic value, HexabaseItem item) {
    if (value is String && value == '') {
      return null;
    }
    if (value is String) {
      value = value.split(",");
    }
    if (value is! List) throw Exception('Invalid file value for $value');
    return value.map((data) {
      if (data is HexabaseFile) return data;
      if (data is Map) {
        data = data as Map<String, dynamic>;
        data.addAll({'field': field, 'item': item});
        var file = HexabaseFile(params: data);
        return file;
      }
      if (data is String) {
        return HexabaseFile(params: {
          'field': field,
          'item': item,
          'file_id': data,
        });
      }
      throw Exception('Invalid file data');
    }).toList();
  }

  @override
  Future<dynamic> jsonValue(dynamic value) async {
    List<String> ary = [];
    for (var v in value) {
      if (v is HexabaseFile) {
        if (v.id == '') {
          v.set('field', field);
          await v.save();
        }
        ary.add(v.id);
      } else if (v is String) {
        ary.add(v);
      } else {
        throw Exception('Invalid file value for ${field.name('en')}, $v');
      }
    }
    return ary;
  }
}
