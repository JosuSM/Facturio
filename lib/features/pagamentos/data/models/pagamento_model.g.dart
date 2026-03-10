// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagamento_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PagamentoModelAdapter extends TypeAdapter<PagamentoModel> {
  @override
  final int typeId = 3;

  @override
  PagamentoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PagamentoModel(
      id: fields[0] as String,
      faturaId: fields[1] as String,
      valor: fields[2] as double,
      meioPagamento: fields[3] as String,
      dataPagamento: fields[4] as DateTime,
      referencia: fields[5] as String?,
      observacoes: fields[6] as String?,
      dataCriacao: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PagamentoModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.faturaId)
      ..writeByte(2)
      ..write(obj.valor)
      ..writeByte(3)
      ..write(obj.meioPagamento)
      ..writeByte(4)
      ..write(obj.dataPagamento)
      ..writeByte(5)
      ..write(obj.referencia)
      ..writeByte(6)
      ..write(obj.observacoes)
      ..writeByte(7)
      ..write(obj.dataCriacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PagamentoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
