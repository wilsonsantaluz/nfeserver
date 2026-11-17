namespace NfeServer.Domain.Comum;

/// <summary>Violação de regra de negócio; a mensagem é segura para devolver ao cliente.</summary>
public sealed class RegraNegocioException(string message) : Exception(message);
