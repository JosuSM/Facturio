// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fatura_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaturaModelAdapter extends TypeAdapter<FaturaModel> {
  @override
  final int typeId = 2;

  @override
  FaturaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaturaModel(
      id: fields[0] as String,
      numero: fields[1] as String,
      data: fields[2] as DateTime,
      clienteId: fields[3] as String,
      clienteNome: fields[4] as String,
      clienteNif: fields[7] as String?,
      clienteMorada: fields[8] as String?,
      linhas: (fields[5] as List).cast<LinhaFatura>(),
      estado: fields[6] as String,
      tipoDocumento: fields[9] as String,
      serie: fields[10] as String,
      codigoATCUD: fields[11] as String?,
      hashAnterior: fields[12] as String?,
      qrCodeData: fields[13] as String?,
      meioPagamento: fields[14] as String?,
      dataPagamento: fields[15] as DateTime?,
      valorPago: fields[16] as double?,
      retencaoFonte: fields[17] as double?,
      valorRetencao: fields[18] as double?,
      motivoIsencaoIVA: fields[19] as String?,
      observacoes: fields[20] as String?,
      notasInternas: fields[21] as String?,
      documentoOrigem: fields[22] as String?,
      numeroDocumentoOrigem: fields[23] as String?,
      dataCriacao: fields[24] as DateTime,
      dataUltimaAlteracao: fields[25] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FaturaModel obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.numero)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.clienteId)
      ..writeByte(4)
      ..write(obj.clienteNome)
      ..writeByte(5)
      ..write(obj.linhas)
      ..writeByte(6)
      ..write(obj.estado)
      ..writeByte(7)
      ..write(obj.clienteNif)
      ..writeByte(8)
      ..write(obj.clienteMorada)
      ..writeByte(9)
      ..write(obj.tipoDocumento)
      ..writeByte(10)
      ..write(obj.serie)
      ..writeByte(11)
      ..write(obj.codigoATCUD)
      ..writeByte(12)
      ..write(obj.hashAnterior)
      ..writeByte(13)
      ..write(obj.qrCodeData)
      ..writeByte(14)
      ..write(obj.meioPagamento)
      ..writeByte(15)
      ..write(obj.dataPagamento)
      ..writeByte(16)
      ..write(obj.valorPago)
      ..writeByte(17)
      ..write(obj.retencaoFonte)
      ..writeByte(18)
      ..write(obj.valorRetencao)
      ..writeByte(19)
      ..write(obj.motivoIsencaoIVA)
      ..writeByte(20)
      ..write(obj.observacoes)
      ..writeByte(21)
      ..write(obj.notasInternas)
      ..writeByte(22)
      ..write(obj.documentoOrigem)
      ..writeByte(23)
      ..write(obj.numeroDocumentoOrigem)
      ..writeByte(24)
      ..write(obj.dataCriacao)
      ..writeByte(25)
      ..write(obj.dataUltimaAlteracao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaturaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
