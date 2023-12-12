import 'interface.dart';

class DI extends IDependencyInjection
{
  final Map<String, dynamic> _container = {};
  
  static final DI _instance = DI();
  
  static DI get instance => _instance;

  @override
  T get<T extends Object>({String? named}) {
    named ??= T.toString();
    return _container[named] as T;
  }

  @override
  Future<T> getAsync<T extends Object>({String? named}) async {
    named ??= T.toString();
    var func = _container[named] as Future<T> Function();
    return await func();
  }

  @override
  void register<T extends Object>(T instance, {String? named}) {
    named ??= T.toString();
    if (_container.containsKey(named)) 
    {
      throw Exception('Key $named already exists');
    }
    _container.putIfAbsent(named, () => instance);
  }
  
  @override
  void registerLazy<T extends Object>(Future<T> Function() func, {String? named}) {
    named ??= T.toString();
    if (_container.containsKey(named)) 
    {
      throw Exception('Key already exists');
    }
    _container.putIfAbsent(named, () => func);
  }
  
  @override
  void change<T extends Object>(T instance, {String? named}) {
    named ??= T.toString();
    _container.update(named, (x) => instance);
  }
  
  @override
  bool isRegistered<T extends Object>({String? named}) 
  {
    named ??= T.toString();
    return _container.containsKey(named);
  }
}