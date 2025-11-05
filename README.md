### minimal_di

A small and simple Dependency Injection (DI) container for Dart/Flutter.

### Features
- Clear API for sync/async registrations and lookups
- Lazy Singleton and Factory (both sync and async)
- Default key is `T.toString()` (type-based key)
- Helpful errors for wrong usage
- Lightweight, no extra dependencies

### Install
Add to your `pubspec.yaml`:

```yaml
dependencies:
  minimal_di: ^0.0.6
```

### Quick Start
```dart
import 'package:minimal_di/minimal_di.dart';

void main() async {
  final di = Dependency.instance; // or Dependency()

  // 1) Singleton (sync) — same DateTime
  di.putSingleton<DateTime>(DateTime.now(), named: 'singleton');
  final s1 = di.get<DateTime>(named: 'singleton');
  final s2 = di.get<DateTime>(named: 'singleton');
  assert(identical(s1, s2));

  // 2) Lazy Singleton (sync) — same DateTime
  di.putLazySingleton<DateTime>(() => DateTime.now(), named: 'lazy');
  final l1 = di.get<DateTime>(named: 'lazy');
  final l2 = di.get<DateTime>(named: 'lazy'); // same instance
  assert(identical(l1, l2));

  // 3) Factory (sync) — different DateTime
  di.putFactory<DateTime>(() => DateTime.now(), named: 'factory');
  final f1 = di.get<DateTime>(named: 'factory');
  final f2 = di.get<DateTime>(named: 'factory'); // different each time
  assert(!identical(f1, f2));

  // 4) Lazy Singleton (async) — same DateTime
  di.putAsyncLazySingleton<DateTime>(() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return DateTime.now();
  }, named: 'asyncLazy');
  final al1 = await di.getAsync<DateTime>(named: 'asyncLazy');
  final al2 = await di.getAsync<DateTime>(named: 'asyncLazy');
  assert(identical(al1, al2));

  // 5) Factory (async) — different DateTime
  di.putAsyncFactory<DateTime>(() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return DateTime.now();
  }, named: 'asyncFactory');
  final af1 = await di.getAsync<DateTime>(named: 'asyncFactory');
  final af2 = await di.getAsync<DateTime>(named: 'asyncFactory');
  assert(!identical(af1, af2));
}
```

### API (Dependency)
- Check: `has<T>({String? named}) -> bool`
- Replace: `swap<T>(T instance, {String? named})`
- Register (sync)
  - `putSingleton<T>(T instance, {String? named})`
  - `putLazySingleton<T>(T Function() func, {String? named})`
  - `putFactory<T>(T Function() func, {String? named})`
- Register (async)
  - `putAsyncLazySingleton<T>(Future<T> Function() func, {String? named})`
  - `putAsyncFactory<T>(Future<T> Function() func, {String? named})`
- Resolve
  - Sync: `get<T>({String? named})`
  - Async: `getAsync<T>({String? named})`

### Examples
Sync lazy singleton — same DateTime
```dart
final di = Dependency();
di.putLazySingleton<DateTime>(() => DateTime.now());
final v1 = di.get<DateTime>();
final v2 = di.get<DateTime>();
assert(identical(v1, v2));
```

Async lazy singleton (concurrency-safe) — same DateTime
```dart
final di = Dependency();
di.putAsyncLazySingleton<DateTime>(() async {
  await Future.delayed(const Duration(milliseconds: 100));
  return DateTime.now();
}, named: 'num');

final results = await Future.wait(
  List.generate(10, (_) => di.getAsync<DateTime>(named: 'num')),
);
assert(results.toSet().length == 1); // created only once
```

Factories (sync / async) — different DateTime
```dart
final di = Dependency();
di.putFactory<DateTime>(() => DateTime.now());
di.putAsyncFactory<DateTime>(() async => DateTime.now());

final s1 = di.get<DateTime>();
final s2 = di.get<DateTime>();
assert(!identical(s1, s2)); // new instance each call

final n1 = await di.getAsync<DateTime>();
final n2 = await di.getAsync<DateTime>();
assert(!identical(n1, n2));
```

Named keys and defaults
```dart
final di = Dependency();
di.putSingleton<DateTime>(DateTime.now());               // key = 'DateTime'
di.putSingleton<DateTime>(DateTime.now(), named: 'two'); // key = 'two'

expect(di.get<DateTime>(), isA<DateTime>());
expect(di.get<DateTime>(named: 'two'), isA<DateTime>());
```

Swap
```dart
final di = Dependency();
di.putSingleton<DateTime>(DateTime.now(), named: 'x');
di.swap<DateTime>(DateTime.now(), named: 'x');
expect(di.get<DateTime>(named: 'x'), isA<DateTime>());
```

### Important Rules
- If you register async (Async Lazy / Async Factory), you must use `getAsync<T>()`.
  - Calling `get<T>()` will throw a clear error.
- If you register sync, both `get<T>()` and `getAsync<T>()` are fine.

### Errors
- Not found: `Exception('Key <name> not found')`
- Duplicate: `Exception('Key <name> already exists')`
- Wrong combination (e.g., async reg + get):
  - `Exception('... Use getAsync() instead.')`

### Tests
Run all tests:
```bash
flutter test
```

### License
MIT