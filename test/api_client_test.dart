import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  group('Experience model serialization', () {
    test('fromJson maps snake_case fields and applies defaults', () {
      final experience = Experience.fromJson(const {
        'id': 'exp-123',
        'title': 'Backend Developer Intern',
        'description': 'Built REST APIs with Django.',
        'organization': 'Tokopedia',
        'start_year': 2025,
        'start_month': 6,
        'is_current': true,
        'star_count': 4,
        'logo_url': '/static/images/logo.png',
      });

      expect(experience.id, 'exp-123');
      expect(experience.title, 'Backend Developer Intern');
      expect(experience.category, 'full-time');
      expect(experience.organization, 'Tokopedia');
      expect(experience.startYear, 2025);
      expect(experience.startMonth, 6);
      expect(experience.isCurrent, isTrue);
      expect(experience.starCount, 4);
      expect(experience.displayOrder, 0);
      expect(experience.periodLabel, 'Jun 2025 - Present');
      expect(
        experience.resolvedLogoUrl('http://localhost:8000'),
        'http://localhost:8000/static/images/logo.png',
      );
    });

    test('toJson omits read-only server fields and uses snake_case keys', () {
      const experience = Experience(
        id: 'server-id-should-be-omitted',
        title: 'Teaching Assistant',
        description: 'Assisted PBP students.',
        category: 'part-time',
        organization: 'Fasilkom UI',
        logoStaticPath: 'https://example.com/ui.png',
        logoAlt: 'UI Logo',
        startYear: 2026,
        startMonth: 1,
        endYear: 2026,
        endMonth: 5,
        isCurrent: false,
        starCount: 99,
        isStarred: true,
        logoUrl: 'https://example.com/ui.png',
      );

      final json = experience.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('star_count'), isFalse);
      expect(json.containsKey('is_starred'), isFalse);
      expect(json.containsKey('logo_url'), isFalse);
      expect(json['title'], 'Teaching Assistant');
      expect(json['logo_static_path'], 'https://example.com/ui.png');
      expect(json['start_year'], 2026);
      expect(json['start_month'], 1);
      expect(json['end_year'], 2026);
      expect(json['end_month'], 5);
      expect(json['is_current'], isFalse);
    });
  });

  group('ApiClient Experience endpoints', () {
    test('getExperiences performs public GET and parses list', () async {
      late http.Request capturedRequest;
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode([
            {
              'id': 'uuid-1',
              'title': 'Software Engineer Intern',
              'description': 'Worked on Flutter & Django.',
              'category': 'internship',
              'organization': 'Acme Corp',
              'start_year': 2025,
              'start_month': 7,
              'end_year': 2025,
              'end_month': 12,
              'is_current': false,
            },
          ]),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );
      final experiences = await apiClient.getExperiences();

      expect(capturedRequest.method, 'GET');
      expect(
        capturedRequest.url.toString(),
        'http://localhost:8000/api/v1/experiences/',
      );
      expect(capturedRequest.headers.containsKey('Authorization'), isFalse);
      expect(experiences, hasLength(1));
      expect(experiences.first.id, 'uuid-1');
      expect(experiences.first.categoryLabel, 'Internship');
    });

    test(
      'createExperience sends Token auth header and omits id in payload',
      () async {
        late http.Request capturedRequest;
        final mockClient = MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 'uuid-new',
              'title': 'Research Assistant',
              'description': 'Conducted NLP experiments.',
              'category': 'research',
              'organization': 'IRLab UI',
              'start_year': 2026,
              'start_month': 2,
              'is_current': true,
            }),
            201,
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );
        final created = await apiClient.createExperience(
          const Experience(
            id: 'should-not-be-sent',
            title: 'Research Assistant',
            description: 'Conducted NLP experiments.',
            category: 'research',
            organization: 'IRLab UI',
            startYear: 2026,
            startMonth: 2,
            isCurrent: true,
          ),
          token: 'secret-token-123',
        );

        expect(capturedRequest.method, 'POST');
        expect(
          capturedRequest.url.toString(),
          'http://localhost:8000/api/v1/experiences/',
        );
        expect(
          capturedRequest.headers['Authorization'],
          'Token secret-token-123',
        );
        final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
        expect(body.containsKey('id'), isFalse);
        expect(body['title'], 'Research Assistant');
        expect(created.id, 'uuid-new');
      },
    );

    test('updateExperience sends authenticated PATCH request', () async {
      late http.Request capturedRequest;
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 'uuid-1',
            'title': 'Senior Intern',
            'description': 'Updated description.',
            'category': 'internship',
            'organization': 'Acme Corp',
          }),
          200,
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );
      final updated = await apiClient.updateExperience(
        'uuid-1',
        const Experience(
          id: 'uuid-1',
          title: 'Senior Intern',
          description: 'Updated description.',
          category: 'internship',
          organization: 'Acme Corp',
        ),
        token: 'tok-abc',
      );

      expect(capturedRequest.method, 'PATCH');
      expect(
        capturedRequest.url.toString(),
        'http://localhost:8000/api/v1/experiences/uuid-1/',
      );
      expect(capturedRequest.headers['Authorization'], 'Token tok-abc');
      expect(updated.title, 'Senior Intern');
    });

    test('deleteExperience sends authenticated DELETE request', () async {
      late http.Request capturedRequest;
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );
      await apiClient.deleteExperience('uuid-1', token: 'tok-del');

      expect(capturedRequest.method, 'DELETE');
      expect(
        capturedRequest.url.toString(),
        'http://localhost:8000/api/v1/experiences/uuid-1/',
      );
      expect(capturedRequest.headers['Authorization'], 'Token tok-del');
    });

    test(
      'createExperience throws ApiException(401) on expired token',
      () async {
        final mockClient = MockClient(
          (request) async => http.Response('{"detail":"Invalid token."}', 401),
        );

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: 'http://localhost:8000',
        );

        await expectLater(
          apiClient.createExperience(
            const Experience(title: 'Test', description: 'Desc'),
            token: 'expired-token',
          ),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
          ),
        );
      },
    );

    test('getExperiences throws ApiException on 500 server error', () async {
      final mockClient = MockClient(
        (request) async => http.Response('Internal Server Error', 500),
      );

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );

      await expectLater(
        apiClient.getExperiences(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });
}
