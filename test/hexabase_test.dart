import 'package:flutter_test/flutter_test.dart';

import 'package:hexabase/hexabase.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  setUp(() async {
    var path = 'test/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    var keys = json.decode(str);
    var client = Hexabase();
    await client.login(keys['email'], keys['password']);
  });

  test('Check login', () async {
    var client = Hexabase();
    final bol = await client.isLogin();
    expect(bol, false);
  });

  test('Not login error', () async {
    var client = Hexabase();
    try {
      await client.workspaces();
      expect(true, false);
    } catch (e) {
      expect(e.toString(), contains('Not authenticated'));
    }
  });

  test('Get all workspaces', () async {
    var client = Hexabase.instance;
    var workspaces = await client.workspaces();
    print(workspaces.map((e) => e.id));
    expect(workspaces[0].id, isNot(''));
    expect(workspaces[0].name, isNot(''));
  });
}
