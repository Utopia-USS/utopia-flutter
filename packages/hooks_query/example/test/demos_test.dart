import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:utopia_hooks_query/utopia_hooks_query.dart';
import 'package:utopia_hooks_query_example/api.dart';
import 'package:utopia_hooks_query_example/demos/basic_query_demo.dart';
import 'package:utopia_hooks_query_example/demos/dependent_query_demo.dart';
import 'package:utopia_hooks_query_example/demos/global_fetching_demo.dart';
import 'package:utopia_hooks_query_example/demos/infinite_scroll_demo.dart';
import 'package:utopia_hooks_query_example/demos/mutation_demo.dart';
import 'package:utopia_hooks_query_example/demos/optimistic_demo.dart';
import 'package:utopia_hooks_query_example/demos/pagination_demo.dart';
import 'package:utopia_hooks_query_example/demos/polling_demo.dart';

/// Routes JSONPlaceholder requests to canned responses so the demos can be
/// driven without a network. Post titles encode their id + page for asserts.
MockClient buildMockClient() {
  Map<String, dynamic> post(int id, {int userId = 1}) =>
      {'id': id, 'userId': userId, 'title': 'Post $id', 'body': 'Body $id'};

  return MockClient((request) async {
    final path = request.url.path;
    final q = request.url.queryParameters;

    if (request.method == 'POST' && path == '/posts') {
      return http.Response(jsonEncode(post(101)), 201);
    }
    if (request.method == 'PATCH' && path.startsWith('/todos/')) {
      return http.Response(request.body, 200);
    }
    if (path == '/posts/1') {
      return http.Response(jsonEncode(post(1)), 200);
    }
    if (path == '/posts') {
      if (q['userId'] != null) {
        final uid = int.parse(q['userId']!);
        return http.Response(
          jsonEncode([for (var i = 1; i <= 3; i++) post(uid * 10 + i, userId: uid)]),
          200,
        );
      }
      final page = int.parse(q['_page'] ?? '1');
      final limit = int.parse(q['_limit'] ?? '10');
      final start = (page - 1) * limit + 1;
      return http.Response(
        jsonEncode([for (var i = 0; i < limit; i++) post(start + i)]),
        200,
      );
    }
    if (path == '/users') {
      return http.Response(
        jsonEncode([
          for (var i = 1; i <= 3; i++) {'id': i, 'name': 'User $i', 'email': 'u$i@x.io'}
        ]),
        200,
      );
    }
    if (path == '/todos') {
      return http.Response(
        jsonEncode([
          for (var i = 1; i <= 5; i++) {'id': i, 'title': 'Todo $i', 'completed': false}
        ]),
        200,
      );
    }
    return http.Response('not found: $path', 404);
  });
}

late QueryClient client;

Future<void> pumpDemo(WidgetTester tester, Widget demo) async {
  api = PlaceholderApi(client: buildMockClient());
  await tester.pumpWidget(
    QueryClientProvider.value(
      client,
      child: MaterialApp(home: demo),
    ),
  );
}

/// Unmounts the tree and advances the clock past the mutation/gc timers so the
/// test ends with no pending timers.
Future<void> finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(minutes: 6));
}

void main() {
  setUp(() {
    client = QueryClient(
      defaultQueryOptions: DefaultQueryOptions(gcDuration: GcDuration.infinity),
    );
  });

  tearDown(() => client.clear());

  testWidgets('basic query renders fetched post', (tester) async {
    await pumpDemo(tester, const BasicQueryDemo());
    await tester.pumpAndSettle();
    expect(find.text('Post 1'), findsOneWidget);
    expect(find.text('Body 1'), findsOneWidget);
  });

  testWidgets('pagination moves to next page', (tester) async {
    await pumpDemo(tester, const PaginationDemo());
    await tester.pumpAndSettle();
    expect(find.text('Page 1 / 10'), findsOneWidget);
    expect(find.text('Post 1'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 / 10'), findsOneWidget);
    expect(find.text('Post 11'), findsOneWidget); // page 2 starts at id 11
  });

  testWidgets('infinite scroll loads more pages', (tester) async {
    await pumpDemo(tester, const InfiniteScrollDemo());
    await tester.pumpAndSettle();
    expect(find.text('Post 1'), findsOneWidget);
    expect(find.text('Post 11'), findsNothing); // page 2 not fetched yet

    // Scrolling toward the bottom triggers the auto load-more; page 2 (ids
    // 11-20) is fetched and Post 11 becomes reachable.
    await tester.scrollUntilVisible(find.text('Post 11'), 400);
    await tester.pumpAndSettle();
    expect(find.text('Post 11'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('mutation creates a post', (tester) async {
    await pumpDemo(tester, const MutationDemo());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'My new post');
    await tester.pump();
    await tester.tap(find.text('Create post'));
    await tester.pumpAndSettle();

    expect(find.text('Created post #101'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('optimistic toggle flips checkbox then rolls back on failure',
      (tester) async {
    await pumpDemo(tester, const OptimisticDemo());
    await tester.pumpAndSettle();

    final firstCheckbox = find.byType(CheckboxListTile).first;
    expect(tester.widget<CheckboxListTile>(firstCheckbox).value, isFalse);

    // Turn on fail mode, then toggle: optimistic flip then rollback to false.
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(firstCheckbox).value, isFalse);
    await finish(tester);
  });

  testWidgets('polling fetches at least once', (tester) async {
    await pumpDemo(tester, const PollingDemo());
    await tester.pump(); // first fetch
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Fetches:'), findsOneWidget);

    // Unmount to cancel the refetch timer before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('dependent query runs only after selecting a user', (tester) async {
    await pumpDemo(tester, const DependentQueryDemo());
    await tester.pumpAndSettle();
    expect(find.text('Select a user to load their posts'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('User 1').last);
    await tester.pumpAndSettle();
    expect(find.text('Post 11'), findsOneWidget); // user 1 -> ids 11,12,13
  });

  testWidgets('global fetching indicator shows counts', (tester) async {
    await pumpDemo(tester, const GlobalFetchingDemo());
    await tester.pumpAndSettle();
    expect(find.text('3 loaded'), findsWidgets); // users + todos both have >0
  });
}
