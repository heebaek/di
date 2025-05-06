abstract class IDependencyInjection {
  bool isRegistered<T extends Object>({String? named});
  void register<T extends Object>(T instance, {String? named});
  void registerLazy<T extends Object>(Future<T> Function() func,
      {String? named});
  void change<T extends Object>(T instance, {String? named});
  T get<T extends Object>({String? named});
  Future<T> getAsync<T extends Object>({String? named});
}
