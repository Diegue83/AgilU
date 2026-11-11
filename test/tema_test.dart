import 'package:agilu/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('los botones rellenos y tonales tienen texto legible',
      (tester) async {
    late ButtonStyle normal;
    late ButtonStyle tonal;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(builder: (context) {
        normal = FilledButtonTheme.of(context).style!;
        tonal = FilledButtonTheme.of(context).style!;
        return Column(children: [
          FilledButton(onPressed: () {}, child: const Text('Normal')),
          FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
        ]);
      }),
    ));
    expect(normal.foregroundColor!.resolve({}), Colors.white);
    expect(tonal.backgroundColor!.resolve({}), AppTheme.navy);

    final texto = tester.widget<DefaultTextStyle>(find
        .ancestor(
            of: find.text('Tonal'), matching: find.byType(DefaultTextStyle))
        .first);
    expect(texto.style.color, Colors.white);
  });
}
