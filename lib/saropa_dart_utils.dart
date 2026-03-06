/// Saropa Dart Utils - Boilerplate reduction tools and human-readable
/// extension methods by Saropa.
library;

// Base64 utilities
export 'base64/base64_utils.dart';

// Bool extensions
export 'bool/bool_iterable_extensions.dart';
export 'bool/bool_string_extensions.dart';

// DateTime extensions and utilities
export 'datetime/date_constant_extensions.dart';
export 'datetime/date_constants.dart';
export 'datetime/date_time_arithmetic_extensions.dart';
export 'datetime/date_time_bounds_extensions.dart';
export 'datetime/date_time_business_days_utils.dart';
export 'datetime/date_time_calendar_extensions.dart';
export 'datetime/date_time_clamp_extensions.dart';
export 'datetime/date_time_comparison_extensions.dart';
export 'datetime/date_time_extensions.dart';
export 'datetime/date_time_fiscal_extensions.dart';
export 'datetime/date_time_list_extensions.dart';
export 'datetime/date_time_nullable_extensions.dart';
export 'datetime/date_time_overlap_utils.dart';
export 'datetime/date_time_range_utils.dart';
export 'datetime/date_time_relative_utils.dart';
export 'datetime/date_time_utils.dart';
export 'datetime/date_time_week_extensions.dart';
export 'datetime/date_time_timezone_extensions.dart';
export 'datetime/duration_format_utils.dart';
export 'datetime/duration_parse_utils.dart';
export 'datetime/time_emoji_utils.dart';
export 'datetime/date_time_more_extensions.dart';
export 'datetime/time_rounding_utils.dart';
export 'datetime/relative_date_bucket_utils.dart';
export 'datetime/period_split_utils.dart';
export 'datetime/injectable_clock_utils.dart';

// Double extensions
export 'double/double_extensions.dart';
export 'double/double_iterable_extensions.dart';

// Enum extensions
export 'enum/enum_iterable_extensions.dart';

// Gesture utilities
export 'gesture/swipe_properties.dart';

// Hex utilities
export 'hex/hex_utils.dart';

// HTML utilities
export 'html/html_utils.dart';

// Int extensions and utilities
export 'int/int_extensions.dart';
export 'int/int_iterable_extensions.dart';
export 'int/int_nullable_extensions.dart';
export 'int/int_string_extensions.dart';
export 'int/int_utils.dart';

// Iterable extensions
export 'iterable/comparable_iterable_extensions.dart';
export 'iterable/iterable_extensions.dart';
export 'iterable/iterable_flatten_extensions.dart';
export 'iterable/iterable_list_ops_extensions.dart';
export 'iterable/occurrence.dart';
export 'iterable/run_length_utils.dart';

// Collections (advanced algorithms, roadmap 441+)
export 'collections/lis_utils.dart';
export 'collections/lcs_substring_utils.dart';
export 'collections/sliding_window_aggregate_utils.dart';
export 'collections/reservoir_sampling_utils.dart';
export 'collections/interval_scheduling_utils.dart';
export 'collections/trie_utils.dart';
export 'collections/disjoint_set_utils.dart';
export 'collections/damerau_levenshtein_utils.dart';
export 'collections/knapsack_utils.dart';
export 'collections/bloom_filter_utils.dart';
export 'collections/nway_merge_utils.dart';
export 'collections/ring_buffer_utils.dart';
export 'collections/multiset_utils.dart';
export 'collections/online_mean_variance_utils.dart';
export 'collections/histogram_utils.dart';
export 'collections/difference_array_utils.dart';
export 'collections/bimap_utils.dart';
export 'collections/kmeans_utils.dart';
export 'collections/weighted_interval_utils.dart';
export 'collections/greedy_set_cover_utils.dart';
export 'collections/chunk_overlap_utils.dart';
export 'collections/pivot_unpivot_utils.dart';
export 'collections/run_detection_utils.dart';
export 'collections/stream_quantile_utils.dart';
export 'collections/inverted_index_utils.dart';
export 'collections/top_k_heap_utils.dart';
export 'collections/time_bucket_utils.dart';
export 'collections/multi_criteria_sort_utils.dart';
export 'collections/columnar_view_utils.dart';
export 'collections/window_functions_utils.dart';
export 'collections/balanced_partition_utils.dart';
export 'collections/bin_packing_utils.dart';
export 'collections/prefix_frequency_utils.dart';
export 'collections/rolling_hash_utils.dart';
export 'collections/dedup_set_expiry_utils.dart';
export 'collections/string_pool_utils.dart';
export 'collections/row_column_table_utils.dart';
export 'collections/priority_map_utils.dart';
export 'collections/seeded_shuffle_utils.dart';

