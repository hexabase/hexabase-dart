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

  test('Get fields', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    project.workspace = HexabaseWorkspace(params: {'id': keys['workspace']});
    var datastore = await project.datastore();
    await new Future.delayed(new Duration(seconds: 10));
    var fields = await datastore.fields();
  });

  test('Add fields', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    project.workspace = HexabaseWorkspace(params: {'id': keys['workspace']});
    var datastore = await project.datastore();
    await new Future.delayed(new Duration(seconds: 10));
    await datastore.fields();
    /*
    var field = datastore.field();
    field.name('ja', '価格').name('en', 'Price');
    field.dataType = HexabaseFieldType.number;
    await field.save();
    */
  });
}
