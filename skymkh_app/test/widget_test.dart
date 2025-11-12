// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:skymkh_app/main.dart';

void main() {
  test('يحوي التطبيق خمسة تبويبات مع الروابط الصحيحة', () {
    expect(navigationTabs, hasLength(5));
    expect(
      navigationTabs.map((tab) => tab.title).toList(),
      ['الرئيسية', 'الدروس', 'الأدوات', 'الاختبارات', 'الحساب'],
    );
    expect(
      navigationTabs.map((tab) => tab.url).toList(),
      [
        'https://skymkh.com/?page_id=192',
        'https://skymkh.com/?page_id=1096',
        'https://skymkh.com/?page_id=1082',
        'https://skymkh.com/?page_id=1170',
        'https://skymkh.com/?page_id=484',
      ],
    );
  });
}