// Graph (roadmap 531+)
export 'graph/graph_utils.dart';
export 'graph/bfs_dfs_utils.dart';
export 'graph/dijkstra_utils.dart';
export 'graph/astar_utils.dart';
export 'graph/connected_components_utils.dart';
export 'graph/line_simplify_utils.dart';
export 'graph/hierarchy_utils.dart';
export 'graph/floyd_warshall_utils.dart';
export 'graph/topological_sort_utils.dart';
export 'graph/mst_utils.dart';
export 'graph/critical_path_utils.dart';
export 'graph/bipartite_utils.dart';
export 'graph/tree_utils.dart';
export 'graph/graph_diff_utils.dart';
export 'graph/dag_scheduler_utils.dart';

// Stats (roadmap 561+)
export 'stats/robust_stats_utils.dart' hide median;
export 'stats/moving_average_utils.dart';
export 'stats/data_normalization_utils.dart';
export 'stats/quantile_summary_utils.dart';
export 'stats/correlation_utils.dart';
export 'stats/linear_regression_utils.dart';
export 'stats/bucketed_aggregate_utils.dart';
export 'stats/confidence_interval_utils.dart';
export 'stats/funnel_utils.dart';
export 'stats/outlier_mad_utils.dart';
export 'stats/percentile_rank_utils.dart' hide percentile;
export 'stats/retention_utils.dart';
export 'stats/sampling_utils.dart';
export 'stats/metric_rollup_utils.dart';
export 'stats/log_transform_utils.dart';
export 'stats/feature_encoding_utils.dart';

// JSON utilities
export 'json/json_epoch_scale.dart';
export 'json/json_iterables_utils.dart';
export 'json/json_type_utils.dart';
export 'json/json_utils.dart';

// List extensions
export 'list/list_extensions.dart';
export 'list/list_binary_search_extensions.dart';
export 'list/list_rotate_extensions.dart';
export 'list/list_string_extensions.dart';
export 'list/list_nullable_extensions.dart';
export 'list/list_of_list_extensions.dart';
export 'list/make_list_extensions.dart';
export 'list/unique_list_extensions.dart';
export 'list/list_lower_extensions.dart';
export 'list/list_default_empty_extensions.dart';

// Map extensions and utilities
export 'map/deep_equality_utils.dart';
export 'map/map_deep_merge_extensions.dart';
export 'map/map_deep_utils.dart';
export 'map/map_default_extensions.dart';
export 'map/map_diff_utils.dart';
export 'map/map_extensions.dart';
export 'map/map_flatten_extensions.dart';
export 'map/map_from_entries_extensions.dart';
export 'map/map_invert_extensions.dart';
export 'map/map_merge_extensions.dart';
export 'map/map_nested_extensions.dart';
export 'map/map_pick_omit_extensions.dart';
export 'map/map_transform_extensions.dart';
export 'map/map_nullable_extensions.dart';
export 'map/map_more_extensions.dart';

