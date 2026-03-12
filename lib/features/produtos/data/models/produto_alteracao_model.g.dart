// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_alteracao_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProdutoAlteracaoModelAdapter extends TypeAdapter<ProdutoAlteracaoModel> {
  @override
  final int typeId = 13;

  @override
  ProdutoAlteracaoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProdutoAlteracaoModel(
      dataCriacao: fields[0] as DateTime,
      versao: fields[1] as int,
      precoAnterior: fields[2] as double,
      precoNovo: fields[3] as double,
      descricaoAlteracao: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProdutoAlteracaoModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.dataCriacao)
      ..writeByte(1)
      ..write(obj.versao)
      ..writeByte(2)
      ..write(obj.precoAnterior)
      ..writeByte(3)
      ..write(obj.precoNovo)
      ..writeByte(4)
      ..write(obj.descricaoAlteracao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProdutoAlteracaoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
