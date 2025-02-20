part of 'models.dart';

/// Thread filter applied on current forum.
@MappableClass()
class FilterState with FilterStateMappable {
  /// Constructor.
  const FilterState({
    this.filter,
    this.filterType,
    this.filterSpecialType,
    this.filterDateline,
    this.filterOrder,
    this.filterDigest = const FilterDigest(digest: false),
    this.filterRecommend = const FilterRecommend(recommend: false),
  });

  /// Filter parameter in forum url to define the thread filter.
  ///
  /// Available values:
  /// * null
  /// * typeid
  /// * dateline
  /// * specialtype
  /// * digest
  /// * recommend
  ///
  /// Every time user changed the filter settings, this option is updated to
  /// the latest filter type. But the existing filter will still work so we
  /// should reserve them in state.
  ///
  /// Note that the "digest" filter and the "recommend" filter seems conflicts
  /// on the web browser. Here we bypass the conflict by reserving both
  /// parameters in url, which leads to different behavior with web browser.
  /// But it's ok, even better.
  final String? filter;

  /// Thread type used to filter threads.
  ///
  /// Apply the parameter "typeid".
  final FilterType? filterType;

  /// Thread special type used to filter threads.
  ///
  /// Apply the parameter "specialtype".
  final FilterSpecialType? filterSpecialType;

  /// Duration since thread published.
  ///
  /// Apply the parameter "dateline".
  final FilterDateline? filterDateline;

  /// Sort order of the filter results.
  ///
  /// Apply the parameter "orderby".
  final FilterOrder? filterOrder;

  /// Only show threads marked with digest (精华贴).
  final FilterDigest filterDigest;

  /// Only show threads marked with recommend (推荐贴).
  final FilterRecommend filterRecommend;

  /// Return whether thread filter is on.
  bool isFiltering() {
    return filterType?.typeID != null ||
        filterSpecialType?.specialType != null ||
        filterDateline?.dateline != null ||
        filterOrder?.orderBy != null ||
        filterDigest.digest ||
        filterRecommend.recommend;
  }
}

/// Basic filter definition.
@MappableClass()
sealed class FilterBase with FilterBaseMappable {
  const FilterBase(this.filterName);

  /// Parameter "&filer=" in url.
  ///
  final String filterName;
}

/// Filter threads with thread "typeid".
///
/// 其他、心情、领糖……
@MappableClass()
final class FilterType extends FilterBase with FilterTypeMappable {
  /// Constructor.
  const FilterType({required this.name, required this.typeID}) : super('typeid');

  /// Thread type name.
  ///
  /// e.g. 其他
  final String name;

  /// Type id value.
  ///
  /// e.g. &typeid=2
  ///
  /// Null value means do not filter by thread type.
  final String? typeID;
}

/// Thread special type.
///
/// 投票、商品、悬赏……
@MappableClass()
final class FilterSpecialType extends FilterBase with FilterSpecialTypeMappable {
  /// Constructor.
  const FilterSpecialType({required this.name, required this.specialType}) : super('specialtype');

  /// Thread special type name.
  ///
  /// e.g. 投票
  final String name;

  /// Special type id.
  ///
  /// e.g. &specialtype=poll
  ///
  /// Null value means do not filter by thread special type.
  final String? specialType;
}

/// Duration elapsed since thread published in seconds.
///
/// 一天、两天、一周……
@MappableClass()
final class FilterDateline extends FilterBase with FilterDatelineMappable {
  /// Constructor.
  const FilterDateline({required this.name, required this.dateline}) : super('dateline');

  /// Dateline human readable name.
  ///
  /// e.g. 一天
  final String name;

  /// Duration elapsed since thread published in seconds.
  ///
  /// e.g. &dateline=86400
  ///
  /// Null value means do not filter by dateline.
  final String? dateline;
}

/// Filter thread by sorting order.
@MappableClass()
final class FilterOrder extends FilterBase with FilterOrderMappable {
  /// Constructor.
  const FilterOrder({required this.name, required this.orderBy}) : super('orderby');

  /// Human readable order name.
  ///
  /// e.g. 发帖时间
  final String name;

  /// Order by.
  ///
  /// e.g. dateline
  final String? orderBy;
}

/// Only show threads marked with digest (精华贴).
///
/// Note that on the browser platform this filter is conflict with
/// [FilterRecommend] filter, we bypass this conflict by reserving both
/// parameters when fetching forum content, which behaves different but ok,
/// even better.
@MappableClass()
final class FilterDigest extends FilterBase with FilterDigestMappable {
  /// Constructor.
  const FilterDigest({required this.digest}) : super('digest');

  /// Only show thread marked as digest.
  final bool digest;
}

/// Only show threads marked with recommend (推荐贴).
///
/// Note that on the browser platform this filter is conflict with
/// [FilterDigest] filter, we bypass this conflict by reserving both parameters
/// when fetching forum content, which behaves different but ok, even better.
@MappableClass()
final class FilterRecommend extends FilterBase with FilterRecommendMappable {
  /// Constructor.
  const FilterRecommend({required this.recommend}) : super('recommends');

  /// Only show thread marked as recommend.
  final bool recommend;
}