// Num extensions and utilities
export 'num/math_utils.dart';
export 'num/num_clamp_extensions.dart';
export 'num/num_compact_parse_extensions.dart';
export 'num/num_extensions.dart';
export 'num/num_factorial_utils.dart';
export 'num/num_format_extensions.dart';
export 'num/num_iterable_extensions.dart';
export 'num/num_lerp_utils.dart';
export 'num/num_locale_utils.dart';
export 'num/num_min_max_utils.dart';
export 'num/num_modulo_utils.dart';
export 'num/num_prime_utils.dart';
export 'num/num_range_extensions.dart';
export 'num/num_range_inclusive_extensions.dart';
export 'num/num_round_multiple_extensions.dart';
export 'num/num_safe_division_extensions.dart';
export 'num/num_stats_utils.dart';
export 'num/num_utils.dart';
export 'num/num_more_extensions.dart';

// Random utilities
export 'random/common_random.dart';

// Regex utilities
export 'regex/regex_common_utils.dart';
export 'regex/regex_match_utils.dart';

// Caching
export 'caching/lru_cache.dart';
export 'caching/memoize_sync_utils.dart';
export 'caching/size_limit_cache.dart';
export 'caching/ttl_cache.dart';

// Niche utilities
export 'niche/color_utils.dart';
export 'niche/name_utils.dart';
export 'niche/pad_format_utils.dart';
export 'niche/random_string_utils.dart';
export 'niche/hash_utils.dart';
export 'niche/string_diff_utils.dart';
export 'niche/checksum_utils.dart';
export 'niche/natural_sort_utils.dart';
export 'niche/niche_more_utils.dart';

// Object / equality / pipe
export 'object/assert_utils.dart';
export 'object/cast_utils.dart';
export 'object/coalesce_utils.dart';
export 'object/copy_with_defaults_utils.dart';
export 'object/default_value_extensions.dart';
export 'object/identity_utils.dart';
export 'object/pipe_utils.dart';
export 'object/require_utils.dart';
export 'object/shallow_copy_utils.dart';
export 'object/pipe_compose_utils.dart';
export 'object/nullable_more_extensions.dart';

// String extensions and utilities
export 'string/between_result.dart';
export 'string/levenshtein_utils.dart';
export 'string/string_analysis_extensions.dart';
export 'string/string_line_extensions.dart';
export 'string/string_mask_extensions.dart';
export 'string/string_regex_extensions.dart';
export 'string/string_slug_extensions.dart';
export 'string/string_template_extensions.dart';
export 'string/string_wildcard_extensions.dart';
export 'string/string_wrap_extensions.dart';
export 'string/string_indent_extensions.dart';
export 'string/string_replace_n_extensions.dart';
export 'string/string_highlight_extensions.dart';
export 'string/string_csv_extensions.dart';
export 'string/string_ansi_extensions.dart';
export 'string/string_words_extensions.dart';
export 'string/string_key_value_extensions.dart';
export 'string/string_split_extensions.dart';
export 'string/string_unicode_extensions.dart';
export 'string/string_case_acronym_extensions.dart';
export 'string/glob_utils.dart';
export 'string/soundex_utils.dart';
export 'string/string_between_extensions.dart';
export 'string/string_case_extensions.dart';
export 'string/string_character_extensions.dart';
export 'string/string_diacritics_extensions.dart';
export 'string/string_extensions.dart';
export 'string/string_manipulation_extensions.dart';
export 'string/string_nullable_extensions.dart';
export 'string/string_number_extensions.dart';
export 'string/string_punctuation.dart';
export 'string/string_search_extensions.dart';
export 'string/string_text_extensions.dart';
export 'string/string_utils.dart';
export 'string/string_more_extensions.dart';
export 'string/string_lower_extensions.dart';
export 'string/myers_diff_utils.dart';
export 'string/diff_render_utils.dart';
export 'string/apply_patch_utils.dart';
export 'string/ngram_utils.dart';
export 'string/slug_dedup_utils.dart';
export 'string/fuzzy_search_utils.dart';
export 'string/excerpt_utils.dart';
export 'string/text_similarity_utils.dart';
export 'string/sensitive_scrub_utils.dart';
export 'string/text_chunk_utils.dart';
export 'string/html_sanitizer_utils.dart';
export 'string/tokenize_sentences_utils.dart';
export 'string/markdown_plain_utils.dart';
export 'string/search_query_parser_utils.dart';
export 'string/code_block_extract_utils.dart';
export 'string/url_extract_utils.dart';
export 'string/safe_html_excerpt_utils.dart';
export 'string/template_engine_utils.dart';
export 'string/acronym_extract_utils.dart';
export 'string/text_normalize_pipeline_utils.dart';
export 'string/duplicate_doc_utils.dart';
export 'string/human_name_parser_utils.dart';
export 'string/search_index_utils.dart';
export 'string/markdown_snippet_utils.dart' hide extractFirstCodeBlock;
export 'string/text_fingerprint_utils.dart';
export 'string/spelling_key_lookup_utils.dart';
export 'string/email_quote_strip_utils.dart';
export 'string/did_you_mean_utils.dart';

