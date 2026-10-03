import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awnwasand/academy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('missing backend tables block signup before an account is created', () async {
    var requests = 0;
    final transport = MockClient((request) async {
      requests++;
      return http.Response(jsonEncode({'code': 'PGRST205', 'message': 'Missing table'}), 404, headers: {'content-type': 'application/json'});
    });
    final client = SupabaseClient('https://example.supabase.co', 'test-public-key');
    final academy = Academy(await SharedPreferences.getInstance(), client: client, backendUrl: 'https://example.supabase.co', publishableKey: 'test-public-key', readinessClient: transport);
    await academy.checkSchema();
    expect(academy.setupIssue, isNotNull);
    await expectLater(academy.signUp('طالب جديد', 'student@example.com', 'test-password'), throwsStateError);
    expect(requests, 1);
    academy.dispose(); transport.close(); await client.dispose();
  });

  test('private existing tables can deny anonymous reads without blocking setup', () async {
    var requests = 0;
    final transport = MockClient((request) async {
      requests++;
      return http.Response(jsonEncode({'code': '42501', 'message': 'Permission denied'}), 401, headers: {'content-type': 'application/json'});
    });
    final client = SupabaseClient('https://example.supabase.co', 'test-public-key');
    final academy = Academy(await SharedPreferences.getInstance(), client: client, backendUrl: 'https://example.supabase.co', publishableKey: 'test-public-key', readinessClient: transport);
    await academy.checkSchema();
    expect(academy.setupIssue, isNull);
    expect(requests, 4);
    academy.dispose(); transport.close(); await client.dispose();
  });
}
