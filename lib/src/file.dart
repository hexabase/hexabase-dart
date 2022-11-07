import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
import 'package:hexabase/src/item_action.dart';
import 'package:hexabase/src/items_parameter.dart';
import 'package:tuple/tuple.dart';
import 'package:eventsource/eventsource.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
// import "package:http/browser_client.dart";

class HexabaseFile extends HexabaseBase {
  late String? id;
  late String? name;
  late File? file;
  late String? fieldId;
  late HexabaseItem? item;

  HexabaseFile({this.id, this.name, this.fieldId, this.file, this.item})
      : super();

  Future<bool> save() {
    if (id == null) {
      return create();
    } else {
      return update();
    }
  }

  String _getUrl() {
    if (fieldId != null && item != null) {
      return '/api/v0/items/${item!.id}/fields/$fieldId/attachments';
    } else {
      return '/api/v0/files';
    }
  }

  Future<bool> create() async {
    var payload = {
      'filename': name,
      'contentTypeFile': lookupMimeType(file!.path),
      'content': base64.encode(file!.readAsBytesSync()),
      'field_id': fieldId,
      'item_id': item!.id,
      'filepath': file!.path,
      'd_id': item!.datastoreId,
      'p_id': item!.projectId,
      'display_order': 0,
    };
    var response = await HexabaseBase.mutation(
        GRAPHQL_CREATE_ITEM_FILE_ATTACHMENT,
        variables: {'payload': payload});
    if (response.data != null) {
      id = response.data!['createItemFileAttachment']['_id'];
      item!.add(fieldId!, id);
      return true;
    }
    return false;
  }

  Future<bool> update() async {
    return true;
  }
}
