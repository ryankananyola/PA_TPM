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
    );
  }

  @override
  void write(BinaryWriter writer, PurchasedRecipe obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.recipe)
      ..writeByte(1)
      ..write(obj.purchasePrice);
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
