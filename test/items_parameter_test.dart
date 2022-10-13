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

  test('Make search conditions (equalTo)', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var application = client.application(id: keys['application']);
    var datastore = application.datastore(id: keys['datastore']);
    var params = datastore.params();
    params.page(1).per(10).displayId(true);
    params.equalTo('name', '梨');
    var obj = params.toJson();
    expect(obj["conditions"][0]["id"], "name");
    expect(obj["conditions"][0]["search_value"], ["梨"]);
    expect(obj["conditions"][0]["exact_match"], true);
    params.clear();
    // greaterThan
    params.greaterThan("price", 100);
    obj = params.toJson();
    expect(obj["conditions"][0]["id"], "price");
    expect(obj["conditions"][0]["search_value"], ["101", null]);
    expect(obj["conditions"][0]["exact_match"], false);
    params.clear();
    // greaterThanOrEqualTo
    params.greaterThanOrEqualTo("price", 100);
    obj = params.toJson();
    expect(obj["conditions"][0]["id"], "price");
    expect(obj["conditions"][0]["search_value"], ["100", null]);
    expect(obj["conditions"][0]["exact_match"], false);
    params.clear();
    // lessThan
    params.lessThan("price", 100);
    obj = params.toJson();
    expect(obj["conditions"][0]["id"], "price");
    expect(obj["conditions"][0]["search_value"], [null, "99"]);
    expect(obj["conditions"][0]["exact_match"], false);
    params.clear();
    // lessThanOrEqualTo
    params.lessThanOrEqualTo("price", 100);
    obj = params.toJson();
    expect(obj["conditions"][0]["id"], "price");
    expect(obj["conditions"][0]["search_value"], [null, "100"]);
    expect(obj["conditions"][0]["exact_match"], false);
    params.clear();
    // notEqualTo
    params.notEqualTo("name", "梨");
    obj = params.toJson();
    expect(obj["conditions"][0]["id"], "name");
    expect(obj["conditions"][0]["search_value"], ["梨"]);
    expect(obj["conditions"][0]["not_match"], true);
    params.clear();
    // inArray
    params.inArray("name", ["梨", "りんご"]);
    obj = params.toJson();
    expect(obj["conditions"][0]["id"], "name");
    expect(obj["conditions"][0]["search_value"], ["梨", "りんご"]);
    expect(obj["conditions"][0]["exact_match"], true);
    params.clear();
    // notInArray
    params.notInArray("name", ["梨", "りんご"]);
    obj = params.toJson();
    expect(obj["conditions"][0]["id"], "name");
    expect(obj["conditions"][0]["search_value"], ["梨", "りんご"]);
    expect(obj["conditions"][0]["not_match"], true);
    params.clear();
  });
}
