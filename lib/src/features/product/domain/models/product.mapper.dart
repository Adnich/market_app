// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product.dart';

class ProductMapper extends ClassMapperBase<Product> {
  ProductMapper._();

  static ProductMapper? _instance;
  static ProductMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Product';

  static String _$id(Product v) => v.id;
  static const Field<Product, String> _f$id = Field('id', _$id);
  static String _$name(Product v) => v.name;
  static const Field<Product, String> _f$name = Field('name', _$name);
  static double _$price(Product v) => v.price;
  static const Field<Product, double> _f$price = Field('price', _$price);
  static String _$description(Product v) => v.description;
  static const Field<Product, String> _f$description = Field(
    'description',
    _$description,
  );
  static String? _$imageUrl(Product v) => v.imageUrl;
  static const Field<Product, String> _f$imageUrl = Field(
    'imageUrl',
    _$imageUrl,
    opt: true,
  );
  static bool _$available(Product v) => v.available;
  static const Field<Product, bool> _f$available = Field(
    'available',
    _$available,
    opt: true,
    def: true,
  );
  static Timestamp _$createdAt(Product v) => v.createdAt;
  static const Field<Product, Timestamp> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );

  @override
  final MappableFields<Product> fields = const {
    #id: _f$id,
    #name: _f$name,
    #price: _f$price,
    #description: _f$description,
    #imageUrl: _f$imageUrl,
    #available: _f$available,
    #createdAt: _f$createdAt,
  };

  static Product _instantiate(DecodingData data) {
    return Product(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      price: data.dec(_f$price),
      description: data.dec(_f$description),
      imageUrl: data.dec(_f$imageUrl),
      available: data.dec(_f$available),
      createdAt: data.dec(_f$createdAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Product fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Product>(map);
  }

  static Product fromJson(String json) {
    return ensureInitialized().decodeJson<Product>(json);
  }
}

mixin ProductMappable {
  String toJson() {
    return ProductMapper.ensureInitialized().encodeJson<Product>(
      this as Product,
    );
  }

  Map<String, dynamic> toMap() {
    return ProductMapper.ensureInitialized().encodeMap<Product>(
      this as Product,
    );
  }

  ProductCopyWith<Product, Product, Product> get copyWith =>
      _ProductCopyWithImpl<Product, Product>(
        this as Product,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductMapper.ensureInitialized().stringifyValue(this as Product);
  }

  @override
  bool operator ==(Object other) {
    return ProductMapper.ensureInitialized().equalsValue(
      this as Product,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductMapper.ensureInitialized().hashValue(this as Product);
  }
}

extension ProductValueCopy<$R, $Out> on ObjectCopyWith<$R, Product, $Out> {
  ProductCopyWith<$R, Product, $Out> get $asProduct =>
      $base.as((v, t, t2) => _ProductCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductCopyWith<$R, $In extends Product, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    bool? available,
    Timestamp? createdAt,
  });
  ProductCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Product, $Out>
    implements ProductCopyWith<$R, Product, $Out> {
  _ProductCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Product> $mapper =
      ProductMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    double? price,
    String? description,
    Object? imageUrl = $none,
    bool? available,
    Timestamp? createdAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (price != null) #price: price,
      if (description != null) #description: description,
      if (imageUrl != $none) #imageUrl: imageUrl,
      if (available != null) #available: available,
      if (createdAt != null) #createdAt: createdAt,
    }),
  );
  @override
  Product $make(CopyWithData data) => Product(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
    description: data.get(#description, or: $value.description),
    imageUrl: data.get(#imageUrl, or: $value.imageUrl),
    available: data.get(#available, or: $value.available),
    createdAt: data.get(#createdAt, or: $value.createdAt),
  );

  @override
  ProductCopyWith<$R2, Product, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProductCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

