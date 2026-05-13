// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarState {

  DateTime get focusedMonth;

  DateTime? get selectedDay;

  List<String> get cycle;

  DateTime get anchorDate;

  Map<DateKey, Note> get notes;

  Map<DateKey, String> get overrides;
/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarStateCopyWith<CalendarState> get copyWith => _$CalendarStateCopyWithImpl<CalendarState>(this as CalendarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarState&&(identical(other.focusedMonth, focusedMonth) || other.focusedMonth == focusedMonth)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&const DeepCollectionEquality().equals(other.cycle, cycle)&&(identical(other.anchorDate, anchorDate) || other.anchorDate == anchorDate)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.overrides, overrides));
}


@override
int get hashCode => Object.hash(runtimeType,focusedMonth,selectedDay,const DeepCollectionEquality().hash(cycle),anchorDate,const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(overrides));

@override
String toString() {
  return 'CalendarState(focusedMonth: $focusedMonth, selectedDay: $selectedDay, cycle: $cycle, anchorDate: $anchorDate, notes: $notes, overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class $CalendarStateCopyWith<$Res>  {
  factory $CalendarStateCopyWith(CalendarState value, $Res Function(CalendarState) _then) = _$CalendarStateCopyWithImpl;
@useResult
$Res call({
  DateTime focusedMonth, DateTime? selectedDay, List<
      String> cycle, DateTime anchorDate, Map<DateKey, Note> notes, Map<
      DateKey,
      String> overrides
});




}
/// @nodoc
class _$CalendarStateCopyWithImpl<$Res>
    implements $CalendarStateCopyWith<$Res> {
  _$CalendarStateCopyWithImpl(this._self, this._then);

  final CalendarState _self;
  final $Res Function(CalendarState) _then;

/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? focusedMonth = null,Object? selectedDay = freezed,Object? cycle = null,Object? anchorDate = null,Object? notes = null,Object? overrides = null,}) {
  return _then(_self.copyWith(
focusedMonth: null == focusedMonth ? _self.focusedMonth : focusedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,selectedDay: freezed == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,cycle: null == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
  as List<String>,
    anchorDate: null == anchorDate
        ? _self.anchorDate
        : anchorDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as Map<DateKey, Note>,overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
  as Map<DateKey, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarState].
extension CalendarStatePatterns on CalendarState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarState value)  $default,){
final _that = this;
switch (_that) {
case _CalendarState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarState value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime focusedMonth, DateTime? selectedDay, List<String> cycle, DateTime anchorDate, Map<DateKey, Note> notes, Map<DateKey, String> overrides)? $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarState() when $default != null:
return $default(_that.focusedMonth,_that.selectedDay,_that.cycle,_that.anchorDate,_that.notes,_that.overrides);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime focusedMonth, DateTime? selectedDay, List<String> cycle, DateTime anchorDate, Map<DateKey, Note> notes, Map<DateKey, String> overrides) $default,) {final _that = this;
switch (_that) {
case _CalendarState():
return $default(_that.focusedMonth,_that.selectedDay,_that.cycle,_that.anchorDate,_that.notes,_that.overrides);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime focusedMonth, DateTime? selectedDay, List<String> cycle, DateTime anchorDate, Map<DateKey, Note> notes, Map<DateKey, String> overrides)? $default,) {final _that = this;
switch (_that) {
case _CalendarState() when $default != null:
return $default(_that.focusedMonth,_that.selectedDay,_that.cycle,_that.anchorDate,_that.notes,_that.overrides);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarState implements CalendarState {
  const _CalendarState(
      {required this.focusedMonth, this.selectedDay, required final List<
          String> cycle, required this.anchorDate, required final Map<
          DateKey,
          Note> notes, required final Map<DateKey, String> overrides})
      : _cycle = cycle,
        _notes = notes,
        _overrides = overrides;
  

@override final  DateTime focusedMonth;
@override final  DateTime? selectedDay;
  final List<String> _cycle;

  @override List<String> get cycle {
  if (_cycle is EqualUnmodifiableListView) return _cycle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cycle);
}

@override final  DateTime anchorDate;
 final  Map<DateKey, Note> _notes;
@override Map<DateKey, Note> get notes {
  if (_notes is EqualUnmodifiableMapView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_notes);
}

  final Map<DateKey, String> _overrides;

  @override Map<DateKey, String> get overrides {
  if (_overrides is EqualUnmodifiableMapView) return _overrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_overrides);
}


/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarStateCopyWith<_CalendarState> get copyWith => __$CalendarStateCopyWithImpl<_CalendarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarState&&(identical(other.focusedMonth, focusedMonth) || other.focusedMonth == focusedMonth)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&const DeepCollectionEquality().equals(other._cycle, _cycle)&&(identical(other.anchorDate, anchorDate) || other.anchorDate == anchorDate)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._overrides, _overrides));
}


@override
int get hashCode => Object.hash(runtimeType,focusedMonth,selectedDay,const DeepCollectionEquality().hash(_cycle),anchorDate,const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_overrides));

@override
String toString() {
  return 'CalendarState(focusedMonth: $focusedMonth, selectedDay: $selectedDay, cycle: $cycle, anchorDate: $anchorDate, notes: $notes, overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class _$CalendarStateCopyWith<$Res> implements $CalendarStateCopyWith<$Res> {
  factory _$CalendarStateCopyWith(_CalendarState value, $Res Function(_CalendarState) _then) = __$CalendarStateCopyWithImpl;
@override @useResult
$Res call({
  DateTime focusedMonth, DateTime? selectedDay, List<
      String> cycle, DateTime anchorDate, Map<DateKey, Note> notes, Map<
      DateKey,
      String> overrides
});




}
/// @nodoc
class __$CalendarStateCopyWithImpl<$Res>
    implements _$CalendarStateCopyWith<$Res> {
  __$CalendarStateCopyWithImpl(this._self, this._then);

  final _CalendarState _self;
  final $Res Function(_CalendarState) _then;

/// Create a copy of CalendarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? focusedMonth = null,Object? selectedDay = freezed,Object? cycle = null,Object? anchorDate = null,Object? notes = null,Object? overrides = null,}) {
  return _then(_CalendarState(
focusedMonth: null == focusedMonth ? _self.focusedMonth : focusedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,selectedDay: freezed == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,cycle: null == cycle ? _self._cycle : cycle // ignore: cast_nullable_to_non_nullable
  as List<String>,
    anchorDate: null == anchorDate
        ? _self.anchorDate
        : anchorDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as Map<DateKey, Note>,overrides: null == overrides ? _self._overrides : overrides // ignore: cast_nullable_to_non_nullable
  as Map<DateKey, String>,
  ));
}


}

// dart format on
