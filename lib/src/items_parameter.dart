import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/search_condition.dart';

// TODO: Change to Enum
Enum sortOrderType = {'asc', 'desc'} as Enum;

class HexabaseItemsParameters extends HexabaseBase {
  Map<String, dynamic> conditions = {};
  HexabaseItemsParameters() : super();

  HexabaseItemsParameters or(bool bol) {
    conditions['use_or_condition'] = bol;
    return this;
  }

  HexabaseItemsParameters unreadOnly(bool bol) {
    conditions['unread_only'] = bol;
    return this;
  }

  HexabaseItemsParameters addSortFields(String id, String order) {
    Map<String, String> sortField = {id: order};
    if (!conditions.containsKey('sort_fields')) {
      conditions['sort_fields'] = [sortField];
    } else {
      // TODO: 追加
      // conditions['sort_fields']
    }
    return this;
  }

  HexabaseItemsParameters sortField(String field) {
    conditions['sort_field_id'] = field;
    return this;
  }

  HexabaseItemsParameters sortOrder(String sort) {
    conditions['sort_order'] = sort;
    return this;
  }

  HexabaseItemsParameters page(int page) {
    conditions['page'] = page;
    return this;
  }

  HexabaseItemsParameters per(int page) {
    conditions['per_page'] = page;
    return this;
  }

  HexabaseItemsParameters fieldId(bool bol) {
    conditions['use_field_id'] = bol;
    return this;
  }

  HexabaseItemsParameters displayId(bool bol) {
    conditions['use_display_id'] = bol;
    return this;
  }

  HexabaseItemsParameters link(bool bol) {
    conditions['include_links'] = bol;
    return this;
  }

  HexabaseItemsParameters include(bool bol) {
    conditions['include_lookups'] = bol;
    return this;
  }

  HexabaseItemsParameters number(bool bol) {
    conditions['return_number_value'] = bol;
    return this;
  }

  // TODO: Change to enum
  HexabaseItemsParameters format(String format) {
    conditions['format'] = format;
    return this;
  }

  HexabaseItemsParameters count({bool bol = true}) {
    conditions['return_count_only'] = bol;
    return this;
  }

  HexabaseItemsParameters omitFieldsData(bool bol) {
    conditions['omit_fields_data'] = bol;
    return this;
  }

  HexabaseItemsParameters omitTotalItems(bool bol) {
    conditions['omit_total_items'] = bol;
    return this;
  }

  HexabaseItemsParameters resultTimeout(int sec) {
    conditions['data_result_timeout_sec'] = sec;
    return this;
  }

  HexabaseItemsParameters timeout(int sec) {
    conditions['total_count_timeout_sec'] = sec;
    return this;
  }

  HexabaseItemsParameters debug(bool bol) {
    conditions['debug_query'] = bol;
    return this;
  }

  HexabaseItemsParameters select(List<String> fields) {
    conditions['select_fields'] = fields;
    return this;
  }

  HexabaseItemsParameters selectFieldsLookup(dynamic obj) {
    conditions['select_fields_lookup'] = obj;
    return this;
  }

  HexabaseItemsParameters match(HexabaseSearchCondition search) {
    conditions['conditions'] = [search];
    return this;
  }

  dynamic toJson() {
    var obj = conditions;
    if (conditions.containsKey('conditions')) {
      obj['conditions'] = conditions['conditions']
          .map((HexabaseSearchCondition search) => search.toJson());
    }
    return obj;
  }
}
