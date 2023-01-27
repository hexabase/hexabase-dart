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

### Authentication

#### Log in 

```dart
await client.auth.login('you@example.com', 'your_secure_password');
```

#### Save session to localStorage, NSUserDefaults or SharedPreferences

```dart
// Save to local
client.persistence = Hexabase.persistenceLocal;
await client.login(keys['email'], keys['password']);
```

And next time, you should check login status like below.

```dart
if (await client.isLogin()) {
	// Login
} else {
	// Not login, or session is invalid.
}
```

#### Log out

```dart
var user = await client.getCurrentUser();
await user.logout();
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

### Project

#### Get all projects

```dart
var projects = await workspace.projects();
print(projects[0].id);
print(projects[0].datastores[0].id);
```

#### Get project

```dart
var project = client.project(id: 'PROJECT_ID');
```

#### Create project

```dart
var project = client.project();
project.name('ja', 'テストアプリ').name('en', 'Test App');
await project.save();
```

#### Update project

```dart
var project = client.project(id: 'PROJECT_ID');
project.name('en', 'Test app v2');
await project.save();
```

#### Delete project

```dart
await project.delete();
```

### Datastore

#### Get datastore

```dart
var project = client.project(id: 'PROJECT_ID');
var datastore = project.datastore(id: 'DATASTORE_ID');
```

### Datastore Item

#### Search datastore items

```dart
var query = datastore.query);
query.equalTo('name', 'value');
var items = await datastore.items(query);
```

#### Full text search

```dart
var response = await datastore.search(HBSearchType.history, "comment");
print(response.count); // Items count
print(response.items); // Items
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

#### Upload file

```dart
var filePath = './test/test.png';
var file = HexabaseFile(
		name: basename(filePath), contentType: lookupMimeType(filePath));
file.data = File(filePath).readAsBytesSync();
item.set('picture', file);
await item.save();
```

#### Upload files

```dart
var filePaths = ['./test/test.png', './test/test2.png'];
for (var filePath in filePaths) {
	var file = HexabaseFile(
			name: basename(filePath), contentType: lookupMimeType(filePath));
	file.data = File(filePath).readAsBytesSync();
	item.add('picture', file);
}
await item.save();
```

#### Download file

It returns multiple everytime. `data` is Unit8List;

```dart
var pictures = item.get('picture') as List<HexabaseFile>;
var data = await pictures[0].download();
```

#### Delete file

```dart
await pictures[0].delete();
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


