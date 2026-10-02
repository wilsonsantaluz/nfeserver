using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Serializers;
using NfeServer.Infrastructure.Legado;

namespace NfeServer.Infrastructure.Persistencia.Mongo;

/// <summary>
/// Grava datas como string no formato do Delphi (o servidor Delphi lê as mesmas coleções
/// durante a convivência) e aceita na leitura string, BSON date ou TDateTime numérico.
/// </summary>
internal sealed class DataLegadaSerializer : SerializerBase<DateTime>
{
    public static readonly DataLegadaSerializer Instancia = new();

    public override DateTime Deserialize(BsonDeserializationContext context, BsonDeserializationArgs args)
    {
        var reader = context.Reader;
        switch (reader.GetCurrentBsonType())
        {
            case BsonType.String:
                return DataLegada.Converter(reader.ReadString());
            case BsonType.DateTime:
                return DateTimeOffset.FromUnixTimeMilliseconds(reader.ReadDateTime()).LocalDateTime;
            case BsonType.Double:
                return DeOADate(reader.ReadDouble());
            case BsonType.Int32:
                return DeOADate(reader.ReadInt32());
            case BsonType.Int64:
                return DeOADate(reader.ReadInt64());
            case BsonType.Null:
                reader.ReadNull();
                return default;
            default:
                throw CreateCannotDeserializeFromBsonTypeException(reader.GetCurrentBsonType());
        }
    }

    public override void Serialize(BsonSerializationContext context, BsonSerializationArgs args, DateTime value) =>
        context.Writer.WriteString(DataLegada.Formatar(value));

    private static DateTime DeOADate(double valor) => valor == 0 ? default : DateTime.FromOADate(valor);
}
