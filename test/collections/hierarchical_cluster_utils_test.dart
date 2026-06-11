import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/hierarchical_cluster_utils.dart';

void main() {
  group('euclideanDistance', () {
    test('should return 0 for identical points', () {
      expect(euclideanDistance(<double>[1, 2, 3], <double>[1, 2, 3]), 0);
    });

    test('should compute the classic 3-4-5 distance', () {
      expect(euclideanDistance(<double>[0, 0], <double>[3, 4]), 5);
    });

    test('should be symmetric', () {
      expect(
        euclideanDistance(<double>[1, 5], <double>[4, 1]),
        euclideanDistance(<double>[4, 1], <double>[1, 5]),
      );
    });

    test('should ignore extra coordinates on the longer vector', () {
      // Only the shared length is compared, so a ragged input cannot throw.
      expect(euclideanDistance(<double>[0, 0], <double>[3, 4, 99]), 5);
    });

    test('should handle empty vectors as zero distance', () {
      expect(euclideanDistance(<double>[], <double>[]), 0);
    });

    test('should handle negative coordinates', () {
      expect(euclideanDistance(<double>[-3, 0], <double>[0, -4]), 5);
    });
  });

  group('hierarchicalCluster', () {
    test('should return empty for zero points (N=0)', () {
      expect(hierarchicalCluster(<List<double>>[]), isEmpty);
    });

    test('should return empty for a single point (N=1)', () {
      expect(
        hierarchicalCluster(<List<double>>[
          <double>[0],
        ]),
        isEmpty,
      );
    });

    test('should emit n-1 merge steps', () {
      final List<MergeStep> steps = hierarchicalCluster(<List<double>>[
        <double>[0],
        <double>[1],
        <double>[10],
        <double>[11],
      ]);
      expect(steps, hasLength(3));
    });

    test('should merge the two closest points first', () {
      // 0 and 0.1 are nearest, so the first merge joins leaves 0 and 1.
      final List<MergeStep> steps = hierarchicalCluster(<List<double>>[
        <double>[0],
        <double>[0.1],
        <double>[9],
      ]);
      expect(<int>[steps.first.a, steps.first.b], containsAll(<int>[0, 1]));
      expect(steps.first.distance, closeTo(0.1, 1e-9));
    });

    test('should record distance 0 when merging identical points', () {
      final List<MergeStep> steps = hierarchicalCluster(<List<double>>[
        <double>[5, 5],
        <double>[5, 5],
      ]);
      expect(steps.single.distance, 0);
      expect(steps.single.size, 2);
    });

    test('should grow cluster size as merges accumulate', () {
      final List<MergeStep> steps = hierarchicalCluster(<List<double>>[
        <double>[0],
        <double>[0],
        <double>[0],
      ]);
      // First merge yields size 2, the second absorbs the third for size 3.
      expect(steps.last.size, 3);
    });

    test('single linkage should chain a bridged gap', () {
      // Points 0,1,2,10: single linkage merges via nearest member, so the
      // 1<->2 bridge can attach the {0,1,2} chain before the far point.
      final List<MergeStep> steps = hierarchicalCluster(
        <List<double>>[
          <double>[0],
          <double>[1],
          <double>[2],
          <double>[10],
        ],
        linkage: ClusterLinkage.single,
      );
      expect(steps.last.distance, greaterThanOrEqualTo(steps.first.distance));
    });

    test('complete linkage should produce non-decreasing merge distances', () {
      final List<MergeStep> steps = hierarchicalCluster(
        <List<double>>[
          <double>[0],
          <double>[1],
          <double>[5],
          <double>[6],
        ],
        linkage: ClusterLinkage.complete,
      );
      for (int i = 1; i < steps.length; i++) {
        expect(steps[i].distance, greaterThanOrEqualTo(steps[i - 1].distance));
      }
    });
  });

  group('cutClustersByCount', () {
    test('should return empty for zero points', () {
      expect(cutClustersByCount(const <MergeStep>[], 0, 2), isEmpty);
    });

    test('should put every point in cluster 0 when k=1', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[1],
        <double>[2],
      ];
      final List<int> labels = cutClustersByCount(hierarchicalCluster(pts), pts.length, 1);
      expect(labels, <int>[0, 0, 0]);
    });

    test('should give each point its own cluster when k=n', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[5],
        <double>[10],
      ];
      final List<int> labels = cutClustersByCount(hierarchicalCluster(pts), pts.length, 3);
      // No merges applied, so labels are all distinct.
      expect(labels.toSet(), hasLength(3));
    });

    test('should split two well-separated groups into k=2', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0, 0],
        <double>[0.1, 0],
        <double>[10, 10],
        <double>[10.1, 10],
      ];
      final List<int> labels = cutClustersByCount(hierarchicalCluster(pts), pts.length, 2);
      // The two near pairs share a label; the groups differ from each other.
      expect(labels[0], labels[1]);
      expect(labels[2], labels[3]);
      expect(labels[0], isNot(labels[2]));
    });

    test('should clamp k above n to n distinct clusters', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[9],
      ];
      final List<int> labels = cutClustersByCount(hierarchicalCluster(pts), pts.length, 99);
      expect(labels.toSet(), hasLength(2));
    });

    test('should clamp k below 1 to a single cluster', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[1],
      ];
      final List<int> labels = cutClustersByCount(hierarchicalCluster(pts), pts.length, 0);
      expect(labels, <int>[0, 0]);
    });

    test('should produce dense gap-free labels', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[0.1],
        <double>[5],
        <double>[5.1],
        <double>[20],
      ];
      final List<int> labels = cutClustersByCount(hierarchicalCluster(pts), pts.length, 3);
      expect(labels.toSet(), <int>{0, 1, 2});
    });
  });

  group('cutClustersByDistance', () {
    test('should return empty for zero points', () {
      expect(cutClustersByDistance(const <MergeStep>[], 0, 1), isEmpty);
    });

    test('should keep all points separate below the smallest gap', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[1],
        <double>[2],
      ];
      // A threshold of 0.5 joins nothing, so every point stands alone.
      final List<int> labels = cutClustersByDistance(hierarchicalCluster(pts), pts.length, 0.5);
      expect(labels.toSet(), hasLength(3));
    });

    test('should merge points closer than the threshold', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[0.2],
        <double>[10],
      ];
      final List<int> labels = cutClustersByDistance(hierarchicalCluster(pts), pts.length, 1);
      expect(labels[0], labels[1]);
      expect(labels[0], isNot(labels[2]));
    });

    test('should treat a merge exactly at the threshold as not joined', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[1],
      ];
      // Distance is exactly 1.0; strict-less-than leaves the pair unmerged.
      final List<int> labels = cutClustersByDistance(hierarchicalCluster(pts), pts.length, 1);
      expect(labels[0], isNot(labels[1]));
    });

    test('should collapse everything under a large threshold', () {
      final List<List<double>> pts = <List<double>>[
        <double>[0],
        <double>[5],
        <double>[100],
      ];
      final List<int> labels = cutClustersByDistance(hierarchicalCluster(pts), pts.length, 1000);
      expect(labels, <int>[0, 0, 0]);
    });
  });
}
