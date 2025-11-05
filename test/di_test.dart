import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_di/minimal_di.dart';
import 'dart:math';

final _random = Random(); // 전역으로 한 번만 생성

void main() {
  test('singleton', () {
    var di = Dependency();
    di.set(0);

    di.set(1);
    var one = di.get<int>();
    expect(one, 1);

    di.putSingleton("test");
    var test = di.get<String>();
    expect(test, "test");

    di.putSingleton(2, named: "two");
    var two = di.get<int>(named: "two");
    expect(two, 2);

    di.set<int>(3, named: "two");
    var three = di.get<int>(named: "two");
    expect(three, 3);

    if (!di.has(named: "three")) {
      di.putSingleton(3, named: "three");
    }

    three = di.get(named: "three");
    expect(three, 3);
  });

  int randomNumber() {
    var rnd = _random.nextInt(100);
    debugPrint("randomNumber = $rnd");
    return rnd;
  }

  Future<int> randomNumberAsync() async {
    await Future.delayed(Duration(seconds: 1));
    return randomNumber();
  }

  test("lazySingleton", () async {
    var di = Dependency();
    di.putLazySingleton<int>(randomNumber);
    var one = di.get<int>();
    var two = di.get<int>();
    expect(one, equals(two));
  });

  test("asyncLazySingleton", () async {
    var di = Dependency();
    di.putAsyncLazySingleton<int>(randomNumberAsync, named: "one");
    var one = await di.getAsync<int>(named: "one");
    var two = await di.getAsync<int>(named: "one");
    expect(one, equals(two));
  });

  test("asyncFactory", () async {
    var di = Dependency();
    di.putAsyncFactory<int>(randomNumberAsync);
    var one = await di.getAsync<int>();
    var two = await di.getAsync<int>();

    expect(one, isNot(equals(two)));
  });

  test("factory", () async {
    var di = Dependency();
    di.putFactory<int>(randomNumber);
    var one = await di.getAsync<int>();
    var two = await di.getAsync<int>();

    expect(one, isNot(equals(two)));
  });

  // --- 추가: 비동기 LazySingleton 동시성 테스트 (단 한 번만 생성) ---
  test('asyncLazySingleton concurrency creates only once', () async {
    final di = Dependency();
    var createCount = 0;
    di.putAsyncLazySingleton<int>(() async {
      createCount++;
      await Future.delayed(const Duration(milliseconds: 100));
      return 42;
    }, named: 'c1');

    final results = await Future.wait(
      List.generate(20, (_) => di.getAsync<int>(named: 'c1')),
    );

    expect(results.toSet().length, 1);
    expect(createCount, 1);
  });

  // --- 추가: 비동기 Factory 동시성 테스트 (요청마다 생성) ---
  test('asyncFactory concurrency creates per-request', () async {
    final di = Dependency();
    var createCount = 0;
    di.putAsyncFactory<int>(() async {
      createCount++;
      await Future.delayed(const Duration(milliseconds: 10));
      return createCount;
    }, named: 'f1');

    final results = await Future.wait(
      List.generate(10, (_) => di.getAsync<int>(named: 'f1')),
    );

    expect(createCount, 10);
    expect(results.length, 10);
  });

  // --- 추가: 잘못된 조합 사용 시 명확한 예외 ---
  test('mismatch: async lazy registered but get() called', () async {
    final di = Dependency();
    di.putAsyncLazySingleton<int>(() async => 1, named: 'm1');
    expect(
      () => di.get<int>(named: 'm1'),
      throwsA(isA<Exception>()),
    );
  });

  test('mismatch: async factory registered but get() called', () async {
    final di = Dependency();
    di.putAsyncFactory<int>(() async => 1, named: 'm2');
    expect(
      () => di.get<int>(named: 'm2'),
      throwsA(isA<Exception>()),
    );
  });

  // --- 추가: sync 등록 후 getAsync() 정상 동작 ---
  test('sync registrations are retrievable via getAsync()', () async {
    final di = Dependency();
    di.putSingleton<int>(7, named: 's1');
    expect(await di.getAsync<int>(named: 's1'), 7);

    var lazyCount = 0;
    di.putLazySingleton<int>(() {
      lazyCount++;
      return 9;
    }, named: 's2');
    expect(await di.getAsync<int>(named: 's2'), 9);
    expect(lazyCount, 1);

    di.putFactory<int>(() => 11, named: 's3');
    final a = await di.getAsync<int>(named: 's3');
    final b = await di.getAsync<int>(named: 's3');
    expect(a, equals(b));
  });

  // --- 추가: 중복 등록 예외 ---
  test('duplicate registration throws', () {
    final di = Dependency();
    di.putSingleton<int>(1, named: 'dup');
    expect(
        () => di.putSingleton<int>(2, named: 'dup'), throwsA(isA<Exception>()));
    expect(() => di.putLazySingleton<int>(() => 1, named: 'dup'),
        throwsA(isA<Exception>()));
    expect(() => di.putFactory<int>(() => 1, named: 'dup'),
        throwsA(isA<Exception>()));
    expect(() => di.putAsyncLazySingleton<int>(() async => 1, named: 'dup'),
        throwsA(isA<Exception>()));
    expect(() => di.putAsyncFactory<int>(() async => 1, named: 'dup'),
        throwsA(isA<Exception>()));
  });

  // --- 추가: 기본 이름 규칙(T.toString()) 및 named 동작 ---
  test('default key (T.toString()) and named behavior', () {
    final di = Dependency();
    di.putSingleton<int>(123);
    expect(di.get<int>(), 123);
    expect(di.has<int>(), isTrue);

    di.putSingleton<String>('alpha', named: 'str');
    expect(di.get<String>(named: 'str'), 'alpha');
    expect(di.has<String>(named: 'str'), isTrue);
    expect(di.has<String>(named: 'missing'), isFalse);
  });

  // --- 추가: set 교체 동작 ---
  test('set replaces existing instance', () {
    final di = Dependency();
    di.putSingleton<int>(1, named: 'x');
    di.set<int>(2, named: 'x');
    expect(di.get<int>(named: 'x'), 2);
  });

  test('readme example', () async {
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
  });
}
