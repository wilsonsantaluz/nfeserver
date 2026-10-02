using System.Linq.Expressions;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Serializers;
using NfeServer.Domain.Entidades;

namespace NfeServer.Infrastructure.Persistencia.Mongo;

/// <summary>
/// Mapeia as entidades para os mesmos nomes de campo que o REST.Json do Delphi gerava
/// (nomes dos campos sem o prefixo F), sem atributos de persistência no Domain.
/// </summary>
internal static class MapeamentoMongo
{
    private static readonly object Trava = new();
    private static bool _registrado;

    public static void Registrar()
    {
        lock (Trava)
        {
            if (_registrado)
                return;

            Mapear<NotaFiscal>(cm =>
            {
                Campo(cm, x => x.Cnpj, "cnpj");
                Inteiro32(cm, x => x.Numero, "numero");
                Campo(cm, x => x.Serie, "serie");
                Campo(cm, x => x.Modelo, "modelo");
                Campo(cm, x => x.Ambiente, "ambiente");
                Campo(cm, x => x.Chave, "chave");
                Data(cm, x => x.DataEmissao, "dataEmissao");
                Campo(cm, x => x.Xml, "xml");
                Campo(cm, x => x.XmlRetorno, "xmlRetorno");
                Campo(cm, x => x.Txt, "txt");
                Campo(cm, x => x.Status, "status");
                Campo(cm, x => x.Motivo, "motivo");
                Data(cm, x => x.DataValidacao, "dataValidacao");
                Data(cm, x => x.DataProcessamento, "dataProcessamento");
                Campo(cm, x => x.Protocolo, "protocolo");
                Campo(cm, x => x.DigitoVal, "digitoval");
                Campo(cm, x => x.Cancelada, "cancelada");
                Campo(cm, x => x.Danfe, "danfe");
            });

            Mapear<Empresa>(cm =>
            {
                Campo(cm, x => x.Cnpj, "cnpj");
                Campo(cm, x => x.RazaoSocial, "razaoSocial");
                Campo(cm, x => x.Endereco, "endereco");
                Campo(cm, x => x.Bairro, "bairro");
                Campo(cm, x => x.Cidade, "cidade");
                Campo(cm, x => x.CodMunicipio, "codMunicipio");
                Campo(cm, x => x.Complemento, "complemento");
                Campo(cm, x => x.Numero, "numero");
                Campo(cm, x => x.Uf, "uf");
                Campo(cm, x => x.Telefone, "telefone");
                Campo(cm, x => x.InscricaoMunicipal, "inscricaoMunicipal");
                Campo(cm, x => x.InscricaoEstadual, "inscricaoEstadual");
                Campo(cm, x => x.NomeCertificadoPfx, "nomecertificadoPfx");
                Campo(cm, x => x.CertificadoPfx, "certificadoPfx");
                Campo(cm, x => x.SenhaPfx, "senhaPfx");
                Data(cm, x => x.Validade, "validade");
                Campo(cm, x => x.Ambiente, "ambiente");
                Campo(cm, x => x.Contigencia, "contigencia");
                Campo(cm, x => x.Csc, "csc");
                Campo(cm, x => x.IdCsc, "idCsc");
            });

            Mapear<Cancelamento>(cm =>
            {
                Campo(cm, x => x.Cnpj, "cnpj");
                Inteiro32(cm, x => x.Numero, "numero");
                Campo(cm, x => x.Serie, "serie");
                Campo(cm, x => x.Chave, "chave");
                Campo(cm, x => x.Ambiente, "ambiente");
                Campo(cm, x => x.ProtocoloNota, "protocoloNota");
                Campo(cm, x => x.ProtocoloCancelamento, "protocoloCancelamento");
                Data(cm, x => x.Data, "data");
                Campo(cm, x => x.Justificativa, "justificativa");
                Campo(cm, x => x.CStat, "cstat");
                Campo(cm, x => x.XMotivo, "xmotivo");
                Campo(cm, x => x.XmlRetorno, "xmlRetorno");
                Campo(cm, x => x.Danfe, "danfe");
            });

            Mapear<CartaCorrecao>(cm =>
            {
                Campo(cm, x => x.Cnpj, "cnpj");
                Campo(cm, x => x.Chave, "chave");
                Data(cm, x => x.DataHora, "dataHora");
                Campo(cm, x => x.Sequencia, "sequencia");
                Campo(cm, x => x.XCorrecao, "xcorrecao");
                Campo(cm, x => x.XmlEvento, "xmlEvento");
                Campo(cm, x => x.CStat, "cstat");
                Campo(cm, x => x.XMotivo, "xmotivo");
                Campo(cm, x => x.ProtocoloCce, "protocoloCCe");
                Campo(cm, x => x.Danfe, "danfe");
            });

            Mapear<Inutilizacao>(cm =>
            {
                Campo(cm, x => x.Cnpj, "cnpj");
                Campo(cm, x => x.NumeroInicial, "numeroInicial");
                Campo(cm, x => x.NumeroFinal, "numeroFinal");
                Campo(cm, x => x.Serie, "serie");
                Campo(cm, x => x.Modelo, "modelo");
                Campo(cm, x => x.Ano, "ano");
                Campo(cm, x => x.Justificativa, "justificativa");
                Campo(cm, x => x.Protocolo, "protocolo");
                Campo(cm, x => x.XMotivo, "xmotivo");
                Campo(cm, x => x.CStat, "cstat");
                Campo(cm, x => x.XmlEvento, "xmlEvento");
                Campo(cm, x => x.Danfe, "danfe");
                Data(cm, x => x.DhRecbto, "dhRecbto");
            });

            _registrado = true;
        }
    }

    private static void Mapear<T>(Action<BsonClassMap<T>> configurar)
    {
        if (BsonClassMap.IsClassMapRegistered(typeof(T)))
            return;
        BsonClassMap.RegisterClassMap<T>(cm =>
        {
            cm.SetIgnoreExtraElements(true); // _id e campos que só o Delphi conhece
            configurar(cm);
        });
    }

    private static void Campo<T, TCampo>(BsonClassMap<T> cm, Expression<Func<T, TCampo>> membro, string nome) =>
        cm.MapProperty(membro).SetElementName(nome);

    private static void Data<T>(BsonClassMap<T> cm, Expression<Func<T, DateTime>> membro, string nome) =>
        cm.MapProperty(membro).SetElementName(nome).SetSerializer(DataLegadaSerializer.Instancia);

    /// <summary>O Delphi grava inteiros de 32 bits; Int64 mudaria o tipo do campo no banco.</summary>
    private static void Inteiro32<T>(BsonClassMap<T> cm, Expression<Func<T, long>> membro, string nome) =>
        cm.MapProperty(membro).SetElementName(nome).SetSerializer(new Int64Serializer(BsonType.Int32));
}
