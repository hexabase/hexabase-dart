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

  test('Get search conditions', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.equalTo('name', '梨');
    var items = await datastore.items(query: query);
    print(items);
    var response = await datastore.itemsWithCount();
    print(response.count);
  });

  test('Get search conditions with greather or equal', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.greaterThanOrEqualTo("price", 500);
    var items = await datastore.items(query: query);
    print(items[0].get("price"));
    var response = await datastore.itemsWithCount(query: query);
    print(response.count);
  });

  test('Get search conditions with less or equal', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.lessThanOrEqualTo("price", 499);
    var items = await datastore.items(query: query);
    print(items[0].get("price"));
    var response = await datastore.itemsWithCount(query: query);
    print(response.count);
  });
  test('Get search conditions with geather or equal w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var date = DateTime(2022, 9, 11, 0, 0, 0);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.greaterThanOrEqualTo("salesDate", date);
    var items = await datastore.items(query: query);
    print(items[0].get("salesDate"));
    var response = await datastore.itemsWithCount(query: query);
    print(response.count);
  });
  test('Get search conditions with less or equal w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var date = DateTime(2022, 9, 9, 0, 0, 0);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.lessThanOrEqualTo("salesDate", date);
    var items = await datastore.items(query: query);
    print(items[0].get("salesDate"));
    var response = await datastore.itemsWithCount(query: query);
    print(response.count);
  });
  test('Get search conditions with geather w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var date = DateTime(2022, 9, 10);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.greaterThan("salesDate", date);
    var items = await datastore.items(query: query);
    print(items[0].get("salesDate"));
    var response = await datastore.itemsWithCount(query: query);
    print(response.count);
    query.clear();
    query.greaterThan("price", 500);
    response = await datastore.itemsWithCount(query: query);
    print(response.count);
  });
  test('Get search conditions with less w/ time', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var res = await datastore.searchConditions();
    var date = DateTime(2022, 9, 10);
    var query = datastore.query();
    query.page(1).per(10).displayId(true);
    query.lessThan("salesDate", date);
    var items = await datastore.items(query: query);
    print(items[0].get("salesDate"));
    var response = await datastore.itemsWithCount(query: query);
    print(response.count);
    query.clear();
    query.lessThan("price", 500);
    response = await datastore.itemsWithCount(query: query);
    print(response.count);
  });
}
