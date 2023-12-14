import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_di/minimal_di.dart';

void main() {
  test('register', () {

    DI.instance.change(0);

    DI.instance.change(1);
    var one = DI.instance.get<int>();
    expect(one, 1);

    DI.instance.register("test");
    var test = DI.instance.get<String>();
    expect(test, "test");

    DI.instance.register(2, named: "two");
    var two = DI.instance.get<int>(named: "two");
    expect(two, 2);

    DI.instance.change<int>(3, named:"two");
    var three = DI.instance.get<int>(named:"two");
    expect(three, 3);

    if (!DI.instance.isRegistered(named:"three"))
    {
      DI.instance.register(3, named:"three");
    }

    three = DI.instance.get(named: "three");
    expect(three, 3);
  });


  Future<int> initNumber(String number) async
  {
    var parsed = int.tryParse(number);
    parsed ??= 1;
    await Future.delayed(Duration(seconds: parsed));
    return parsed;
  }

  test("registerLazy", () async {

    DI.instance.registerLazy<int>(() => initNumber("1"), named:"one");
    var one = await DI.instance.getAsync<int>(named: "one");
    expect(one, 1);
  });
}
