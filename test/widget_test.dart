import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/main.dart';

void main() {
  testWidgets('App loads with products screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ProductProvider(),
        child: MaterialApp(home: ProductListScreen()),
      ),
    );

    // Verify that the app loads and shows "Products"
    expect(find.text("Products"), findsOneWidget);

    // Check if category filters are visible
    expect(find.byType(ChoiceChip), findsWidgets);

    // Ensure at least one product placeholder (loading state) is visible
    expect(find.byType(Card), findsWidgets);
  });
}
