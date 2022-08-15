# Hexabase SDK for Dart and Flutter

## Usage

### Import

```dart
import 'package:hexabase/hexabase.dart';
```

### Initializing

```dart
var client = HexabaseClient();
```

### Sign in 

```dart
await client!.auth.signIn('you@example.com', 'your_secure_password');
```

### Workspace

#### Get all workspaces

```dart
var workspaces = await client!.workspace.all();
// workspaces[0].id
// workspaces[0].name
```

## License

MIT License


