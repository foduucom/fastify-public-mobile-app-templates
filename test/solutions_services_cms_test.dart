import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:zouhi/app/data/models/page_model.dart';

void main() {
  group('Solutions & Services CMS Page Parsing', () {
    test('parses solution page components correctly', () {
      final solutionRaw = {
        "_id": "6a92b3c9955c2b5d4722081c",
        "name": "Solution",
        "slug": "solution",
        "content": jsonEncode([
          {
            "id": "4i54aq0dj",
            "type": "about-us_page-header",
            "data": {
              "h1_about_us": "Solutions",
              "header_image": "/images/2026/08/29/logo-728ecf92.webp"
            }
          },
          {
            "id": "kugd4vuvf",
            "type": "solutions_solutions-intro",
            "data": {
              "section_subtitle": "What We Deliver",
              "section_title": "Network Infrastructure Solutions Built Around Your Industry",
              "stat_item": "10+ Industries Served",
              "cta_text": "Talk To Our Team"
            }
          },
          {
            "id": "vh9imqwqw",
            "type": "solutions_industry-solutions",
            "data": {
              "section_title": "Built For Every Environment",
              "link_text": "Explore Products"
            }
          },
          {
            "id": "58p1rt5cn",
            "type": "solutions_solution-capabilities",
            "data": {
              "section_title": "Whatever The Challenge, We Have A Solution"
            }
          },
          {
            "id": "l4lpy0shs",
            "type": "solutions_solution-cta",
            "data": {
              "cta_heading": "Not Sure Which Solution Fits Your Project?",
              "cta_button_text": "Request A Consultation"
            }
          }
        ])
      };

      final page = PageData.fromJson(solutionRaw);
      expect(page.name, 'Solution');
      expect(page.slug, 'solution');
      expect(page.content.length, 5);
      expect(page.content.map((c) => c.type).toList(), [
        'about-us_page-header',
        'solutions_solutions-intro',
        'solutions_industry-solutions',
        'solutions_solution-capabilities',
        'solutions_solution-cta',
      ]);
      expect(page.content[1].fields['section_title'],
          'Network Infrastructure Solutions Built Around Your Industry');
    });

    test('parses services page components correctly', () {
      final servicesRaw = {
        "_id": "6a92d27f3c13c2a7e993ea12",
        "name": "Services",
        "slug": "services",
        "content": jsonEncode([
          {
            "id": "ujod6kbdl",
            "type": "services_page-header",
            "data": {
              "h1_services": "Services",
              "header_image": "/images/2026/08/29/slide-2-73b3aa6d.webp"
            }
          },
          {
            "id": "z4bl1dezg",
            "type": "services_services-intro",
            "data": {
              "section_title": "Real Support, Before And After The Sale",
              "cta_text": "Contact Support"
            }
          },
          {
            "id": "rrref6hnq",
            "type": "services_core-services-tabs",
            "data": {
              "section_title": "Our Core Services",
              "tab1_heading": "Technical Support",
              "tab2_heading": "Installation & Deployment",
              "tab3_heading": "Warranty & RMA"
            }
          },
          {
            "id": "183s60in3",
            "type": "about-us_why-choose",
            "data": {
              "feature_title": "Certified Quality"
            }
          },
          {
            "id": "gls0f3fvo",
            "type": "services_services-cta",
            "data": {
              "cta_button_text": "Get In Touch"
            }
          }
        ])
      };

      final page = PageData.fromJson(servicesRaw);
      expect(page.name, 'Services');
      expect(page.slug, 'services');
      expect(page.content.length, 5);
      expect(page.content.map((c) => c.type).toList(), [
        'services_page-header',
        'services_services-intro',
        'services_core-services-tabs',
        'about-us_why-choose',
        'services_services-cta',
      ]);
      expect(page.content[2].fields['tab1_heading'], 'Technical Support');
    });
  });
}
