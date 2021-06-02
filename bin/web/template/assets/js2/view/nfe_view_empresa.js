/*----------------------------------------------------------------------------------------------
                                         linx 2021
                                      wilson santa luz
----------------------------------------------------------------------------------------------*/
var ocnpj = 0

function prepareInsert() {
    $('#cnpj').prop('readonly', false);
    $('#cnpj').val('');
    $('#ambiente').prop('selectedIndex', 0);
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
    $('#cnpj').focus();
}

function getEmpresas() {
    function getEmpresasCallback(oresponse) {
        $('#loading-indicator').hide();
        if (oresponse !== "") {
            var oparam = "";
            var ovalor = "";
            if (IsJsonString(oresponse)) {
                jsonConsulta = JSON.parse(oresponse);
				$('#cnpj').prop('readonly', true);
                $('#cnpj').val(jsonConsulta.listHelper[0].cnpj);
                $('#razaoSocial').val(jsonConsulta.listHelper[0].razaoSocial);
                $('#endereco').val(jsonConsulta.listHelper[0].endereco);
                $('#bairro').val(jsonConsulta.listHelper[0].bairro);
                $('#cidade').val(jsonConsulta.listHelper[0].cidade);
                $('#codMunicipio').val(jsonConsulta.listHelper[0].codMunicipio);
                $('#complemento').val(jsonConsulta.listHelper[0].complemento);
                $('#numero').val(jsonConsulta.listHelper[0].numero);
                $('#telefone').val(jsonConsulta.listHelper[0].telefone);
                $('#inscricaoMunicipal').val(jsonConsulta.listHelper[0].inscricaoMunicipa);
                $('#inscricaoEstadual').val(jsonConsulta.listHelper[0].inscricaoEstadua);
                $('#certificadoPfx').val(jsonConsulta.listHelper[0].certificadoPfx);
                $('#senhaPfx').val(jsonConsulta.listHelper[0].senhaPfx);
                $('#validade').val(jsonConsulta.listHelper[0].validade);
                $('#ambiente').prop('selectedIndex', jsonConsulta.listHelper[0].ambiente);
            } else {
                doalert('error', 'Erro inteno', oresponse);
            }

        } else {

            doalert('error', 'Erro inteno', 'Erro:Json não valido na resposta do servidor');
        }
    }
    var dados = {
        "cnpj": ocnpj
    };
    var oparam = JSON.stringify(dados);
    $('#cnpj').val('');
    $('#ambiente').prop('selectedIndex', 0);
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
    basicRequest("GET", _CT_SERVER_NFE_EMPRESA + '?' + oparam, oparam, getEmpresasCallback);
}
//-----------------------------------------------------------------------------------------------------------------//
function setEmpresa() {

    var setEmpresaCallback = function(oresponse) {
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
        "cnpj": $('#cnpj').val(),
        "razaoSocial": $('#razaoSocial').val(),
        "Ambiente": $('#ambiente').prop('selectedIndex'),
        "endereco": $('#endereco').val(),
        "bairro": $('#bairro').val(),
        "cidade": $('#cidade').val(),
        "codMunicipio": $('#codMunicipio').val(),
        "complemento": $('#complemento').val(),
        "numero": $('#numero').val(),
        "telefone": $('#telefone').val(),
        "inscricaoMunicipal": $('#inscricaoMunicipal').val(),
        "inscricaoEstadual": $('#inscricaoEstadual').val(),
        "certificadoPfx": $('#certificadoPfx').val(),
        "senhaPfx": $('#senhaPfx').val(),
        "validade": $('#validade').val()


    };
	if ($('#cnpj').val() == '') { alert('Cnpj e obrigatorio'); return };
	
	if ($('#razaoSocial').val() == '') { alert('Razão social e obrigatoria'); return };
	if ($('#validade').val() == '') { alert('Validade do certificado obrigatoria'); return }
    
    var oparam = JSON.stringify(dados);
    $('#loading-indicator').show();
    basicRequest("POST", _CT_SERVER_NFE_EMPRESA, oparam, setEmpresaCallback);
}
//-----------------------------------------------------------------------------------------------------------------//
var listEmpresas = function() {
    function listEmpresasCallback(oresponse) {
        $('#loading-indicator').hide();

        //var myObj = JSON.parse(this.responseText);
		
        if (oresponse !== "") {
         
            jsonConsulta = JSON.parse(oresponse);
			$("#selectfiliais").empty();
            $("#selectfiliais").append(
                "<option value=0>Nada selecionado  </option>");
            for (i = 0; i < jsonConsulta.listHelper.length; i++) {
                var id = jsonConsulta.listHelper[i].cnpj;
                var name = jsonConsulta.listHelper[i].cnpj + '-' + jsonConsulta.listHelper[i].razaoSocial
                $("#selectfiliais").append("<option value='" + id + "'>" + name +
                    "</option>");
            }
        }

    };
    $('#loading-indicator').show();
	
    basicRequest("GET", _CT_SERVER_NFE_EMPRESA, "", listEmpresasCallback);

};

/*----------------------------------------------------------------------------------------------
                       
------------------------------------------------------------------------------------------------
*/
rpsConfigMain = function() {
    "use strict";
    $('#small-version').text("version 21.06.02.1900");
    return {

        init: function() {

            $("#empresagravar").click(function() {
                setEmpresa();
            });

            $("#empresainserir").click(function() {
                prepareInsert();
            });


            $('#selectfiliais').change(function() {

                ocnpj = $('#selectfiliais').val();
                if (ocnpj == 0) {
                    alert('Selecione a empresa');
                    return
                };
                setTimeout(getEmpresas(ocnpj), 1000);
            });

            $("#emporesareload").click(function() {
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