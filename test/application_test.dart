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
    var applications = await workspace.applications();
    // print(applications[0].datastores.length);
    expect(applications[0].id, isNot(''));
    expect(applications[0].datastores[0].id, isNot(''));
  });
  test('Get Application Info', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var application = client.application(id: keys['application']);
    print(application);
    expect(application.id, isNot(''));
  });

  test('Create application', () async {
    var client = Hexabase.instance;
    var application = client.application();
    application.name = {
      HBAppName.ja: 'テストアプリ',
      HBAppName.en: 'Test App',
    };
    await application.save();
    expect(application.id, isNot(''));
  });
  test('Update application and delete', () async {
    var client = Hexabase.instance;
    var application = client.application();
    application.name = {
      HBAppName.ja: 'テストアプリ',
      HBAppName.en: 'Test App',
    };
    await application.save();
    await new Future.delayed(new Duration(seconds: 1));
    application.name[HBAppName.ja] = 'テストアプリ2';
    await application.save();
    expect(application.id, isNot(''));
    await application.delete();
  });
}
