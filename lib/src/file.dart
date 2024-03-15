import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
// import "package:http/browser_client.dart";

class HexabaseFile extends HexabaseBase {
  String id = '';
  late String? name;
  late Uint8List data;
  late HexabaseItem? item;
  late String contentType = "application/octet-stream";
  late DateTime? createdAt;
  late bool? deleted;
  late int displayOrder = 0;
  late String? filepath;
  late String? mediaLink;
  late String? selfLink;
  late int? size;
  late bool? temporary;
  late DateTime? updatedAt;
  late String? userId;
  late HexabaseField? field;

  HexabaseFile({Map<String, dynamic>? params}) : super() {
    if (params != null) sets(params);
  }

  HexabaseFile sets(Map<String, dynamic> params) {
    if (params.containsKey('item')) set('item', params['item']!);
    if (params.containsKey('field')) {
      set('field', params['field']!);
    } else {
      field = null;
    }
    params.forEach((key, value) => set(key, value));
    return this;
  }

  Future<bool> save() {
    if (id == '') {
      return create();
    } else {
      return update();
    }
  }

  HexabaseFile set(String key, dynamic value) {
    if (value == null) return this;
    switch (key) {
      case 'item':
        item = value as HexabaseItem;
        break;
      case 'name':
      case 'filename':
        name = value as String;
        break;
      case 'field':
        field = value as HexabaseField;
        break;
      case 'data':
        data = value as Uint8List;
        break;
      case 'content_type':
      case 'contentType':
        contentType = value as String;
        break;
      case 'timeCreated':
      case 'created_at':
        createdAt = DateTime.parse(value as String);
        break;
      case 'updated_at':
      case 'updated':
        updatedAt = DateTime.parse(value as String);
        break;
      case '_id':
      case 'file_id':
        id = value as String;
        break;
      case 'deleted':
        deleted = value as bool;
        break;
      case 'temporary':
        temporary = value as bool;
        break;
      case 'display_order':
        displayOrder = value as int;
        break;
      case 'filepath':
        filepath = value as String;
        break;
      case 'mediaLink':
        mediaLink = value as String;
        break;
      case 'selfLink':
        selfLink = value as String;
        break;
      case 'size':
        size = value as int;
        break;
      case 'user_id':
        userId = value as String;
        break;
      case 'p_id':
      case 'project_id':
      case 'd_id':
      case 'datastore_id':
      case 'w_id':
      case 'workspace_id':
      case 'field_id':
      case 'i_id':
      case 'item_id':
        break;
      default:
        throw Exception('Unknown field in HexabaseFile: $key');
    }
    return this;
  }

  Future<dynamic> download() async {
    data = await HexabaseBase.get('/api/v0/files/$id', binary: true);
    return data;
    /*
    var response = await HexabaseBase.query(GRAPHQL_GET_DOWNLOAD_FILE,
        variables: {'id': id});
    if (response.data != null) {
      return response.data;
    }
    return false;
    */
  }

  Future<bool> delete() async {
    /*
    REST version
    await HexabaseBase.delete(
        '/api/v0/items/${item!.id}/fields/$fieldId/attachments/$id');
    return true;
    */
    var response = await HexabaseBase.mutation(
        GRAPHQL_DATASTORE_DELETEITEM_FILE_ATTACHMENT_ITEM,
        variables: {'itemId': item!.id, 'fieldId': field!.id, 'fileId': id});
    if (response.data == null) {
      return false;
    }
    var data = response.data!['datastoreDeleteItemFileAttachmentItem']
        as Map<String, dynamic>;
    var bol = data['success'] as bool;
    if (bol) {
      item!.remove(field!.id!, this);
      item!.remove(field!.id!, id);
      await item!.save();
    }
    return bol;
  }

  Map<String, dynamic> createJson() {
    var project = item!.datastore!.project!;
    var datastore = item!.datastore!;
    return {
      'filename': name!,
      'contentTypeFile': contentType,
      'content': base64.encode(data),
      'field_id': field!.id!,
      'item_id': item!.id,
      'filepath':
          "${project.id}/${datastore.id}/${item!.id}/${field!.id}/$name",
      'd_id': datastore.id,
      'p_id': project.id,
      'display_order': displayOrder,
    };
  }

  Future<bool> create() async {
    if (field == null) {
      var res = await HexabaseBase.post(
          '/api/v0/files',
          {
            'filename': name,
            'file': data,
          },
          multipart: true);
      id = (res as Map<String, dynamic>)['file_id'];
      return true;
    } else {
      var response = await HexabaseBase.mutation(
          GRAPHQL_CREATE_ITEM_FILE_ATTACHMENT,
          variables: {'payload': createJson()});
      if (response.data != null) {
        id = response.data!['createItemFileAttachment']['_id'];
        return true;
      }
    }
    return false;
  }

  Future<bool> update() async {
    return true;
  }
}
