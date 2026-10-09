---
name: tests
description: Use this when writing tests. Lists styles, rules, and guidelines for tests and planning tests.
---

# Test Writing Guidelines

Use `flutter_test` and `package:flutter_test/flutter_test.dart`.

## Scope

Test:
- All public methods
- All method arguments
- All method return types / scenarios
- Constructors only if they have non-trivial logic

Skip:
- Private methods
- Getters and setters (unless they have non-trivial logic)

## Directory Structure

- Categorize tests into `unit`, `integration`, and `end-to-end` tests
- Mirror the source file path under `test/{category}` (e.g. `lib/foo/bar/baz.dart` → `test/unit/foo/bar/baz_test.dart`)
- Mocks, fakes, stubs, dummies, helper methods live in `test/support`

## Test Grouping Structure

Test files must always have 3 levels of grouping before tests.
The 3rd level is especially useful during planning to discover all the cases to be considered.

For truly standalone test scenarios, you may have a 3rd level group with just the one test.

For top level functions not in a class, the level 1 = 'standalone'.

### Non-widget tests groups

1. group level 1: top level symbols: class | 'standalone' for symbols not in a class
2. group level 2: methods / callables on a class / functions
3. group level 3: group of scenarios / theme of test collection (typically usage oriented)
4. actual tests

### Widget tests groups

1. group level 1: top level symbols: class | 'standalone' for symbols not in a class
2. group level 2: attribute of interest: render | interactions | lifecycle
3. group level 3: group of scenarios / theme of test collection (typically usage oriented)
4. actual tests

### Deriving groups

Derive groups from the member's inputs:
- collection/map argument → cardinalities: none / one / multiple
- match or dispatch behaviour → match / no match
- independent arguments → cross product, plus a `mixed` group covering orderings
- one `errors` group, one test per failure mode

### Combinations

When a member composes with others or itself, cover the full matrix (configs × inputs), not samples. Enumerate from every subject's perspective — each owns its row; don't deduplicate shared pairs.

## Naming

- Group names:
  - level 1: 'class ClassName' | 'standalone'
  - level 2: 
    - non widget tests: 'method methodName' | 'function functionName' | 'getter getterName' | 'operator operator-symbol' | etc
    - widget tests: 'render' | 'interactions' | 'lifecycle'
  - level 3: 'group description' (do not skip this group level even if it only includes 1 test)
- Test names: very short plain english description of the scenario or purpose, never include the expectation
  - do:
    - `multiple newlines`
    - `line after newline`
    - `column after newline`
  - don't:
    - `multiple newlines increment line correctly`
    - `token after newline is on line 2`
    - `newline resets column to 1 for next token`
- Subject variable: named after the type in lowerCamelCase (e.g. `token`, `lexer`)
- Comparison variable: `other` (in cases like ==, or hashCode)
- Captured expression: `actual`
- Expected value: `expected`

## Assertions

- Prefer `expect(actual, equals(expected))`
- Avoid `isNull`, `isNotNull`, `contains`, `isTrue`, etc (due to test driven methodology)
- Do not use bare `assert()`
- Keep assertions simple, expect the entire result, don't test properties of the result

## Dependencies, Stubs, and Mocks

- Unit tests: use stubs, the names should be prefixed with `stub`
- Integration tests: use real dependencies — the real collaborators you pass in, not code built on top
- Test the unit, not its consumers: compose a generic/reusable member with stubs or other instances of the same abstraction, never a specific downstream consumer (except when testing grammar entities)

## Other

- If the test result type does not implement value based equality, ask the user if this should be implemented
- prefer literal code over abstractions even if it's more code
- before writing a test, plan the groups and test names

## Examples

### Test File Structure

