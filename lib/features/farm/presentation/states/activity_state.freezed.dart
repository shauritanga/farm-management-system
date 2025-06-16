// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActivityState()';
}


}

/// @nodoc
class $ActivityStateCopyWith<$Res>  {
$ActivityStateCopyWith(ActivityState _, $Res Function(ActivityState) __);
}


/// @nodoc


class _ActivityInitial implements ActivityState {
  const _ActivityInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActivityState.initial()';
}


}




/// @nodoc


class _ActivityLoading implements ActivityState {
  const _ActivityLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActivityState.loading()';
}


}




/// @nodoc


class _ActivityLoaded implements ActivityState {
  const _ActivityLoaded(final  List<ActivityEntity> activities): _activities = activities;
  

 final  List<ActivityEntity> _activities;
 List<ActivityEntity> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}


/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityLoadedCopyWith<_ActivityLoaded> get copyWith => __$ActivityLoadedCopyWithImpl<_ActivityLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityLoaded&&const DeepCollectionEquality().equals(other._activities, _activities));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_activities));

@override
String toString() {
  return 'ActivityState.loaded(activities: $activities)';
}


}

/// @nodoc
abstract mixin class _$ActivityLoadedCopyWith<$Res> implements $ActivityStateCopyWith<$Res> {
  factory _$ActivityLoadedCopyWith(_ActivityLoaded value, $Res Function(_ActivityLoaded) _then) = __$ActivityLoadedCopyWithImpl;
@useResult
$Res call({
 List<ActivityEntity> activities
});




}
/// @nodoc
class __$ActivityLoadedCopyWithImpl<$Res>
    implements _$ActivityLoadedCopyWith<$Res> {
  __$ActivityLoadedCopyWithImpl(this._self, this._then);

  final _ActivityLoaded _self;
  final $Res Function(_ActivityLoaded) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activities = null,}) {
  return _then(_ActivityLoaded(
null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<ActivityEntity>,
  ));
}


}

/// @nodoc


class _ActivityError implements ActivityState {
  const _ActivityError(this.message);
  

 final  String message;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityErrorCopyWith<_ActivityError> get copyWith => __$ActivityErrorCopyWithImpl<_ActivityError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ActivityState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ActivityErrorCopyWith<$Res> implements $ActivityStateCopyWith<$Res> {
  factory _$ActivityErrorCopyWith(_ActivityError value, $Res Function(_ActivityError) _then) = __$ActivityErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ActivityErrorCopyWithImpl<$Res>
    implements _$ActivityErrorCopyWith<$Res> {
  __$ActivityErrorCopyWithImpl(this._self, this._then);

  final _ActivityError _self;
  final $Res Function(_ActivityError) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ActivityError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ActivityCreating implements ActivityState {
  const _ActivityCreating();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityCreating);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActivityState.creating()';
}


}




/// @nodoc


class _ActivityCreated implements ActivityState {
  const _ActivityCreated(this.activity);
  

 final  ActivityEntity activity;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityCreatedCopyWith<_ActivityCreated> get copyWith => __$ActivityCreatedCopyWithImpl<_ActivityCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityCreated&&(identical(other.activity, activity) || other.activity == activity));
}


@override
int get hashCode => Object.hash(runtimeType,activity);

@override
String toString() {
  return 'ActivityState.created(activity: $activity)';
}


}

/// @nodoc
abstract mixin class _$ActivityCreatedCopyWith<$Res> implements $ActivityStateCopyWith<$Res> {
  factory _$ActivityCreatedCopyWith(_ActivityCreated value, $Res Function(_ActivityCreated) _then) = __$ActivityCreatedCopyWithImpl;
@useResult
$Res call({
 ActivityEntity activity
});




}
/// @nodoc
class __$ActivityCreatedCopyWithImpl<$Res>
    implements _$ActivityCreatedCopyWith<$Res> {
  __$ActivityCreatedCopyWithImpl(this._self, this._then);

  final _ActivityCreated _self;
  final $Res Function(_ActivityCreated) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activity = null,}) {
  return _then(_ActivityCreated(
null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityEntity,
  ));
}


}

/// @nodoc


class _ActivityUpdating implements ActivityState {
  const _ActivityUpdating();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityUpdating);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActivityState.updating()';
}


}




