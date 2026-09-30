class RingDeduper {
  RingDeduper._();

  static final Set<String> _ids = <String>{};

  static bool claim(String id) {
    if (id.isEmpty) return true;
    if (!_ids.add(id)) return false;
    if (_ids.length > 40) {
      _ids.remove(_ids.first);
    }
    return true;
  }

  static void reset() => _ids.clear();
}
