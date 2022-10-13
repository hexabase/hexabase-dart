import 'dart:async';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';

class HexabaseFieldResult extends HexabaseBase {
  HexabaseFieldResult() : super();
  late String id;
  late String name;
  late String? displayId;
  late String? dataType;
  late String? maxValue;
  late String? minValue;
  late int? order;
  late String? usersInfo;
  late Map<String, String> dsLookupInfo = {};
  late List<Map<String, dynamic>> options = [];
  late List<Map<String, String?>> status = [];

  HexabaseFieldResult addOptions(
      {String? id, int? sortId, String? value, bool? enabled, String? color}) {
    options.add({
      'option_id': id,
      'sort_id': sortId,
      'value': value,
      'enabled': enabled,
      'color': color
    });
    return this;
  }

  HexabaseFieldResult addStatus({String? id, String? name}) {
    status.add({'id': id, 'name': name});
    return this;
  }

  void set(Map<String, dynamic> params) {
    id = params['f_id'];
    name = params['name'];
    displayId = params['display_id'];
    dataType = params['data_type'];
    maxValue = params['max_value'];
    minValue = params['min_value'];
    order = params['order'];
    usersInfo = params['user_info'];
    if (params['ds_lookup_info'] != null) {
      dsLookupInfo = params['ds_lookup_info'];
    }
    if (params['options'] != null) {
      var options = params['options'] as List<Object?>;
      for (var option in options) {
        option = option as Map<String, dynamic>;
        addOptions(
            id: option['option_id'],
            sortId: option['sort_id'],
            value: option['value'],
            enabled: option['enabled'],
            color: option['color']);
      }
    }
    if (params['statuses'] != null) {
      var statuses = params['statuses'] as List<Object?>;
      for (var status in statuses) {
        status = status as Map<String, dynamic>;
        addStatus(id: status['status_id'], name: status['name']);
      }
    }
  }
}
