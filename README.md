# di

Flutter Dependency Injection package for minimalist.

## just 6 simple features

```dart
abstract class IDependencyInjection
{
  bool isRegistered<T extends Object>({String? named});
  void register<T extends Object>(T instance, {String? named});
  void registerLazy<T extends Object>(Future<T> Function() func, {String? named});
  void change<T extends Object>(T instance, {String? named});
  T get<T extends Object>({String? named});
  Future<T> getAsync<T extends Object>({String? named});
}
```

## Usage

```dart
Future<int> initNumber(String number) async
{
  var parsed = int.tryParse(number);
  parsed ??= 1;
  await Future.delayed(Duration(seconds: parsed));
  return parsed;
}

DI.instance.registerLazy<int>(() => initNumber("1"), named:"one");
var one = await DI.instance.getAsync<int>(named: "one");
assert(one == 1);

```
if you do not pass named argument, default values is runtimeType.toString()