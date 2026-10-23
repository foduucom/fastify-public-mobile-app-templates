import 'package:flutter_test/flutter_test.dart';
import 'package:zouhi/app/data/category_index_service.dart';

Map node(String id, String name, {List children = const [], Map? extra}) => {
      '_id': id,
      'name': name,
      'slug': name.toLowerCase().replaceAll(' ', '-'),
      'children': children,
      'owner_id': {'remember_tokens': ['secret']},
      ...?extra,
    };

void main() {
  // Mirrors the real API: get-tree is 2 levels, level 3 is bare IDs.
  Future<dynamic> fakeFetch(String path, {Set<String> fail = const {}}) async {
    if (path == 'category/get-tree/product') {
      return {
        'data': {
          'data': [
            node('root', 'Fibre Cable', children: [
              node('fpc', 'Fiber Patch Cables', children: ['c1', 'c2', 'c3']),
            ]),
          ]
        }
      };
    }
    if (path == 'category/get-tree/material') return {'data': []};
    final id = path.split('/').last;
    if (fail.contains(id)) throw Exception('boom');
    final names = {
      'c1': 'Patch Cables Custom',
      'c2': 'Uniboot Cables',
      'c3': 'OM1/OM2 Multimode',
    };
    return {'status': 'success', 'data': node(id, names[id]!)};
  }

  CategoryIndexService make({Set<String> fail = const {}, Map? store}) {
    final s = store ?? {};
    return CategoryIndexService(
      fetcher: (p) => fakeFetch(p, fail: fail),
      read: (k) => s[k],
      write: (k, v) => s[k] = v,
    );
  }

  test('hydrates bare-ID children with breadcrumbs', () async {
    final r = await make().buildIndex();
    expect(r.complete, true);
    expect(r.entries.map((e) => e.name),
        containsAll(['Fibre Cable', 'Fiber Patch Cables', 'Uniboot Cables']));
    final c = r.entries.firstWhere((e) => e.id == 'c1');
    expect(c.breadcrumb, 'Fibre Cable › Fiber Patch Cables');
    expect(c.parentName, 'Fiber Patch Cables');
    expect(c.depth, 2);
  });

  test('one failing ID keeps the rest and marks index incomplete', () async {
    final svc = make(fail: {'c2'});
    final r = await svc.buildIndex();
    expect(r.complete, false);
    expect(r.entries.any((e) => e.id == 'c1'), true);
    expect(r.entries.any((e) => e.id == 'c2'), false);
  });

  test('incomplete index is not persisted; complete one is', () async {
    final partial = <String, dynamic>{};
    await make(fail: {'c2'}, store: partial).ensureLoaded();
    expect(partial.containsKey('category_index_v1'), false);

    final full = <String, dynamic>{};
    await make(store: full).ensureLoaded();
    expect(full['category_index_v1'], isNotEmpty);
  });

  test('duplicate / cyclic ids are only added once', () async {
    final svc = CategoryIndexService(
      fetcher: (p) async {
        if (p == 'category/get-tree/product') {
          return [node('a', 'A', children: ['b'])];
        }
        if (p.endsWith('/b')) return {'data': node('b', 'B', children: ['a', 'b'])};
        return [];
      },
      read: (_) => null,
      write: (_, __) {},
    );
    final r = await svc.buildIndex();
    expect(r.entries.map((e) => e.id).toList(), ['a', 'b']);
  });

  test('cache is served on next ensureLoaded without network', () async {
    final store = <String, dynamic>{};
    await make(store: store).ensureLoaded();
    var calls = 0;
    final second = CategoryIndexService(
      fetcher: (p) async {
        calls++;
        return null;
      },
      read: (k) => store[k],
      write: (k, v) => store[k] = v,
    );
    final e = await second.ensureLoaded();
    expect(calls, 0);
    expect(e.length, 5);
  });
}
