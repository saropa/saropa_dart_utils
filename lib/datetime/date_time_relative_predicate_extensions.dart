import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_time_comparison_extensions.dart';
import 'package:saropa_dart_utils/string/string_text_extensions.dart';

part 'date_time_relative_predicate_predicates.dart';
part 'date_time_relative_predicate_format.dart';
part 'date_time_relative_predicate_messages.dart';

/// Terse token returned for an exact instant match (`this == now`) and as the
/// terse rendering of the sub-45-second "a moment" band.
const String relativeNowTime = 'now';

/// Suffix appended when this date is before [DateTime.now] / the supplied now.
const String relativeTimeSuffixPast = 'ago';

/// Suffix appended when this date is after [DateTime.now] / the supplied now.
const String relativeTimeSuffixFuture = 'from now';
