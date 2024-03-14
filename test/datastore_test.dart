import 'dart:math';

import 'package:collection/collection.dart';
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

  test('Get search conditions', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    // var res = await datastore.searchConditions();
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.equalTo('name', '梨');
    var items = await datastore.items(query: query);
    expect(items.length, isNot(0));
    var response = await datastore.itemsWithCount();
    expect(response.count, isNot(0));
  });

  test('Get search conditions with greather or equal', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    item.set('test_number', 100);
    await item.save();
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.greaterThanOrEqualTo("test_number", 100);
    var items = await datastore.items(query: query);
    expect(items[0].get("test_number"), greaterThanOrEqualTo(100));
    var response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
    await item.delete();
  });

  test('Get search conditions with less or equal', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var query = datastore.query();
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    item.set('test_number', 100);
    await item.save();
    query.page(1).per(10).displayId(true);
    query.lessThanOrEqualTo("test_number", 101);
    var items = await datastore.items(query: query);
    expect(items[0].get<double>("test_number"), lessThanOrEqualTo(101));
    var response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
    await item.delete();
  });
  test('Get search conditions with geather or equal w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    item.set('test_datetime', DateTime(2022, 9, 11, 0, 0, 0));
    await item.save();
    var date = DateTime(2022, 9, 11, 0, 0, 0);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.greaterThanOrEqualTo("test_datetime", date);
    var items = await datastore.items(query: query);
    expect(items[0].getAsDateTime("test_datetime").isAfter(date), isTrue);
    var response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
    await item.delete();
  });
  test('Get search conditions with less or equal w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    item.set('test_datetime', DateTime(2022, 9, 8, 0, 0, 0));
    await item.save();
    var date = DateTime(2024, 9, 9, 0, 0, 0);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.lessThanOrEqualTo("test_datetime", date);
    var items = await datastore.items(query: query);
    expect(items[0].getAsDateTime("test_datetime").isBefore(date), isTrue);
    var response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
    await item.delete();
  });
  test('Get search conditions with geather w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    item.set('test_number', 600);
    item.set('test_datetime', DateTime(2022, 9, 11, 0, 0, 0));
    await item.save();
    var date = DateTime(2022, 9, 10);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.greaterThan("test_datetime", date);
    var items = await datastore.items(query: query);
    expect(items[0].getAsDateTime("test_datetime").isAfter(date), isTrue);
    var response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
    query.clear();
    query.greaterThan('test_number', 500);
    response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
    await item.delete();
  });
  test('Get search conditions with less w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    // var res = await datastore.searchConditions();
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    item.set('test_number', 400);
    item.set('test_datetime', DateTime(2022, 9, 9, 0, 0, 0));
    await item.save();
    var date = DateTime(2022, 9, 10);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.lessThan("test_datetime", date);
    var items = await datastore.items(query: query);
    expect(items[0].getAsDateTime("test_datetime").isBefore(date), isTrue);
    var response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
    query.clear();
    query.lessThan("test_number", 500);
    response = await datastore.itemsWithCount(query: query);
    expect(response.count, isNot(0));
  });
  test('Search items', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var response = await datastore.search(HBSearchType.history, "コメント");
    if (response.items.length > 0) {
      print(response.items[0].title);
    }
  });

  test('create datastore', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore();
    var name = {'ja': 'テストデータストア', 'en': 'Test Datastore'};
    datastore.set('name', name);
    datastore.displayId = 'TestDatastore';
    datastore.ignoreSaveTemplate = true;
    await datastore.save();
    expect(datastore.id, isNot(''));
    expect(datastore.name('ja'), name['ja']);
    await datastore.delete();
  });

  test('update datastore', () async {
    /*
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    // project.workspace = HexabaseWorkspace(id: keys['workspace']);
    var datastore = await project.datastore();
    datastore.set('name', {'ja': 'テストデータストア', 'en': 'Test Datastore'});
    datastore.displayId = 'TestDatastore';
    datastore.ignoreSaveTemplate = true;
    await datastore.save();
    expect(datastore.id, isNot(''));
    // wait 3 sec
    await Future.delayed(const Duration(seconds: 3));
    var name = {'ja': 'データストア', 'en': 'Datastore'};
    datastore.set('name', name);
    await datastore.save();
    expect(datastore.name('ja'), name['ja']);
    await datastore.delete();
    */
  });
  test('Fetch all datastores', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastores = await project.datastores();
    expect(datastores.length, isNot(0));
  });

  test('Delete datastore', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore();
    datastore.set('name', {'ja': 'テストデータストア', 'en': 'Test Datastore'});
    datastore.displayId = 'TestDatastore';
    datastore.ignoreSaveTemplate = true;
    await datastore.save();
    expect(datastore.id, isNot(''));
    await datastore.delete();
    await Future.delayed(const Duration(seconds: 3));
    var datastores = await project.datastores(refresh: true);
    expect(datastores.length, isNonZero);
    if (datastores.isNotEmpty) {
      var d = datastores.firstWhereOrNull((d) => d.id == datastore.id);
      expect(d, null);
    } else {
      expect(true, false);
    }
  });
}

String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  final randomStr =
      List.generate(length, (_) => charset[random.nextInt(charset.length)])
          .join();
  return randomStr;
}
