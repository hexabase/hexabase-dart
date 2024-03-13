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

  /*
  test('Get roles', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var roles = await project.roles();
    print(roles);
  });
  */
}