/// @nodoc


class _ActivityUpdated implements ActivityState {
  const _ActivityUpdated(this.activity);
  

 final  ActivityEntity activity;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityUpdatedCopyWith<_ActivityUpdated> get copyWith => __$ActivityUpdatedCopyWithImpl<_ActivityUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityUpdated&&(identical(other.activity, activity) || other.activity == activity));
}


@override
int get hashCode => Object.hash(runtimeType,activity);

@override
String toString() {
  return 'ActivityState.updated(activity: $activity)';
}


}

/// @nodoc
abstract mixin class _$ActivityUpdatedCopyWith<$Res> implements $ActivityStateCopyWith<$Res> {
  factory _$ActivityUpdatedCopyWith(_ActivityUpdated value, $Res Function(_ActivityUpdated) _then) = __$ActivityUpdatedCopyWithImpl;
@useResult
$Res call({
 ActivityEntity activity
});




}
/// @nodoc
class __$ActivityUpdatedCopyWithImpl<$Res>
    implements _$ActivityUpdatedCopyWith<$Res> {
  __$ActivityUpdatedCopyWithImpl(this._self, this._then);

  final _ActivityUpdated _self;
  final $Res Function(_ActivityUpdated) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activity = null,}) {
  return _then(_ActivityUpdated(
null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityEntity,
  ));
}


}

/// @nodoc


class _ActivityCompleting implements ActivityState {
  const _ActivityCompleting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityCompleting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActivityState.completing()';
}


}




/// @nodoc


class _ActivityCompleted implements ActivityState {
  const _ActivityCompleted(this.activity);
  

 final  ActivityEntity activity;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityCompletedCopyWith<_ActivityCompleted> get copyWith => __$ActivityCompletedCopyWithImpl<_ActivityCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityCompleted&&(identical(other.activity, activity) || other.activity == activity));
}


@override
int get hashCode => Object.hash(runtimeType,activity);

@override
String toString() {
  return 'ActivityState.completed(activity: $activity)';
}


}

/// @nodoc
abstract mixin class _$ActivityCompletedCopyWith<$Res> implements $ActivityStateCopyWith<$Res> {
  factory _$ActivityCompletedCopyWith(_ActivityCompleted value, $Res Function(_ActivityCompleted) _then) = __$ActivityCompletedCopyWithImpl;
@useResult
$Res call({
 ActivityEntity activity
});




}
/// @nodoc
class __$ActivityCompletedCopyWithImpl<$Res>
    implements _$ActivityCompletedCopyWith<$Res> {
  __$ActivityCompletedCopyWithImpl(this._self, this._then);

  final _ActivityCompleted _self;
  final $Res Function(_ActivityCompleted) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activity = null,}) {
  return _then(_ActivityCompleted(
null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityEntity,
  ));
}


}

/// @nodoc


class _ActivityDeleting implements ActivityState {
  const _ActivityDeleting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityDeleting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ActivityState.deleting()';
}


}




/// @nodoc


class _ActivityDeleted implements ActivityState {
  const _ActivityDeleted(this.activityId);
  

 final  String activityId;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityDeletedCopyWith<_ActivityDeleted> get copyWith => __$ActivityDeletedCopyWithImpl<_ActivityDeleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityDeleted&&(identical(other.activityId, activityId) || other.activityId == activityId));
}


@override
int get hashCode => Object.hash(runtimeType,activityId);

@override
String toString() {
  return 'ActivityState.deleted(activityId: $activityId)';
}


}

/// @nodoc
abstract mixin class _$ActivityDeletedCopyWith<$Res> implements $ActivityStateCopyWith<$Res> {
  factory _$ActivityDeletedCopyWith(_ActivityDeleted value, $Res Function(_ActivityDeleted) _then) = __$ActivityDeletedCopyWithImpl;
@useResult
$Res call({
 String activityId
});




}
/// @nodoc
class __$ActivityDeletedCopyWithImpl<$Res>
    implements _$ActivityDeletedCopyWith<$Res> {
  __$ActivityDeletedCopyWithImpl(this._self, this._then);

  final _ActivityDeleted _self;
  final $Res Function(_ActivityDeleted) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activityId = null,}) {
  return _then(_ActivityDeleted(
null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
