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
var params = datastore.params();
params.equalTo('name', 'value');
var items = await datastore.items(params);
```

### Search conditions

#### Equal to

```dart
var params = datastore.params();
params.equalTo('name', 'value');
```

#### Not equal to

```dart
params.notEqualTo("name", "梨");
```

#### Greater than ">"

Only support int and DateTime.

```dart
params.greaterThan("price", 100);
```

#### Greater than or equal ">="

Only support int and DateTime.

```dart
params.greaterThanOrEqualTo("price", 100);
```

#### Less than "<"

Only support int and DateTime.

```dart
params.lessThan("price", 100);
```

#### Less than or equal "<="

Only support int and DateTime.

```dart
params.lessThanOrEqualTo("price", 100);
```

#### In

```dart
// name == "Apple" or name == "Orange"
params.inArray("name", ["Apple", "Orange"]);
```

#### Not in

```dart
// name != "Apple" && name != "Orange"
params.notInArray("name", ["Apple", "Orange"]);
```

## License

MIT License


