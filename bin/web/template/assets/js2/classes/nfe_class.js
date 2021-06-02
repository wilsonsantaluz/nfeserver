function Trps_class(_rps_id) {

  //initClass();
  ///----------------------------------------------------------------------------------------------------------//
  ///----------------------------------------------------------------------------------------------------------//


  this.ID = _rps_id;
  this.CD_EMP = "000";
  this.CD_FILIAL = 0;
  this.DT_COMP = "";
  this.DT_EMIS = "";
  this.TP_RPS = "";
  this.NUM_RPS = "";
  this.SERIE_RPS = "";
  this.CD_NT_OP_SERVICO = "";
  this.REG_ESP_TRIB = "";
  this.OPT_SIMPLES = "";
  this.INCENT_FISCAL = "";
  this.STATUS = 0;
  this.TRIB_MUN = "";
  this.TRIB_PREST = "";
  this.VLR_SERVICOS = "";
  this.VLR_DEDUCOES = "";
  this.VLR_PIS = "";
  this.VLR_COFINS = "";
  this.VLR_INSS = "";
  this.VLR_IR = "";
  this.VLR_CSLL = "";
  this.VLR_ISS = "";
  this.VLR_ISS_RET = "";
  this.VLR_OTR_RETENCOES = "";
  this.VLR_BASE_CALCULO = "";
  this.PERC_ALQ_ISS = "";
  this.VLR_LIQUIDO_NFSE = "";
  this.VLR_DESC_INCONDICIONADO = "";
  this.VLR_DESC_CONDICIONADO = "";
  this.VLR_RED_BC = "";
  this.VLR_REPASSE = "";
  this.VLR_APROX_IMPOSTO = "";
  this.PERC_ALQ_APROX_IMPOSTO = "";
  this.CNPJ_TOMADOR = "";
  this.RZ_TOMADOR = "";
  this.END_TOMADOR = "";
  this.NR_TOMADOR = "";
  this.CPL_TOMADOR = "";
  this.BAIRRO_TOMADOR = "";
  this.CD_MUN_TOMADOR = "";
  this.UF_TOMADOR = "";
  this.CEP_TOMADOR = "";
  this.CNPJ_PRESTADOR = "";
  this.INSC_MUN_PRESTADOR = "";
  this.END_PRESTADOR = "";
  this.NR_PRESTADOR = "";
  this.CPL_PRESTADOR = "";
  this.BAIRRO_PRESTADOR = "";
  this.UF_PRESTADOR = "";
  this.CEP_PRESTADOR = "";
  this.CD_PAIS_PRESTADOR = "";
  this.DDD_PRESTADOR = "";
  this.TEL_PRESTADOR = "";
  this.RZ_PRESTADOR = "";
  this.EMAIL_PRESTADOR = "";
  this.CIDADE_TOMADOR = "";
  this.CIDADE_PRESTADOR = "";
  this.INDENTIFICACAO = "";
  this.RPS_SUBSTITUIDO = "";
  this.CODIGO_VERIFICACAO = "";
  this.CHAVE_ACESSO = "";

  this.CD_PROD = "";
  this.DS_PROD = "";
  this.CD_CNAE = "";
  this.CD_TRIB_MUNICIPIO = "";
  this.DESC_SERVICO = 0;
  this.VLR_ISS_RETIDO = 0;
  this.ITEM_LISTA_SERVICO = "";
  this.CD_MUN_INCIDENCIA = "";
  this.QTD_SERV = 0;
  this.SERIE_PRESTACAO = "";
  this.SERV_TRIBUTAVEL = "";
  this.TP_RECOLHIMENTO = "";
  this.VLR_DESCONTO = 0;
  this.VLR_TOTAL = 0;
  this.VLR_UNITARIO = 0;


  ///----------------------------------------------------------------------------------------------------------//
  this.excluir = function (pcodigo, pfilial, pfcallback) {
    var dados = {
      "id": pcodigo,
      "cdEmp": 1,
      "cdfilial": pfilial
    };

    params = JSON.stringify(dados);
    var fcalback = function (oresponse) {
      if (oresponse !== "") {
        jsonResult = JSON.parse(oresponse);
        if (typeof jsonResult.codretorno == "undefined") {
          doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
        } else {
          if (jsonResult.codretorno == 1) {

            doalert('success', ' Exclusão de dados', jsonResult.codretorno + ' - ' + jsonResult.msg);

          } else {
            doalert('info', ' Exclusão de dados', jsonResult.codretorno + ' - ' + jsonResult.msg);

          }
        };
      };
      pfcallback();
    }
    basicRequest("DELETE", _CT_SERVER_NFSE + '?' + params, params, fcalback);

  }
  ///----------------------------------------------------------------------------------------------------------//
  //ALTERAR  DADOS 
  ///----------------------------------------------------------------------------------------------------------//
  function alterar() {}
  ///----------------------------------------------------------------------------------------------------------//
  //INCLUIR DADOS
  ///----------------------------------------------------------------------------------------------------------//
  function inclur() {}
  ///----------------------------------------------------------------------------------------------------------//
  //EXIBIR UM RPS
  ///----------------------------------------------------------------------------------------------------------//
  this.exibirRps = function (idRps, cdFilial, oret, fclass) {
    var dados = {
      "ID": idRps,
      "CD_EMP": 1,
      "CD_FILIAL": cdFilial
    };
    //params = "{ \"id\":, \"cdEmp\": 1 }";
    params = JSON.stringify(dados);
    var fretornoExibirRps = function (oresponse) {
      if (oresponse !== "") {
        jsonConsulta = JSON.parse(oresponse);

        fclass.ID = jsonConsulta.data[0].ID;
        fclass.CD_EMP = jsonConsulta.data[0].CD_EMP;
        fclass.CD_FILIAL = jsonConsulta.data[0].CD_FILIAL;
        fclass.DT_COMP = jsonConsulta.data[0].DT_COMP;
        fclass.DT_EMIS = jsonConsulta.data[0].DT_EMIS;
        fclass.TP_RPS = jsonConsulta.data[0].DT_RPS;
        fclass.NUM_RPS = jsonConsulta.data[0].NUM_RPS;
        fclass.SERIE_RPS = jsonConsulta.data[0].SERIE_RPS;
        fclass.CD_NT_OP_SERVICO = jsonConsulta.data[0].CD_NT_OP_SERVICO;
        fclass.REG_ESP_TRIB = jsonConsulta.data[0].REG_ESP_TRIB;
        fclass.OPT_SIMPLES = jsonConsulta.data[0].OPT_SIMPLES;
        fclass.INCENT_FISCAL = jsonConsulta.data[0].INCENT_FISCAL;
        fclass.STATUS = jsonConsulta.data[0].STATUS;
        fclass.TRIB_MUN = jsonConsulta.data[0].TRIB_MUN;
        fclass.TRIB_PREST = jsonConsulta.data[0].TRIB_PREST;
        fclass.VLR_SERVICOS = jsonConsulta.data[0].VLR_SERVICOS;
        fclass.VLR_DEDUCOES = jsonConsulta.data[0].VLR_DEDUCOES;
        fclass.VLR_PIS = jsonConsulta.data[0].VLR_PIS;
        fclass.VLR_COFINS = jsonConsulta.data[0].VLR_COFINS;
        fclass.VLR_INSS = jsonConsulta.data[0].VLR_INSS;
        fclass.VLR_IR = jsonConsulta.data[0].VLR_IR;
        fclass.VLR_CSLL = jsonConsulta.data[0].VLR_CSLL;
        fclass.VLR_ISS = jsonConsulta.data[0].VLR_INSS;
        fclass.VLR_ISS_RET = jsonConsulta.data[0].VLR_ISS_RET;
        fclass.VLR_OTR_RETENCOES = jsonConsulta.data[0].VLR_OTR_RETENCOES;
        fclass.VLR_BASE_CALCULO = jsonConsulta.data[0].VLR_BASE_CALCULO;
        fclass.PERC_ALQ_ISS = jsonConsulta.data[0].PERC_ALQ_ISS;
        fclass.VLR_LIQUIDO_NFSE = jsonConsulta.data[0].VLR_LIQUIDO_NFSE;
        fclass.VLR_DESC_INCONDICIONADO = jsonConsulta.data[0].VLR_DESC_INCONDICIONADO;
        fclass.VLR_DESC_CONDICIONADO = jsonConsulta.data[0].VLR_DESC_CONDICIONADO;
        fclass.VLR_RED_BC = jsonConsulta.data[0].VLR_RED_BC;
        fclass.VLR_REPASSE = jsonConsulta.data[0].VLR_REPASSE;
        fclass.VLR_APROX_IMPOSTO = jsonConsulta.data[0].VLR_APROX_IMPOSTO;
        fclass.PERC_ALQ_APROX_IMPOSTO = jsonConsulta.data[0].PERC_ALQ_APROX_IMPOSTO;
        fclass.CNPJ_TOMADOR = jsonConsulta.data[0].CNPJ_TOMADOR;
        fclass.RZ_TOMADOR = jsonConsulta.data[0].RZ_TOMADOR;
        fclass.END_TOMADOR = jsonConsulta.data[0].END_TOMADOR;
        fclass.NR_TOMADOR = jsonConsulta.data[0].NR_TOMADOR;
        fclass.CPL_TOMADOR = jsonConsulta.data[0].CPL_TOMADOR;
        fclass.BAIRRO_TOMADOR = jsonConsulta.data[0].BAIRRO_TOMADOR;
        fclass.CD_MUN_TOMADOR = jsonConsulta.data[0].CD_MUN_TOMADOR;
        fclass.UF_TOMADOR = jsonConsulta.data[0].UF_TOMADOR;
        fclass.CEP_TOMADOR = jsonConsulta.data[0].CEP_TOMADOR;
        fclass.CNPJ_PRESTADOR = jsonConsulta.data[0].CNPJ_PRESTADOR;
        fclass.INSC_MUN_PRESTADOR = jsonConsulta.data[0].INSC_MUN_PRESTADOR;
        fclass.END_PRESTADOR = jsonConsulta.data[0].END_PRESTADOR;
        fclass.NR_PRESTADOR = jsonConsulta.data[0].NR_PRESTADOR;
        fclass.CPL_PRESTADOR = jsonConsulta.data[0].CPL_PRESTADOR;
        fclass.BAIRRO_PRESTADOR = jsonConsulta.data[0].BAIRRO_PRESTADOR;
        fclass.UF_PRESTADOR = jsonConsulta.data[0].UF_PRESTADOR;
        fclass.CEP_PRESTADOR = jsonConsulta.data[0].CEP_PRESTADOR;
        fclass.CD_PAIS_PRESTADOR = jsonConsulta.data[0].CD_PAIS_PRESTADOR;
        fclass.DDD_PRESTADOR = jsonConsulta.data[0].DDD_PRESTADOR;
        fclass.TEL_PRESTADOR = jsonConsulta.data[0].TEL_PRESTADOR;
        fclass.RZ_PRESTADOR = jsonConsulta.data[0].RZ_PRESTADOR;
        fclass.EMAIL_PRESTADOR = jsonConsulta.data[0].EMAIL_PRESTADOR;
        fclass.CIDADE_TOMADOR = jsonConsulta.data[0].CIDADE_TOMADOR;
        fclass.CIDADE_PRESTADOR = jsonConsulta.data[0].CIDADE_PRESTADOR;
        fclass.INDENTIFICACAO = jsonConsulta.data[0].INDENTIFICACAO;
        fclass.RPS_SUBSTITUIDO = jsonConsulta.data[0].RPS_SUBSTITUIDO;
        fclass.CODIGO_VERIFICACAO = jsonConsulta.data[0].CODIGO_VERIFICACAO;
        fclass.CHAVE_ACESSO = jsonConsulta.data[0].CHAVE_ACESSO;
        fclass.CD_PROD = jsonConsulta.data[0].CD_PROD;
        fclass.DS_PROD = jsonConsulta.data[0].DS_PROD;
        fclass.CD_CNAE = jsonConsulta.data[0].CD_CNAE;
        fclass.CD_TRIB_MUNICIPIO = jsonConsulta.data[0].CD_TRIB_MUNICIPIO;
        fclass.DESC_SERVICO = jsonConsulta.data[0].DESC_SERVICO;
        fclass.VLR_ISS_RETIDO = jsonConsulta.data[0].VLR_ISS_RETIDO;
        fclass.ITEM_LISTA_SERVICO = jsonConsulta.data[0].ITEM_LISTA_SERVICO;
        fclass.CD_MUN_INCIDENCIA = jsonConsulta.data[0].CD_MUN_INCIDENCIA;
        fclass.QTD_SERV = jsonConsulta.data[0].QTD_SERV;
        fclass.SERIE_PRESTACAO = jsonConsulta.data[0].SERIE_PRESTACAO;
        fclass.SERV_TRIBUTAVEL = jsonConsulta.data[0].SERV_TRIBUTAVEL;
        fclass.TP_RECOLHIMENTO = jsonConsulta.data[0].TP_RECOLHIMENTO;
        fclass.VLR_DESCONTO = jsonConsulta.data[0].VLR_DESCONTO;
        fclass.VLR_TOTAL = jsonConsulta.data[0].VLR_TOTAL;
        fclass.VLR_UNITARIO = jsonConsulta.data[0].VLR_UNITARIO;
        oret();
      } else {

        doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor ' + oresponse);
      }
    }
    basicRequest("GET", _CT_SERVER_NFSE + '?' + params, params, fretornoExibirRps);

  }
  ///----------------------------------------------------------------------------------------------------------//
  //VALIDAR RPS NO WEBSERVICE DA PREFEITURA
  ///----------------------------------------------------------------------------------------------------------//
  this.validarRps = function (idrps, cdfilial, oret) {

    var dados = {
      "idrps": idrps,
      "operacao": "validacao",
      "cdEmp": 1,
      "cdfilial": cdfilial
    };
    params = JSON.stringify(dados);
    var fcalback = function (oresponse) {
      oret();
      if (oresponse !== "") {
        jsonResult = JSON.parse(oresponse);
        if (typeof jsonResult.codretorno == "undefined") {
          doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
        } else {
          if (jsonResult.codretorno == 1) {

            doalert('success', ' Emissao nfse', jsonResult.codretorno + ' - ' + jsonResult.msg);

          } else {

            doalert('info', 'Falha Emissao nfse ', jsonResult.codretorno + ' - ' + jsonResult.msg);

          }
        }
      }
    }
    basicRequest("PUT", _CT_SERVER_NFSE + '?' + params, params, fcalback);

  }
  ///----------------------------------------------------------------------------------------------------------//
  //RETORNAR LISTA DE RPS PENDENTES  COM ERRO OU NÃO ENVIADAS
  ///----------------------------------------------------------------------------------------------------------//

  this.listar = function (oretlistar, astatus) {

    var fcalback = function (oresponse) {
      if (oresponse !== "") {
        jsonConsulta = null;
        if (IsJsonString(oresponse)) {
          jsonConsulta = JSON.parse(oresponse);
          if (typeof jsonConsulta.data == "undefined") {
            doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
          } else {

            oretlistar(jsonConsulta);

          }
        } else {
          doalert('error', 'Erro inteno', oresponse);

        }
      }
    }
    params = "{ \"status\":" + astatus + ", \"cdEmp\": 1 }";
    basicRequest("GET", _CT_SERVER_NFSE + '?' + params, params, fcalback);

  }
  ///----------------------------------------------------------------------------------------------------------//
  ///CANCELAR NFSE
  ///----------------------------------------------------------------------------------------------------------//
  this.cancelarNfse = function (idrps, cdfilial, oret) {

    var dados = {
      "idrps": idrps,
      "operacao": "cancelamento",
      "cdEmp": 1,
      "cdfilial": cdfilial
    };
    params = JSON.stringify(dados);
    var fcalback = function (oresponse) {
      oret();
      if (oresponse !== "") {
        jsonResult = JSON.parse(oresponse);
        if (typeof jsonResult.codretorno == "undefined") {
          doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
        } else {
          if (jsonResult.codretorno == 1) {

            doalert('success', ' Cancelamento nfse', jsonResult.codretorno + ' - ' + jsonResult.msg);

          } else {

            doalert('info', 'Cancelamento nfse ', jsonResult.codretorno + ' - ' + jsonResult.msg);

          }
        }
      }
    }
    basicRequest("PUT", _CT_SERVER_NFSE + '?' + params, params, fcalback);


  }

  ///----------------------------------------------------------------------------------------------------------//
  ///IMPRIMIR NFSE
  ///----------------------------------------------------------------------------------------------------------//
  this.imprimirNfse = function (idrps, cdfilial, oret) {

    var dados = {
      "idrps": idrps,
      "operacao": "imprimir",
      "cdEmp": 1,
      "cdfilial": cdfilial
    };
    params = JSON.stringify(dados);
    var fcalback = function (oresponse) {
      
      if (oresponse !== "") {
        jsonResult = JSON.parse(oresponse);
        if (typeof jsonResult.codretorno == "undefined") {
         oret('');             
          doalert('error', 'Imprimir nfse', 'Erro:Json não valido na resposta do servidor');
        } else {
             oret(jsonResult.arquivo)
            
            

        }
      }
    }
    basicRequest("PUT", _CT_SERVER_NFSE + '?' + params, params, fcalback);


  }


  ///----------------------------------------------------------------------------------------------------------//
  ///GRAVAR DADOS TOMADO E DA DESCRIÇÃO DO SERVIÇO
  ///----------------------------------------------------------------------------------------------------------//
  this.gravar = function (idRps, cdFilial, oret) {
      
    var dados = {
       "idrps": idRps,
      "operacao": "gravar",
      "cdEmp": 1,
      "cdfilial": cdFilial,
      "CNPJ_TOMADOR"  :$('#CNPJ_TOMADOR').val(),
      "RZ_TOMADOR"    :$('#RZ_TOMADOR').val(),
      "END_TOMADOR"   :$('#END_TOMADOR').val(),
      "NR_TOMADOR"    :$('#NR_TOMADOR').val(),
      "CPL_TOMADOR"   :$('#CPL_TOMADOR').val(),
      "BAIRRO_TOMADOR":$('#BAIRRO_TOMADOR').val(),
      "CD_MUN_TOMADOR":$('#CD_MUN_TOMADOR').val(),
      "UF_TOMADOR"    :$('#UF_TOMADOR').val(),
      "CEP_TOMADOR"   :$('#CEP_TOMADOR').val(),
      "DESC_SERVICO"   :$('#DESC_SERVICO').val()
      
    
    };
   
    params = JSON.stringify(dados);
    var fcalback = function (oresponse) {
      
      if (oresponse !== "") {
        jsonResult = JSON.parse(oresponse);
        if (typeof jsonResult.codretorno == "undefined") {
         oret('0');             
          doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
        } else {
             oret(jsonResult.codretorno )
            
            
            

        }
      }
    }
    basicRequest("POST", _CT_SERVER_NFSE + '?' + params, params, fcalback);


  }
}
