import 'dependency_container.dart';

class Dependency implements DependencyContainer {
  static final instance = Dependency();

  final Map<String, dynamic> _container = {};

  @override
  bool has<T extends Object>({String? named}) {
    named ??= T.toString();
    return _container.containsKey(named);
  }

  @override
  void swap<T extends Object>(T instance, {String? named}) {
    named ??= T.toString();
    _container[named] = instance;
  }

  @override
  void putSingleton<T extends Object>(T instance, {String? named}) {
    named ??= T.toString();
    if (_container.containsKey(named)) {
      throw Exception('Key $named already exists');
    }
    _container[named] = instance;
  }

  @override
  void putLazySingleton<T extends Object>(T Function() func, {String? named}) {
    named ??= T.toString();
    if (_container.containsKey(named)) {
      throw Exception('Key $named already exists');
    }
    _container[named] = _LazySingleton(func);
  }

  @override
  void putFactory<T extends Object>(T Function() func, {String? named}) {
    named ??= T.toString();
    if (_container.containsKey(named)) {
      throw Exception('Key $named already exists');
    }
    _container[named] = _Factory(func);
  }

  @override
  void putAsyncLazySingleton<T extends Object>(
    Future<T> Function() func, {
    String? named,
  }) {
    named ??= T.toString();
    if (_container.containsKey(named)) {
      throw Exception('Key $named already exists');
    }
    _container[named] = _AsyncLazySingleton(func);
  }

  @override
  void putAsyncFactory<T extends Object>(
    Future<T> Function() func, {
    String? named,
  }) {
    named ??= T.toString();
    if (_container.containsKey(named)) {
      throw Exception('Key $named already exists');
    }
    _container[named] = _AsyncFactory(func);
  }

  @override
  T get<T extends Object>({String? named}) {
    named ??= T.toString();
    if (!_container.containsKey(named)) {
      throw Exception('Key $named not found');
    }
    final value = _container[named];
    if (value is _LazySingleton) {
      final instance = value.create();
      _container[named] = instance;
      return instance as T;
    }
    if (value is _AsyncLazySingleton) {
      throw Exception(
          'Key $named is registered as async lazy singleton. Use getAsync() instead.');
    }
    if (value is _Factory) {
      return value.create() as T;
    }
    if (value is _AsyncFactory) {
      throw Exception(
          'Key $named is registered as async factory. Use getAsync() instead.');
    }
    return value as T;
  }

  @override
  Future<T> getAsync<T extends Object>({String? named}) async {
    named ??= T.toString();
    if (!_container.containsKey(named)) {
      throw Exception('Key $named not found');
    }
    final value = _container[named];
    if (value is _AsyncLazySingleton) {
      final instance = await value.create();
      _container[named] = instance;
      return instance as T;
    }
    if (value is _LazySingleton) {
      // 동기 lazy singleton도 async로 조회 가능 (동기 함수를 await해도 동작)
      final instance = value.create();
      _container[named] = instance;
      return instance as T;
    }
    if (value is _AsyncFactory) {
      return await value.create() as T;
    }
    if (value is _Factory) {
      return value.create() as T;
    }
    return value as T;
  }
}

class _LazySingleton {
  final dynamic Function() _factory;
  _LazySingleton(this._factory);
  dynamic create() => _factory();
}

class _AsyncLazySingleton {
  final Future<dynamic> Function() _factory;
  Future<dynamic>? _future;

  _AsyncLazySingleton(this._factory);

  Future<dynamic> create() {
    _future ??= _factory();
    return _future!;
  }
}

class _Factory {
  final dynamic Function() _factory;
  _Factory(this._factory);
  dynamic create() => _factory();
}

class _AsyncFactory {
  final Future<dynamic> Function() _factory;
  _AsyncFactory(this._factory);
  Future<dynamic> create() => _factory();
}
