# Hexabase SDK for Dart and Flutter

## Usage

### Import

```dart
import 'package:hexabase/hexabase.dart';
```

### Initializing

```dart
Hexabase();
```

After initialized the client, you can take client object anytime.

```dart
var client = Hexabase.instance;
```

### Log in 

```dart
await client.auth.login('you@example.com', 'your_secure_password');
```

### Workspace

#### Get all workspaces

```dart
var workspaces = await client.workspace.all();
// workspaces[0].id
// workspaces[0].name
```

#### Get workspace

```dart
var workspace = client.workspace(id: 'WORKSPACE_ID');
```

### Application

#### Get all applications

```dart
var applications = await workspace.applications();
print(applications[0].id);
print(applications[0].datastores[0].id);
```

#### Get application

```dart
var application = client.application(id: 'APPLICATION_ID');
```

#### Create application

```dart
var application = client.application();
application.name = {
	HBAppName.ja: 'テストアプリ',
	HBAppName.en: 'Test App',
};
await application.save();
```

#### Update application

```dart
var application = client.application(id: 'APPLICATION_ID');
application.name[HBAppName.en] = 'Test app v2';
await application.save();
```

#### Delete application

```dart
await application.delete();
```

### Datastore

#### Get datastore

```dart
var application = client.application(id: 'APPLICATION_ID');
var datastore = application.datastore(id: 'DATASTORE_ID');
```

### Datastore Item

#### Search datastore items

```dart
var query.= datastore.query.);
query.equalTo('name', 'value');
var items = await datastore.items(query.;
```

#### Create new item

```dart
var item = datastore.item();
item.set('name', 'value').set('price', 100);
await item.save();
```

#### Update item

```dart
item.set('price', 110).set('salesDate', DateTime.now());
await item.save();
```

#### Update item status

```dart
item
	.action('startReservation') // Action ID or Action Id or Action name (English) or Action name (Japanese)
	.set('salesDate', DateTime.now()); // You can also update other fields
await item.save();
```

#### Delete item

```dart
await item.delete();
```

#### Get field data

```dart
item.get('name');
item.getAsString('name');
item.getAsInt('name');
item.getAsDouble('name');
item.getAsDateTime('name');
item.getAsBool('name');

// w/ default value
item.getAsString('name', defaultValue: "Hello");
item.getAsInt('name', defaultValue: 100);
item.getAsDouble('name', defaultValue: 3.14156);
item.getAsDateTime('name', defaultValue: DateTime.now());
item.getAsBool('name', defaultValue: true);
```

### Search conditions

#### Equal to

```dart
var query.= datastore.query();
query.equalTo('name', 'value');
```

#### Not equal to

```dart
query.notEqualTo("name", "value");
```

#### Greater than ">"

Only support int and DateTime.

```dart
query.greaterThan("price", 100);
```

#### Greater than or equal ">="

Only support int and DateTime.

```dart
query.greaterThanOrEqualTo("price", 100);
```

#### Less than "<"

Only support int and DateTime.

```dart
query.lessThan("price", 100);
```

#### Less than or equal "<="

Only support int and DateTime.

```dart
query.lessThanOrEqualTo("price", 100);
```

#### In

```dart
// name == "Apple" or name == "Orange"
query.inArray("name", ["Apple", "Orange"]);
```

#### Not in

```dart
// name != "Apple" && name != "Orange"
query.notInArray("name", ["Apple", "Orange"]);
```

## License

MIT License


