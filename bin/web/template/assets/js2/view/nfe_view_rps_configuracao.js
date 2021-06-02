/*----------------------------------------------------------------------------------------------
                                         linx 2019
                                      wilson santa luz
----------------------------------------------------------------------------------------------*/
var ofilial =0
function getEmpresas() {
	function getEmpresasCallback(oresponse) {
		$('#loading-indicator').hide();
		if (oresponse !== "") {
			var oparam = "";
			var ovalor = "";
			if (IsJsonString(oresponse)) {
				jsonConsulta = JSON.parse(oresponse);				
				$('#cnpj').val(jsonConsulta.data[0].cnpj); 
                $('#razaoSocial').val(jsonConsulta.data[0].razaoSocial);
                $('#endereco').val(jsonConsulta.data[0].endereco);
	            $('#bairro').val(jsonConsulta.data[0].bairro);
                $('#cidade').val(jsonConsulta.data[0].cidade);
                $('#codMunicipio').val(jsonConsulta.data[0].codMunicipio);
	            $('#complemento').val(jsonConsulta.data[0].complemento);
	            $('#numero').val(jsonConsulta.data[0].numero);
	            $('#telefone').val(jsonConsulta.data[0].telefone); 
	            $('#inscricaoMunicipal').val(jsonConsulta.data[0].inscricaoMunicipa);	
				$('#inscricaoEstadual').val(jsonConsulta.data[0].inscricaoEstadua);				  
				$('#certificadoPfx').val(jsonConsulta.data[0].certificadoPfx);				
                $('#senhaPfx').val(jsonConsulta.data[0].senhaPfx');			
				$('#validade').val (jsonConsulta.data[0].validade);
				$('#ambiente').prop('selectedIndex', jsonConsulta.data[0].ambiente);
			} else {
				doalert('error', 'Erro inteno', oresponse);
			}

		} else {

			doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
		}
	}    
    var dados = {
        "Filial":ofilial
	};
	var oparam = JSON.stringify(dados);
    $('##cnpj').val('');
    $('#ambiente').prop('selectedIndex',0);
    $('#razaoSocial').val('');
    $('#endereco').val('');
	$('#bairro').val('');
	$('#cidade').val('');
    $('#codMunicipio').val('');
	$('#complemento').val('');
	$('#numero').val('0');
	$('#telefone').val(''); 
	$('#inscricaoMunicipal').val('');
	$('#inscricaoEstadual').val('');
	$('#certificadoPfx').val('');
	$('#senhaPfx').val('');
	$('#validade').val('');

	$('#loading-indicator').show();
	basicRequest("GET", _CT_SERVER_NFSE_CONFIG+'?'+oparam,oparam, getEmpresasCallback);
}
//-----------------------------------------------------------------------------------------------------------------//
function setRpsConfig() {

	var setRpsConfigCallback = function(oresponse) {
		$('#loading-indicator').hide();
		if (oresponse !== "") {
			jsonResult = JSON.parse(oresponse);
			if (typeof jsonResult.codretorno == "undefined") {
				doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
			} else {
				if (jsonResult.codretorno == 1) {
					getEmpresas();
					doalert('success', 'Gravação de parametros', jsonResult.codretorno + ' - ' + jsonResult.msg);


				} else {
					doalert('info', ' Gravação de parametros', jsonResult.codretorno + ' - ' + jsonResult.msg);

				}
			};
		};
	};
	var dados = {
        "Filial":ofilial, 
		"Cd_mov_op": $('#CD_MOV_OP').val(),
		"Ambiente": $('#AMBIENTE').prop('selectedIndex'),
		"Serie": $('#SERIE').val(),
		"Senha_webServer": $('#SENHA_WEBSERVER').val(),
		"Usuario_prefeitura": $('#USUARIO_PREFEITURA').val(),
		"Frase_secreta": $('#FRASE_SECRETA').val(),		
		"Ultimo_lote_enviado": $('#ULTIMO_LOTE_ENVIADO').val(),
		"Perc_iss": $('#PERC_ISS').val(),
		"Perc_ir": $('#PERC_IR').val(),
	    "Cd_trib_municipio": $('#CD_TRIB_MUNICIPIO').val(), 
		"Cnae": $('#CNAE').val(),
		"SenhaCertificado": $('#SENHA_CERTIFICADO').val(),
		"ArquivoPfx": $('#ARQUIVOPFX').val(),		
		"Envio_auto": $('#ENVIO_AUTO').prop('checked')

	};

	var oparam = JSON.stringify(dados);

	$('#loading-indicator').show();
	basicRequest("POST", _CT_SERVER_EMPRESA, oparam, setRpsConfigCallback);
}
//-----------------------------------------------------------------------------------------------------------------//
var listEmpresas = function() {
	function listEmpresasCallback(oresponse) {
		$('#loading-indicator').hide();

		//var myObj = JSON.parse(this.responseText);
		if (oresponse !== "") {
			var oresponse = $.parseJSON(oresponse);
			$("#selectfiliais").empty();
			$("#selectfiliais").append(
				"<option value=0>Nada selecionado  </option>");
			for (i = 0; i < oresponse.data.length; i++) {
				var id = oresponse.data[i].cnpj;
				var name = oresponse.data[i].cnpj + '-' + oresponse.data[i].razaoSocial
				$("#selectfiliais").append("<option value='" + id + "'>" + name +
					"</option>");
			}
		}

	};
	$('#loading-indicator').show();
	basicRequest("GET", _CT_SERVER_EMPRESAS, "", listEmpresasCallback);

};

/*----------------------------------------------------------------------------------------------
                       
------------------------------------------------------------------------------------------------
*/
rpsConfigMain = function() {
	"use strict";
	$('#small-version').text("version 21.06.02.1900");
	return {

		init: function() {

			$("#rpsgravar").click(function() {
				setRpsConfig();
			});

			$('#selectfiliais').change( function() {
              
				ofilial = $('#selectfiliais').val();
				if (ofilial == 0) {
					alert('Selecione a filial');
					return
				};
				setTimeout(getEmpresas(ofilial), 1000);
			});

			$("#rpsreload").click(function() {
				getEmpresas();
			});
			$(document).ready(function() {
				setTimeout(listEmpresas(), 10);
			});
		}
	};
}();

/*----------------------------------------------------------------------------------------------
  
-----------------------------------------------------------------------------------------------*/