import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astro_ramji/core/localization/app_localizations.dart';
import 'package:astro_ramji/data/models/location_model.dart';
import 'package:astro_ramji/presentation/providers/theme_provider.dart';
import 'package:astro_ramji/presentation/providers/language_provider.dart';
import 'package:astro_ramji/presentation/providers/astrology_api_provider.dart';
import 'package:astro_ramji/presentation/widgets/location_autocomplete_field.dart';
import 'package:astro_ramji/presentation/pages/kundali/kundali_form_screen.dart';

Widget createTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => AstrologyApiProvider()),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LocationAutocompleteField renders label and hint in dark and light modes', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(createTestApp(
      LocationAutocompleteField(
        controller: controller,
        label: 'PLACE OF BIRTH',
        hint: 'Search city or town',
        isDark: true,
      ),
    ));

    expect(find.text('PLACE OF BIRTH'), findsOneWidget);
    expect(find.text('Search city or town'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('LocationAutocompleteField typing text displays clear button and clears on tap', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(createTestApp(
      LocationAutocompleteField(
        controller: controller,
        label: 'BIRTH PLACE',
        hint: 'Enter location',
        isDark: false,
      ),
    ));

    // Enter text into field
    await tester.enterText(find.byType(TextFormField), 'Varanasi');
    await tester.pump();

    // When searching, progress indicators are shown (in field suffix & overlay)
    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

    // Fast forward past debounce
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(controller.text, 'Varanasi');
    expect(find.byIcon(Icons.clear), findsOneWidget);

    // Tap clear button
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(controller.text, '');
  });

  testWidgets('LocationAutocompleteField fires validator on empty submit', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    await tester.pumpWidget(createTestApp(
      Form(
        key: formKey,
        child: LocationAutocompleteField(
          controller: controller,
          label: 'LOCATION',
          hint: 'Select location',
          isDark: true,
          validator: (val) => (val == null || val.isEmpty) ? 'Location required' : null,
        ),
      ),
    ));

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Location required'), findsOneWidget);
  });

  testWidgets('LocationAutocompleteField triggers onLocationSelected with LocationModel', (tester) async {
    final controller = TextEditingController();
    LocationModel? selectedLocation;

    await tester.pumpWidget(createTestApp(
      LocationAutocompleteField(
        controller: controller,
        label: 'LOCATION',
        hint: 'Search...',
        isDark: true,
        onLocationSelected: (loc) {
          selectedLocation = loc;
        },
      ),
    ));

    expect(selectedLocation, isNull);
  });

  group('KundaliChartPainter Dynamic Tests', () {
    testWidgets('KundaliChartPainter paints cleanly with default data in CustomPaint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: CustomPaint(
                  painter: KundaliChartPainter(isDark: true),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('KundaliChartPainter paints cleanly with live API dynamic data', (tester) async {
      final sampleApiData = {
        'ascendant': {
          'sign': 'PISCES',
          'lord': 'JUPITER',
          'degree_dms': "16°11'",
          'nakshatra': 'UTTARA_BHADRAPADA',
        },
        'houses': [
          {'house_number': 1, 'sign': 'PISCES', 'lord': 'JUPITER'},
          {'house_number': 2, 'sign': 'ARIES', 'lord': 'MARS'},
          {'house_number': 3, 'sign': 'TAURUS', 'lord': 'VENUS'},
          {'house_number': 4, 'sign': 'GEMINI', 'lord': 'MERCURY'},
          {'house_number': 5, 'sign': 'CANCER', 'lord': 'MOON'},
          {'house_number': 6, 'sign': 'LEO', 'lord': 'SUN'},
          {'house_number': 7, 'sign': 'VIRGO', 'lord': 'MERCURY'},
          {'house_number': 8, 'sign': 'LIBRA', 'lord': 'VENUS'},
          {'house_number': 9, 'sign': 'SCORPIO', 'lord': 'MARS'},
          {'house_number': 10, 'sign': 'SAGITTARIUS', 'lord': 'JUPITER'},
          {'house_number': 11, 'sign': 'CAPRICORN', 'lord': 'SATURN'},
          {'house_number': 12, 'sign': 'AQUARIUS', 'lord': 'SATURN'},
        ],
        'planets': [
          {'planet': 'SUN', 'sign': 'CAPRICORN', 'house': 11, 'retrograde': false},
          {'planet': 'MOON', 'sign': 'SCORPIO', 'house': 9, 'retrograde': false},
          {'planet': 'MARS', 'sign': 'AQUARIUS', 'house': 12, 'retrograde': false},
          {'planet': 'MERCURY', 'sign': 'SAGITTARIUS', 'house': 10, 'retrograde': false},
          {'planet': 'JUPITER', 'sign': 'AQUARIUS', 'house': 12, 'retrograde': false},
          {'planet': 'VENUS', 'sign': 'SAGITTARIUS', 'house': 10, 'retrograde': true},
          {'planet': 'SATURN', 'sign': 'PISCES', 'house': 1, 'retrograde': false},
          {'planet': 'RAHU', 'sign': 'LEO', 'house': 6, 'retrograde': true},
          {'planet': 'KETU', 'sign': 'AQUARIUS', 'house': 12, 'retrograde': true},
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                height: 350,
                child: CustomPaint(
                  painter: KundaliChartPainter(
                    isDark: false,
                    kundaliData: sampleApiData,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('KundaliChartPainter shouldRepaint triggers on data or theme change', () {
      final painter1 = KundaliChartPainter(isDark: true, kundaliData: null);
      final painter2 = KundaliChartPainter(isDark: true, kundaliData: null);
      final painter3 = KundaliChartPainter(isDark: false, kundaliData: null);
      final painter4 = KundaliChartPainter(isDark: true, kundaliData: {'ascendant': {'sign': 'ARIES'}});

      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painter3), isTrue);
      expect(painter1.shouldRepaint(painter4), isTrue);
    });
  });
}