```dart
void main() {
  group('class StaticLexicalRule', () {
    group('method match', () {
      group('matches', () {
        test('keyword matches', () {
          final lexicalRule = StaticLexicalRule(name: 'abc', lexeme: 'abc');
          final actual = lexicalRule.match('abc', 1, 0);
          final expected = Token(
            lexicalRule: StaticLexicalRule(name: 'abc', lexeme: 'abc'),
            lexeme: 'abc',
            line: 1,
            column: 0,
          );
          expect(actual, equals(expected));
        });
        test('keyword matches at start of input', () {
          final lexicalRule = StaticLexicalRule(name: 'abc', lexeme: 'abc');
          final actual = lexicalRule.match('abcdef', 1, 0);
          final expected = Token(
            lexicalRule: StaticLexicalRule(name: 'abc', lexeme: 'abc'),
            lexeme: 'abc',
            line: 1,
            column: 0,
          );
          expect(actual, equals(expected));
        });
        test('symbol matches', () {
          final lexicalRule = StaticLexicalRule(name: 'equals', lexeme: '=');
          final actual = lexicalRule.match('=', 1, 0);
          final expected = Token(
            lexicalRule: StaticLexicalRule(name: 'equals', lexeme: '='),
            lexeme: '=',
            line: 1,
            column: 0,
          );
          expect(actual, equals(expected));
        });
        test('symbol matches at start of input', () {
          final lexicalRule = StaticLexicalRule(name: 'equals', lexeme: '=');
          final actual = lexicalRule.match('==', 1, 0);
          final expected = Token(
            lexicalRule: StaticLexicalRule(name: 'equals', lexeme: '='),
            lexeme: '=',
            line: 1,
            column: 0,
          );
          expect(actual, equals(expected));
        });
      });

      group('does not match', () {
        test('keyword does not match', () {
          final lexicalRule = StaticLexicalRule(name: 'abc', lexeme: 'abc');
          final actual = lexicalRule.match('123', 1, 0);
          const expected = null;
          expect(actual, equals(expected));
        });
        test('symbol does not match', () {
          final lexicalRule = StaticLexicalRule(name: 'equals', lexeme: '=');
          final actual = lexicalRule.match('!', 1, 0);
          const expected = null;
          expect(actual, equals(expected));
        });
        test('symbol does not match when present later in input', () {
          final lexicalRule = StaticLexicalRule(name: 'equals', lexeme: '=');
          final actual = lexicalRule.match('!=', 1, 0);
          const expected = null;
          expect(actual, equals(expected));
        });
        test('empty lexeme does not match', () {
          final lexicalRule = StaticLexicalRule(name: 'empty', lexeme: '');
          final actual = lexicalRule.match('', 1, 0);
          const expected = null;
          expect(actual, equals(expected));
        });
      });

      group('line and column numbers', () {
        test('0 line and column numbers', () {
          final lexicalRule = StaticLexicalRule(name: 'abc', lexeme: 'abc');
          final actual = lexicalRule.match('abc', 0, 0);
          final expected = Token(
            lexicalRule: StaticLexicalRule(name: 'abc', lexeme: 'abc'),
            lexeme: 'abc',
            line: 0,
            column: 0,
          );
          expect(actual, equals(expected));
        });
        test('non-zero line and column numbers', () {
          final lexicalRule = StaticLexicalRule(name: 'abc', lexeme: 'abc');
          final actual = lexicalRule.match('abc', 2, 5);
          final expected = Token(
            lexicalRule: StaticLexicalRule(name: 'abc', lexeme: 'abc'),
            lexeme: 'abc',
            line: 2,
            column: 5,
          );
          expect(actual, equals(expected));
        });
        test('large line and column numbers', () {
          final lexicalRule = StaticLexicalRule(name: 'abc', lexeme: 'abc');
          final actual = lexicalRule.match('abc', 999999, 999999);
          final expected = Token(
            lexicalRule: StaticLexicalRule(name: 'abc', lexeme: 'abc'),
            lexeme: 'abc',
            line: 999999,
            column: 999999,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        // ...
      });
      group('not equals', () {
        // ...
      });
    });

    group('hashCode', () {
      group('equals', () {
        // ...
      });
      group('not equals', () {
        // ...
      });
    });

    group('toString', () {
      // ...
    });
  });
}
```

### Unit Test

```dart
  // test return value
  test('keyword matches', () {
    final lexicalRule = StaticLexicalRule(name: 'abc', lexeme: 'abc');
    final actual = lexicalRule.match('abc', 1, 0);
    final expected = Token(
      lexicalRule: StaticLexicalRule(name: 'abc', lexeme: 'abc'),
      lexeme: 'abc',
      line: 1,
      column: 0,
    );
    expect(actual, equals(expected));
  });

  // test exception throwing
  test('does not throw on first call', () {
    final loopLimit = LoopLimit(3, () => CustomException('limit exceeded'));
    void event() => loopLimit.check();
    expect(event, returnsNormally);
  });
  test('throws when max iterations exceeded', () {
    final loopLimit = LoopLimit(3, () => CustomException('limit exceeded'));
    void event() {
      loopLimit.check();
      loopLimit.check();
      loopLimit.check();
      loopLimit.check();
    }
    expect(event, throwsA(isA<CustomException>()));
  });
```

# Steps for Reviewing Tests

1. does the style comply with the guidelines?
2. is the test well structured and organized?
3. are all public methods, arguments, and return types tested?
4. are all branches & code paths tested?
5. are tests true unit tests (unless the group is marked 'integration')?

# Steps for Writing Tests

1. Examine the source code
2. List all classes, methods, arguments, return types, and logical branches in the source code (the prompt may narrow this down to a subset of classes, methods, etc)
3. List unit, integration, and end-to-end categories applicable
    (usually only one or two are needed for a file)
4. Plan the test categories, groups, and test names according to the guidelines
5. Present the test plan to the user and ask for confirmation before writing any code
    (you keep skipping this for some reason, please don't skip it)
6. Write the tests according to the plan and guidelines
7. Run tests
8. If any tests fail, 
    either fix the test 
    or present the source code bug to the user and ask for confirmation before fixing
9. Review your own tests
