// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DriverModel {
  String walletId;
  String? name;

  DriverModel({
    required this.walletId,
    this.name,
  });

  DriverModel copyWith({
    String? walletId,
    String? name,
  }) {
    return DriverModel(
      walletId: walletId ?? this.walletId,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'walletId': walletId,
      'name': name,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      walletId: map['walletId'] as String,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DriverModel.fromJson(String source) => DriverModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DriverModel(walletId: $walletId, name: $name)';

  @override
  bool operator ==(covariant DriverModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.walletId == walletId &&
      other.name == name;
  }

  @override
  int get hashCode => walletId.hashCode ^ name.hashCode;
}
