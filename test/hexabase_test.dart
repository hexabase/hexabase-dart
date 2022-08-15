import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:hexabase/hexabase.dart';
import 'dart:io';
import 'dart:convert';

HexabaseClient? client;
void main() {
  setUp(() async {
    var path = 'test/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    var keys = json.decode(str);
    client = HexabaseClient();
    await client!.auth.signIn(keys['email'], keys['password']);
  });

  test('Get all workspaces', () async {
    var workspaces = await client!.workspace.all();
    expect(workspaces[0].id, isNot(''));
    expect(workspaces[0].name, isNot(''));
  });
}
