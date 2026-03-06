/// Funnel analysis (drop-off between ordered steps) — roadmap #580.
library;

/// Step name and count of users who reached it.
class FunnelUtils {
  const FunnelUtils(String name, int count) : _name = name, _count = count;
  final String _name;

  String get name => _name;
  final int _count;

  int get count => _count;

  @override
  String toString() => 'FunnelUtils(name: $_name, count: $_count)';
}

/// Returns conversion rate from step i to i+1 (and overall to last step).
List<double> funnelConversionRates(List<FunnelUtils> steps) {
  if (steps.length < 2) return [];
  final List<double> out = [];
  for (int i = 0; i < steps.length - 1; i++) {
    final int cur = steps[i].count;
    final int next = steps[i + 1].count;
    out.add(cur > 0 ? next / cur : 0);
  }
  return out;
}
