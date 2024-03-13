import 'package:flutter_test/flutter_test.dart';

import 'package:hexabase/hexabase.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  dynamic loadFile() async {
    var path = 'test/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    return json.decode(str);
  }

  setUp(() async {
    var keys = await loadFile();
    var client = Hexabase();
    await client.login(keys['email'], keys['password']);
    await client.setWorkspace(keys['workspace']);
  });

  test('Get group tree', () async {
    var client = Hexabase.instance;
    var groups = await client.groups();
    expect(groups.length, isNot(0));
  });

  test('Find group', () async {
    var client = Hexabase.instance;
    var groups = await client.groups();
    var group = await client.group(id: groups[0].id);
    expect(group.id, groups[0].id);
  });

  test('Create group', () async {
    var client = Hexabase.instance;
    var groups = await client.groups();
    var group = await client.group();
    group.name = 'テストグループ';
    group.parent = groups[0];
    group.displayId = 'test_group';
    await group.save();
    await group.delete();
  });

  test('Update group', () async {
    var client = Hexabase.instance;
    var groups = await client.groups();
    var group = await client.group();
    group.name = 'テストグループ';
    group.parent = groups[0];
    group.displayId = 'test_group3';
    await group.save();
    group.name = 'テストグループ2';
    await group.save();
    await group.delete();
  });

  test('Delete group', () async {
    var client = Hexabase.instance;
    var groups = await client.groups();
    var group = await client.group();
    group.name = 'テストグループ';
    group.parent = groups[0];
    group.displayId = 'test_group';
    await group.save();
    group.name = 'テストグループ2';
    await group.save();
    await group.delete();
  });
}
