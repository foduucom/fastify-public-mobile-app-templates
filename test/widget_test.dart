import 'package:flutter_test/flutter_test.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';

class MockPageApiService extends PageApiService {
  final Map<String, Map<String, dynamic>?> _mockResponses;

  MockPageApiService(this._mockResponses);

  @override
  Future<Map<String, dynamic>?> getPageData(String endpoint) async {
    if (_mockResponses.containsKey(endpoint)) {
      return _mockResponses[endpoint];
    }
    return null;
  }
}

// pages/terms-conditions
void main() {
  group('PageApiService Tests', () {
    test('getTermsConditions - correctly transforms term-user component to text_bs', () async {
      final mockData = {
        "pages/terms-and-conditions": {
          "_id": "terms_id",
          "name": "Terms and Conditions",
          "slug": "terms-conditions",
          "content": [
            {
              "id": "breadcrumb_id",
              "type": "breadcrumb",
              "fields": {
                "title": "Terms & Conditions",
                "bg_image": "http://example.com/terms.jpg"
              }
            },
            {
              "id": "term_user_id",
              "type": "term-and-condition_term-user",
              "fields": {
                "section_title": "General Conditions",
                "email_address": "support@example.com",
                "term_1_title": "Age Eligibility",
                "term_1_subtitle": "Sub-requirement",
                "term_1_text": "Must be 18 or older.",
                "term_2_title": "User Conduct",
                "term_2_text": "Do not abuse the system."
              }
            }
          ]
        }
      };

      final service = MockPageApiService(mockData);
      final response = await service.getTermsConditions();

      expect(response.status, equals("success"));
      expect(response.data, isNotNull);
      
      final content = response.data!.content;
      expect(content.length, equals(2));
      
      // Breadcrumb check
      expect(content[0].type, equals("breadcrumb"));
      expect(content[0].fields['title'], equals("Terms & Conditions"));
      expect(content[0].fields['bg_image'], equals("http://example.com/terms.jpg"));

      // text_bs check
      expect(content[1].type, equals("text_bs"));
      expect(content[1].id, equals("term_user_id"));
      
      final textblock = content[1].fields['textblock'] as String;
      expect(textblock, contains("General Conditions"));
      expect(textblock, contains("1. Age Eligibility"));
      expect(textblock, contains("Sub-requirement"));
      expect(textblock, contains("Must be 18 or older."));
      expect(textblock, contains("2. User Conduct"));
      expect(textblock, contains("Do not abuse the system."));
      expect(content[1].fields['email_address'], equals("support@example.com"));
    });

    test('getReturnRefundPolicy - correctly combines return-and-refund and return-and-refund-1', () async {
      final mockData = {
        "pages/return-and-refund": {
          "_id": "refund_id",
          "name": "Return and Refund",
          "slug": "return-and-refund",
          "content": [
            {
              "id": "breadcrumb_id",
              "type": "breadcrumb",
              "fields": {
                "title": "Return & Refund Policy",
                "bg_image": "http://example.com/refund.jpg"
              }
            }
          ]
        },
        "pages/return-and-refund-1": {
          "_id": "refund_text_id",
          "name": "Refund Text Block",
          "slug": "return-and-refund-1",
          "content": [
            {
              "id": "text_bs_id",
              "type": "text_bs",
              "data": {
                "textblock": "Our refund policy is simple.",
                "email_address": "refund@example.com"
              }
            }
          ]
        }
      };

      final service = MockPageApiService(mockData);
      final response = await service.getReturnRefundPolicy();

      expect(response.status, equals("success"));
      expect(response.data, isNotNull);

      final content = response.data!.content;
      expect(content.length, equals(2));

      // Breadcrumb check
      expect(content[0].type, equals("breadcrumb"));
      expect(content[0].fields['bg_image'], equals("http://example.com/refund.jpg"));

      // text_bs check
      expect(content[1].type, equals("text_bs"));
      expect(content[1].fields['textblock'], equals("Our refund policy is simple."));
      expect(content[1].fields['email_address'], equals("refund@example.com"));
    });
  });
}
