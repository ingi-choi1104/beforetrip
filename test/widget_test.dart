import 'package:flutter_test/flutter_test.dart';
import 'package:beforetrip/main.dart';

void main() {
  testWidgets('앱 실행 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const BeforeTripApp());
    expect(find.text('여행 가기 전'), findsWidgets);
  });
}
