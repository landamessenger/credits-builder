import 'package:credits_builder/credits_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dummy', () {
    final creditsBuilder = CreditsBuilder();
    expect(creditsBuilder.path.isNotEmpty, true);
  });
}
