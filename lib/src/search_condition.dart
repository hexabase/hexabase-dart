import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseSearchCondition extends HexabaseBase {
  HexabaseSearchCondition() : super();
  Map<String, dynamic> params = {};
  HexabaseSearchCondition seachValue(dynamic value) {
    params['search_condition'] = value;
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
    params['conditions'] = value;
    return this;
  }

  HexabaseSearchCondition useOrCondition(bool value) {
    params['use_or_condition'] = value;
    return this;
  }

  dynamic toJson() {
    var obj = params;
    if (params.containsKey('conditions')) {
      HexabaseSearchCondition condition = params['conditions'];
      obj['conditions'] = condition.toJson();
    }
    return obj;
  }
}
