import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/base.dart';
import 'package:hexabase/src/graphql.dart';
// import "package:http/browser_client.dart";

class HexabaseFile extends HexabaseBase {
  late String? id;
  late String? name;
  late Uint8List data;
  late String? fieldId;
  late HexabaseItem? item;
  late String? projectId;
  late String? workspaceId;
  late String? datastoreId;
  late String? contentType;
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

  HexabaseFile({this.id, this.name, this.fieldId, this.item, this.contentType})
      : super();

  Future<bool> save() {
    if (id == null) {
      return create();
    } else {
      return update();
    }
  }

  HexabaseFile sets(Map<String, dynamic> fields) {
    fields.forEach((key, value) => set(key, value));
    return this;
  }

  HexabaseFile set(String name, dynamic value) {
    switch (name.toLowerCase()) {
      case 'name':
      case 'filename':
        name = value as String;
        break;
      case 'field_id':
        fieldId = value as String;
        break;
      case 'data':
        data = value as Uint8List;
        break;
      case 'content_type':
      case 'contenttype':
        contentType = value as String;
        break;
      case 'timecreated':
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
      case 'i_id':
      case 'item_id':
        item = HexabaseItem(id: value as String);
        break;
      case 'item':
        item = value as HexabaseItem;
        projectId = item!.projectId;
        datastoreId = item!.datastoreId;
        break;
      case 'p_id':
      case 'project_id':
        projectId = value as String;
        break;
      case 'd_id':
      case 'datastore_id':
        datastoreId = value as String;
        break;
      case 'w_id':
      case 'workspace_id':
        workspaceId = value as String;
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
      case 'medialink':
        mediaLink = value as String;
        break;
      case 'selflink':
        selfLink = value as String;
        break;
      case 'size':
        size = value as int;
        break;
      case 'user_id':
        userId = value as String;
        break;
      default:
        throw Exception('Unknown field: $name');
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
        variables: {'itemId': item!.id, 'fieldId': fieldId, 'fileId': id});
    if (response.data != null) {
      var data = response.data!['datastoreDeleteItemFileAttachmentItem']
          as Map<String, dynamic>;
      return data['success'] as bool;
    }
    return false;
  }

  Map<String, dynamic> createJson() {
    return {
      'filename': name!,
      'contentTypeFile': contentType,
      'content': base64.encode(data),
      'field_id': fieldId!,
      'item_id': item!.id!,
      'filepath': "$projectId/$datastoreId/${item!.id}/$fieldId/$name",
      'd_id': datastoreId!,
      'p_id': projectId!,
      'display_order': displayOrder,
    };
  }

  Future<bool> create() async {
    var response = await HexabaseBase.mutation(
        GRAPHQL_CREATE_ITEM_FILE_ATTACHMENT,
        variables: {'payload': createJson()});
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
