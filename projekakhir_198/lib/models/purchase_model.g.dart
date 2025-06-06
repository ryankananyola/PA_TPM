// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchasedRecipeAdapter extends TypeAdapter<PurchasedRecipe> {
  @override
  final int typeId = 3;

  @override
  PurchasedRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchasedRecipe(
      recipe: fields[0] as Recipe,
      purchasePrice: fields[1] as double,
      location: fields[2] as String?,
      purchasedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PurchasedRecipe obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.recipe)
      ..writeByte(1)
      ..write(obj.purchasePrice)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.purchasedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchasedRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