// Async utilities
export 'async/debounce_utils.dart';
export 'async/delay_utils.dart';
export 'async/memoize_future_utils.dart';
export 'async/retry_utils.dart' hide FutureSupplier;
export 'async/sequential_async_utils.dart';
export 'async/throttle_utils.dart' hide VoidCallback;
export 'async/timeout_fallback_utils.dart';
export 'async/batch_async_utils.dart';
export 'async/cancel_previous_utils.dart';
export 'async/async_semaphore_utils.dart';
export 'async/async_mutex_utils.dart';
export 'async/stream_buffer_utils.dart';
export 'async/exponential_backoff_utils.dart';
export 'async/retry_policy_utils.dart' hide retryWithBackoff;
export 'async/batch_flush_utils.dart';
export 'async/circuit_breaker_utils.dart';
export 'async/async_barrier_utils.dart';
export 'async/timeout_policy_utils.dart';
export 'async/race_cancel_utils.dart';
export 'async/idempotent_async_utils.dart';
export 'async/stream_window_utils.dart';
export 'async/heartbeat_utils.dart';

// Parsing and validation
export 'parsing/csv_parse_utils.dart';
export 'parsing/email_validation_utils.dart';
export 'parsing/hex_color_utils.dart';
export 'parsing/isbn_utils.dart';
export 'parsing/luhn_utils.dart';
export 'parsing/parse_bool_utils.dart';
export 'parsing/parse_list_utils.dart';
export 'parsing/phone_normalize_utils.dart';
export 'parsing/semver_utils.dart';
export 'parsing/size_parse_utils.dart';
export 'parsing/validate_non_empty_utils.dart';
export 'parsing/version_parse_utils.dart';
export 'parsing/version_compare_utils.dart';
export 'parsing/parsing_more_utils.dart';
export 'parsing/config_precedence_utils.dart';
export 'parsing/csv_dialect_utils.dart';
export 'parsing/parser_error_utils.dart';
export 'parsing/canonicalize_json_utils.dart';
export 'parsing/changelog_section_utils.dart';
export 'parsing/json_diff_patch_utils.dart';
export 'parsing/nested_query_parser_utils.dart';
export 'parsing/varint_utils.dart';

// URL and path utilities
export 'url/path_extension_utils.dart';
export 'url/path_join_utils.dart';
export 'url/url_absolute_utils.dart';
export 'url/url_build_utils.dart';
export 'url/url_encode_utils.dart';
export 'url/url_extensions.dart';
export 'url/url_query_utils.dart';
export 'url/path_more_utils.dart';

// UUID utilities
export 'uuid/uuid_utils.dart';
export 'uuid/uuid_v4_utils.dart';
export 'testing/debug_utils.dart';

// Validation (roadmap 681+)
export 'validation/validation_error_utils.dart';
export 'validation/path_validator_utils.dart';
export 'validation/input_shaping_utils.dart';
export 'validation/guard_utils.dart';
export 'validation/cross_field_validation_utils.dart';
export 'validation/safe_temp_name_utils.dart';
export 'validation/password_strength_utils.dart';
export 'validation/pii_detector_utils.dart';
export 'validation/data_redaction_utils.dart';
export 'validation/safe_parse_utils.dart';
export 'validation/typed_positive_utils.dart';
export 'validation/ip_cidr_utils.dart';
export 'validation/jwt_structure_utils.dart';
