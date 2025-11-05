abstract interface class DependencyContainer {
  // 1. 등록 여부 확인
  bool has<T extends Object>({String? named});

  // 2. 인스턴스 교체 (주로 테스트/디버깅 목적)
  void swap<T extends Object>(T instance, {String? named});

  // 3. 즉시 싱글톤 등록 (가장 기본, 동기적 인스턴스 제공)
  void putSingleton<T extends Object>(T instance, {String? named});

  // 4. 지연 싱글톤 등록 (동기적 팩토리, 요청 시점에 단 한 번 생성)
  void putLazySingleton<T extends Object>(T Function() func, {String? named});

  // 5. 팩토리 등록 (동기적 팩토리, 요청 시점마다 새 객체 생성)
  void putFactory<T extends Object>(T Function() func, {String? named});

  // --- 비동기 등록 ---

  // 6. 비동기 지연 싱글톤 등록 (Async + Lazy, 단 한 번 생성)
  void putAsyncLazySingleton<T extends Object>(Future<T> Function() func,
      {String? named});

  // 7. 비동기 팩토리 등록 (Async + Factory, 요청 시점마다 새 Future 반환)
  void putAsyncFactory<T extends Object>(Future<T> Function() func,
      {String? named});

  // --- 조회 함수 (get 함수가 빠져있어 추가했습니다) ---

  // 8. 동기적 조회
  T get<T extends Object>({String? named});

  // 9. 비동기적 조회
  Future<T> getAsync<T extends Object>({String? named});
}
