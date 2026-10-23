/// Drops payload fields the UI never reads but that make API responses huge
/// (and, for `owner_id`, carry other users' PII and session tokens).
///
/// Run on list responses before they are held in memory or written to
/// GetStorage, which re-encodes its whole file on every write.
const _heavyKeys = {
  'owner_id',
  'reseller_id',
  'remember_tokens',
  'long_content',
  'meta_title',
  'meta_description',
  'meta_keywords',
};

dynamic stripHeavyFields(dynamic node) {
  if (node is List) {
    return node.map(stripHeavyFields).toList();
  }
  if (node is Map) {
    final out = <String, dynamic>{};
    node.forEach((k, v) {
      if (_heavyKeys.contains(k)) return;
      out[k.toString()] = stripHeavyFields(v);
    });
    return out;
  }
  return node;
}

List stripHeavyList(List input) => stripHeavyFields(input) as List;
