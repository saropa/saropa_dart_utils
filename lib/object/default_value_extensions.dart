import 'package:meta/meta.dart';

/// Default map for null (map null to default value). Roadmap #210.
extension DefaultValueExtensions<T> on T? {
  @useResult
  T orDefault(T defaultValue) => this ?? defaultValue;
}
