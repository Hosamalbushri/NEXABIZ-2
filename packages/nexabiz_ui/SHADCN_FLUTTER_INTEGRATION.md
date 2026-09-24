# shadcn_flutter integration boundary

`shadcn_flutter` is the visual implementation authority inside `packages/nexabiz_ui`. Application and feature code use NexaBiz semantic components through:

```dart
import 'package:nexabiz_ui/nexabiz_ui.dart';
```

Direct `shadcn_flutter` imports belong inside this package or in explicitly registered development showcase code. Do not create a second visual system and do not expose raw shadcn types when a NexaBiz semantic contract is required.

Use [docs/getting_started.md](docs/getting_started.md) for selection guidance and [docs/public_api.md](docs/public_api.md) for the audited public surface.
