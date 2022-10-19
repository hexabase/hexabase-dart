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
  test('Create item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var item = datastore.item();
    item.set('name', 'スイカ').set('price', 100);
    await item.save();
    item.set('price', 110).set('salesDate', DateTime.now());
    await item.save();
    await item.delete();
  });
  test('Update item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.equalTo('name', '梨');
    var items = await datastore.items(query: query);
    var item = items[0];
    item.set('price', 140);
    await item.save();
    item.set('price', 130);
    await item.save();
  });
}
