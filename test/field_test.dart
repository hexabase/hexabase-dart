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

  test('Get fields', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore();
    await datastore.save();
    await Future.delayed(const Duration(seconds: 10));
    var fields = await datastore.fields();
    expect(fields.length, 2); // Title and Status
    await datastore.delete();
  });

  test('Add fields', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore();
    await datastore.save();
    await Future.delayed(const Duration(seconds: 10));
    await datastore.fields();
    await datastore.delete();
    /*
    var field = datastore.field();
    field.name('ja', '価格').name('en', 'Price');
    field.dataType = HexabaseFieldType.number;
    await field.save();
    */
  });
}
