import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/search_condition.dart';
import 'package:collection/collection.dart';

// TODO: Change to Enum
Enum sortOrderType = {'asc', 'desc'} as Enum;

class HexabaseItemsParameters extends HexabaseBase {
  final Map<String, dynamic> _conditions = {};
  HexabaseItemsParameters() : super();
  final List<HexabaseSearchCondition> _searchConditions = [];

  void clear() {
    _conditions.clear();
    _searchConditions.clear();
  }

  HexabaseItemsParameters or(bool bol) {
    _conditions['use_or_condition'] = bol;
    return this;
  }

  HexabaseItemsParameters unreadOnly(bool bol) {
    _conditions['unread_only'] = bol;
    return this;
  }

  HexabaseItemsParameters addSortFields(String id, String order) {
    Map<String, String> sortField = {id: order};
    if (!_conditions.containsKey('sort_fields')) {
      _conditions['sort_fields'] = [sortField];
    } else {
      // TODO: 追加
      // _conditions['sort_fields']
    }
    return this;
  }

  HexabaseItemsParameters sortField(String field) {
    _conditions['sort_field_id'] = field;
    return this;
  }

  HexabaseItemsParameters sortOrder(String sort) {
    _conditions['sort_order'] = sort;
    return this;
  }

  HexabaseItemsParameters page(int page) {
    _conditions['page'] = page;
    return this;
  }

  HexabaseItemsParameters per(int page) {
    _conditions['per_page'] = page;
    return this;
  }

  HexabaseItemsParameters fieldId(bool bol) {
    _conditions['use_field_id'] = bol;
    return this;
  }

  HexabaseItemsParameters displayId(bool bol) {
    _conditions['use_display_id'] = bol;
    return this;
  }

  HexabaseItemsParameters link(bool bol) {
    _conditions['include_links'] = bol;
    return this;
  }

  HexabaseItemsParameters include(bool bol) {
    _conditions['include_lookups'] = bol;
    return this;
  }

  HexabaseItemsParameters number(bool bol) {
    _conditions['return_number_value'] = bol;
    return this;
  }

  // TODO: Change to enum
  HexabaseItemsParameters format(String format) {
    _conditions['format'] = format;
    return this;
  }

  HexabaseItemsParameters count({bool bol = true}) {
    _conditions['return_count_only'] = bol;
    return this;
  }

  HexabaseItemsParameters omitFieldsData(bool bol) {
    _conditions['omit_fields_data'] = bol;
    return this;
  }

  HexabaseItemsParameters omitTotalItems(bool bol) {
    _conditions['omit_total_items'] = bol;
    return this;
  }

  HexabaseItemsParameters resultTimeout(int sec) {
    _conditions['data_result_timeout_sec'] = sec;
    return this;
  }

  HexabaseItemsParameters timeout(int sec) {
    _conditions['total_count_timeout_sec'] = sec;
    return this;
  }

  HexabaseItemsParameters debug(bool bol) {
    _conditions['debug_query'] = bol;
    return this;
  }

  HexabaseItemsParameters select(List<String> fields) {
    _conditions['select_fields'] = fields;
    return this;
  }

  HexabaseItemsParameters selectFieldsLookup(dynamic obj) {
    _conditions['select_fields_lookup'] = obj;
    return this;
  }

  HexabaseItemsParameters conditions(HexabaseSearchCondition search) {
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters equalTo(String field, dynamic value) {
    var search = HexabaseSearchCondition();
    value = _changeValue(value);
    search.id(field).seachValue([value]).exactMatch(true);
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters notEqualTo(String field, dynamic value) {
    var search = HexabaseSearchCondition();
    value = _changeValue(value);
    search.id(field).seachValue([value]).exactMatch(true).notMatch(true);
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters inArray(String field, List<dynamic> value) {
    var search = HexabaseSearchCondition();
    value = value.map((e) => _changeValue(e)).toList();
    search.id(field).seachValue(value).exactMatch(true);
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters notInArray(String field, List<dynamic> value) {
    var search = HexabaseSearchCondition();
    value = value.map((e) => _changeValue(e)).toList();
    search.id(field).seachValue(value).exactMatch(true).notMatch(true);
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters greaterThan(String field, dynamic value) {
    if (!(value is DateTime || value is int)) {
      throw 'value must be DateTime or int';
    }
    if (value is DateTime) {
      value = value.add(const Duration(seconds: 1));
    }
    if (value is int) {
      value = value + 1;
    }
    var search = HexabaseSearchCondition();
    value = _changeValue(value);
    search.id(field).seachValue([value, null]).exactMatch(false);
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters lessThan(String field, dynamic value) {
    if (!(value is DateTime || value is int)) {
      throw 'value must be DateTime or int';
    }
    if (value is DateTime) {
      value = value.subtract(const Duration(seconds: 1));
    }
    if (value is int) {
      value = value - 1;
    }
    var search = HexabaseSearchCondition();
    value = _changeValue(value);
    search.id(field).seachValue([null, value]).exactMatch(false);
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters greaterThanOrEqualTo(String field, dynamic value) {
    var search = HexabaseSearchCondition();
    value = _changeValue(value);
    search.id(field).seachValue([value, null]).exactMatch(false);
    _searchConditions.add(search);
    return this;
  }

  HexabaseItemsParameters lessThanOrEqualTo(String field, dynamic value) {
    var search = HexabaseSearchCondition();
    value = _changeValue(value);
    search.id(field).seachValue([null, value]).exactMatch(false);
    _searchConditions.add(search);
    return this;
  }

  String _changeValue(dynamic value) {
    if (value is DateTime) {
      value = value.toIso8601String();
    } else {
      value = value.toString();
    }
    return value;
  }

  dynamic toJson() {
    var obj = _conditions;
    var params = {'page': 1, 'per_page': 0, 'use_display_id': true};
    params.forEach((key, value) {
      if (!obj.containsKey(key)) {
        obj[key] = params[key];
      }
    });
    if (_searchConditions.isNotEmpty) {
      obj['conditions'] = _searchConditions.map((search) {
        return search.toJson();
      }).toList();
    }
    return obj;
  }
}
