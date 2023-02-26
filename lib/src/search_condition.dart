import 'dart:async';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/field_result.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseSearchCondition extends HexabaseBase {
  HexabaseSearchCondition() : super();
  Map<String, dynamic> params = {};

  static Future<List<HexabaseFieldResult>> all(
      HexabaseProject project, HexabaseDatastore datastore) async {
    final response = await HexabaseBase.query(
        GRAPHQL_GET_ITEM_SEARCH_CONDITIONS,
        variables: {
          'projectId': project.id,
          'datastoreId': datastore.id,
        });
    if (response.data!['getItemSearchConditions']['has_error']) {
      throw Exception('Get item search conditions failed');
    }
    var conditions =
        response.data!['getItemSearchConditions']['result'] as List<Object?>;
    return conditions.map((params) {
      params = params as Map<String, dynamic>;
      var fieldResult = HexabaseFieldResult();
      fieldResult.set(params);
      return fieldResult;
    }).toList();
  }

  HexabaseSearchCondition? get(String id) {
    return id == params['id'] ? this : null;
  }

  HexabaseSearchCondition seachValue(dynamic value) {
    params['search_value'] = value;
    return this;
  }

  HexabaseSearchCondition dataType(String value) {
    params['data_type'] = value;
    return this;
  }

  HexabaseSearchCondition id(String value) {
    params['id'] = value;
    return this;
  }

  HexabaseSearchCondition rpfId(String value) {
    params['rpf_id'] = value;
    return this;
  }

  HexabaseSearchCondition exactMatch(bool value) {
    params['exact_match'] = value;
    return this;
  }

  HexabaseSearchCondition notMatch(bool value) {
    params['not_match'] = value;
    return this;
  }

  HexabaseSearchCondition includeNull(bool value) {
    params['include_null'] = value;
    return this;
  }

  HexabaseSearchCondition conditions(HexabaseSearchCondition value) {
    var ary = params.containsKey('conditions') ? params['conditions'] : [];
    ary.add(value);
    params['conditions'] = ary;
    return this;
  }

  HexabaseSearchCondition useOrCondition(bool value) {
    params['use_or_condition'] = value;
    return this;
  }

  dynamic toJson() {
    var obj = params;
    if (params.containsKey('conditions')) {
      List<HexabaseSearchCondition> conditions = params['conditions'];
      obj['conditions'] = conditions.map((c) => c.toJson());
    }
    return obj;
  }
}
