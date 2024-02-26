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

  test('Get Applications', () async {
    var client = Hexabase.instance;
    var projects = await client.currentWorkspace.projects();
    // print(projects[0].datastores.length);
    expect(projects[0].id, isNot(''));
    expect((await projects[0].datastores())[0].id, isNot(''));
  });
  test('Get Application Info', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    expect(project.name, isNot(''));
    expect(project.id, isNot(''));
  });

  test('Create project', () async {
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project();
    project.set('name', 'Test App');
    await project.save();
    expect(project.id, isNot(''));
    await project.delete();
  });
  test('Update project and delete', () async {
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project();
    project.set('name', 'テストアプリ');
    await project.save();
    await Future.delayed(const Duration(seconds: 1));
    expect(project.id, isNot(''));
    await project.delete();
  });

  test('Execute function', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var params = {'a': 1, 'b': 2};
    var result = await project.function('test', params: params);
    expect(params, result['params']);
  });
}
