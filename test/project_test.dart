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
  });

  test('Get Applications', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var workspace = client.workspace(id: keys['workspace']);
    var projects = await workspace.projects();
    // print(projects[0].datastores.length);
    expect(projects[0].id, isNot(''));
    expect(projects[0].datastores[0].id, isNot(''));
  });
  test('Get Application Info', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    print(project);
    expect(project.id, isNot(''));
  });

  test('Create project', () async {
    var client = Hexabase.instance;
    var project = client.project();
    project.name('ja', 'テストアプリ').name('en', 'Test App');
    await project.save();
    expect(project.id, isNot(''));
  });
  test('Update project and delete', () async {
    var client = Hexabase.instance;
    var project = client.project();
    project.name('ja', 'テストアプリ').name('en', 'Test App');
    await project.save();
    await new Future.delayed(new Duration(seconds: 1));
    project.name('ja', 'テストアプリ2');
    await project.save();
    expect(project.id, isNot(''));
    await project.delete();
  });
}
