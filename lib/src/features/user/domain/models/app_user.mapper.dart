// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_user.dart';

class AppUserMapper extends ClassMapperBase<AppUser> {
  AppUserMapper._();

  static AppUserMapper? _instance;
  static AppUserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppUserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AppUser';

  static String _$id(AppUser v) => v.id;
  static const Field<AppUser, String> _f$id = Field('id', _$id);
  static String _$email(AppUser v) => v.email;
  static const Field<AppUser, String> _f$email = Field('email', _$email);
  static String? _$firstName(AppUser v) => v.firstName;
  static const Field<AppUser, String> _f$firstName = Field(
    'firstName',
    _$firstName,
    opt: true,
  );
  static String? _$lastName(AppUser v) => v.lastName;
  static const Field<AppUser, String> _f$lastName = Field(
    'lastName',
    _$lastName,
    opt: true,
  );
  static String? _$phone(AppUser v) => v.phone;
  static const Field<AppUser, String> _f$phone = Field(
    'phone',
    _$phone,
    opt: true,
  );
  static String? _$dateOfBirth(AppUser v) => v.dateOfBirth;
  static const Field<AppUser, String> _f$dateOfBirth = Field(
    'dateOfBirth',
    _$dateOfBirth,
    opt: true,
  );
  static String? _$gender(AppUser v) => v.gender;
  static const Field<AppUser, String> _f$gender = Field(
    'gender',
    _$gender,
    opt: true,
  );
  static String? _$photoUrl(AppUser v) => v.photoUrl;
  static const Field<AppUser, String> _f$photoUrl = Field(
    'photoUrl',
    _$photoUrl,
    opt: true,
  );

  @override
  final MappableFields<AppUser> fields = const {
    #id: _f$id,
    #email: _f$email,
    #firstName: _f$firstName,
    #lastName: _f$lastName,
    #phone: _f$phone,
    #dateOfBirth: _f$dateOfBirth,
    #gender: _f$gender,
    #photoUrl: _f$photoUrl,
  };

  static AppUser _instantiate(DecodingData data) {
    return AppUser(
      id: data.dec(_f$id),
      email: data.dec(_f$email),
      firstName: data.dec(_f$firstName),
      lastName: data.dec(_f$lastName),
      phone: data.dec(_f$phone),
      dateOfBirth: data.dec(_f$dateOfBirth),
      gender: data.dec(_f$gender),
      photoUrl: data.dec(_f$photoUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppUser fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppUser>(map);
  }

  static AppUser fromJson(String json) {
    return ensureInitialized().decodeJson<AppUser>(json);
  }
}

mixin AppUserMappable {
  String toJson() {
    return AppUserMapper.ensureInitialized().encodeJson<AppUser>(
      this as AppUser,
    );
  }

  Map<String, dynamic> toMap() {
    return AppUserMapper.ensureInitialized().encodeMap<AppUser>(
      this as AppUser,
    );
  }

  AppUserCopyWith<AppUser, AppUser, AppUser> get copyWith =>
      _AppUserCopyWithImpl<AppUser, AppUser>(
        this as AppUser,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppUserMapper.ensureInitialized().stringifyValue(this as AppUser);
  }

  @override
  bool operator ==(Object other) {
    return AppUserMapper.ensureInitialized().equalsValue(
      this as AppUser,
      other,
    );
  }

  @override
  int get hashCode {
    return AppUserMapper.ensureInitialized().hashValue(this as AppUser);
  }
}

extension AppUserValueCopy<$R, $Out> on ObjectCopyWith<$R, AppUser, $Out> {
  AppUserCopyWith<$R, AppUser, $Out> get $asAppUser =>
      $base.as((v, t, t2) => _AppUserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppUserCopyWith<$R, $In extends AppUser, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? photoUrl,
  });
  AppUserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppUserCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppUser, $Out>
    implements AppUserCopyWith<$R, AppUser, $Out> {
  _AppUserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppUser> $mapper =
      AppUserMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? email,
    Object? firstName = $none,
    Object? lastName = $none,
    Object? phone = $none,
    Object? dateOfBirth = $none,
    Object? gender = $none,
    Object? photoUrl = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (email != null) #email: email,
      if (firstName != $none) #firstName: firstName,
      if (lastName != $none) #lastName: lastName,
      if (phone != $none) #phone: phone,
      if (dateOfBirth != $none) #dateOfBirth: dateOfBirth,
      if (gender != $none) #gender: gender,
      if (photoUrl != $none) #photoUrl: photoUrl,
    }),
  );
  @override
  AppUser $make(CopyWithData data) => AppUser(
    id: data.get(#id, or: $value.id),
    email: data.get(#email, or: $value.email),
    firstName: data.get(#firstName, or: $value.firstName),
    lastName: data.get(#lastName, or: $value.lastName),
    phone: data.get(#phone, or: $value.phone),
    dateOfBirth: data.get(#dateOfBirth, or: $value.dateOfBirth),
    gender: data.get(#gender, or: $value.gender),
    photoUrl: data.get(#photoUrl, or: $value.photoUrl),
  );

  @override
  AppUserCopyWith<$R2, AppUser, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AppUserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

