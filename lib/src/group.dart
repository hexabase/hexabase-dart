import './base.dart';
import './graphql.dart';

class HexabaseGroup extends HexabaseBase {
  String? id;
  String? displayId;
  bool? showChild;
  bool? disableUiAccess;
  String? name;
  String? parentId;
  int? index;
  HexabaseGroup? parent;
  DateTime? createdAt;
  String? accessKey;
  bool? isRoot;
  List<HexabaseGroup> children = [];

  HexabaseGroup() : super();

  static Future<List<HexabaseGroup>> all() async {
    var response = await HexabaseBase.query(GRAPHQL_GET_GROUP_TREE);
    var ary = response.data!['getGroupTree']['result'] as List<dynamic>;
    var groups = ary.map((e) => HexabaseGroup.fromJson(e)).toList();
    return groups;
  }

  static HexabaseGroup fromJson(dynamic json) {
    var params = json as Map<String, dynamic>;
    var group = HexabaseGroup();
    group.sets(params);
    return group;
  }

  HexabaseGroup sets(Map<String, dynamic> params) {
    params.forEach((key, value) {
      set(key, value);
    });
    return this;
  }

  Future<bool> save() {
    if (id != null) {
      return update();
    } else {
      return create();
    }
  }

  Future<bool> create() async {
    if (name == null) {
      throw Exception('name is required');
    }
    if (displayId == null) {
      throw Exception('displayId is required');
    }
    if (parentId == null && parent == null) {
      throw Exception('parentId is required');
    }
    var variables = {
      'payload': {
        'name': name,
        'display_id': displayId,
        'is_empty_group': false,
      },
      'parentGroupId': parentId ?? parent!.id,
    };
    var response =
        await HexabaseBase.query(GRAPHQL_CREATE_GROUP, variables: variables);
    var params = response.data!['createGroup']['group'] as Map<String, dynamic>;
    sets(params);
    return true;
  }

  Future<bool> update() async {
    if (name == null) {
      throw Exception('name is required');
    }
    if (displayId == null) {
      throw Exception('displayId is required');
    }
    var variables = {
      'payload': {
        'name': name,
        'display_id': displayId,
      },
      'groupId': id,
    };
    var response =
        await HexabaseBase.query(GRAPHQL_UPDATE_GROUP, variables: variables);
    return response.data!['updateGroup']['error'] == null;
  }

  static Future<HexabaseGroup> find(String id) async {
    var response = await HexabaseBase.query(
        GRAPHQL_WORKSPACE_GET_GROUP_CHILDREN,
        variables: {'groupId': id});
    var params = response.data!['workspaceGetGroupChildren']['group']
        as Map<String, dynamic>;
    var group = HexabaseGroup();
    return group.sets(params);
  }

  Future<bool> delete() async {
    if (id == null) {
      throw Exception('Id is required');
    }
    var variables = {
      'groupId': id,
    };
    var response =
        await HexabaseBase.query(GRAPHQL_DELETE_GROUP, variables: variables);
    return response.data!['deleteGroup']['error'] == null;
  }

  HexabaseGroup set(String key, dynamic value) {
    switch (key) {
      case 'id':
        id = value;
        break;
      case 'g_id':
        id = value;
        break;
      case 'display_id':
        displayId = value;
        break;
      case 'group_id':
        displayId = value;
        break;
      case 'show_child':
        showChild = value;
        break;
      case 'disable_ui_access':
        disableUiAccess = value;
        break;
      case 'name':
        name = value;
        break;
      case 'parent_id':
        parentId = value;
        break;
      case 'index':
        index = value;
        break;
      case 'childGroups':
        if (value != null) {
          children = (value as List<dynamic>)
              .map((e) => HexabaseGroup.fromJson(e))
              .toList();
        }
        break;
      case 'created_at':
        createdAt = DateTime.parse(value);
        break;
      case 'access_key':
        accessKey = value;
        break;
      case 'is_root':
        isRoot = value;
        break;
      default:
        break;
    }
    return this;
  }
}
