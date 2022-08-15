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
    await client.auth.signIn(keys['email'], keys['password']);
  });

  test('Not login error', () async {
    var client = Hexabase();
    try {
      await client.workspace.all();
      expect(true, false);
    } catch (e) {
      expect(e.toString(), contains('Not authenticated'));
    }
  });
  test('No initializing error', () async {
    try {
      var client = Hexabase.instance;
      await client.workspace.all();
      expect(true, false);
    } catch (e) {
      expect(
          e.toString(),
          contains(
              'You must initialize the Hexabase instance before calling Hexabase.instance'));
    }
  });

  test('Get all workspaces', () async {
    var client = Hexabase.instance;
    var workspaces = await client.workspace.all();
    expect(workspaces[0].id, isNot(''));
    expect(workspaces[0].name, isNot(''));
  });
}
