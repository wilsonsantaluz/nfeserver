/*----------------------------------------------------------------------------------------------
                                        2021
                                      wilson santa luz
----------------------------------------------------------------------------------------------*/
var ocnpj = 0;
var b64 = "";
var nomearquivo;
var inputPfx;
var odados;

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
    $('#UF').val('');
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
                $('#UF').val(jsonConsulta.listHelper[0].uf);
                $('#complemento').val(jsonConsulta.listHelper[0].complemento);
                $('#numero').val(jsonConsulta.listHelper[0].numero);
                $('#telefone').val(jsonConsulta.listHelper[0].telefone);
                $('#inscricaoMunicipal').val(jsonConsulta.listHelper[0].inscricaoMunicipa);
                $('#inscricaoEstadual').val(jsonConsulta.listHelper[0].inscricaoEstadua);
                $('#nomecertificadoPfx').val(jsonConsulta.listHelper[0].nomecertificadoPfx);                
                b64 = jsonConsulta.listHelper[0].certificadoPfx;
                nomearquivo = jsonConsulta.listHelper[0].nomecertificadoPfx;
                $('#senhaPfx').val(jsonConsulta.listHelper[0].senhaPfx);
                $('#validade').val(dataAmericana(jsonConsulta.listHelper[0].validade));
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
    $('#UF').val('');
    $('#numero').val('0');
    $('#telefone').val('');
    $('#inscricaoMunicipal').val('');
    $('#inscricaoEstadual').val('');
    $('#nomecertificadoPfx').val('');
    $('#certificadoPfx').val('');
    $('#senhaPfx').val('');
    $('#validade').val('');
    b64 = "";
    nomearquivo = "";

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
                if (jsonResult.codretorno == 200) {
                    getEmpresas();
                    doalert('success', 'Gravação de parametros', jsonResult.codretorno + ' - ' + jsonResult.msg);


                } else {
                    doalert('info', ' Gravação de parametros', jsonResult.codretorno + ' - ' + jsonResult.msg);

                }
            };
        };
    };

    var preparePost = function() {

        var pdados = {
            "cnpj": $('#cnpj').val(),
            "razaoSocial": $('#razaoSocial').val(),
            "Ambiente": $('#ambiente').prop('selectedIndex'),
            "endereco": $('#endereco').val(),
            "bairro": $('#bairro').val(),
            "cidade": $('#cidade').val(),
            "codMunicipio": $('#codMunicipio').val(),
            "complemento": $('#complemento').val(),
            "uf": $('#UF').val(),
            "numero": $('#numero').val(),
           
            "telefone": $('#telefone').val(),
            "inscricaoMunicipal": $('#inscricaoMunicipal').val(),
            "inscricaoEstadual": $('#inscricaoEstadual').val(),
            "nomecertificadoPfx": nomearquivo,
            "certificadoPfx":b64,
            "senhaPfx": $('#senhaPfx').val(),
            "validade": $('#validade').val()
        };
            odados =pdados;
            var oparam = JSON.stringify(pdados);
            $('#loading-indicator').show();
            basicRequest("POST", _CT_SERVER_NFE_EMPRESA,oparam , setEmpresaCallback);
        }
  
    if ($('#cnpj').val() == '') {
        alert('Cnpj e obrigatorio');
        return
    };
    if ($('#razaoSocial').val() == '') {
        alert('Razão social e obrigatoria');
        return
    };
    if ($('#validade').val() == '') {
        alert('Validade do certificado obrigatoria');
        return
    };
  
    var file = inputPfx.files[0];
    if (file) {
        
       
        reader = new FileReader();
        reader.onload = function() {
            nomearquivo = file.name;
            b64 = reader.result.replace(/^data:.+;base64,/, '');
            console.log('conteudo base 64 é  ' + b64);
            preparePost();
          
        };
        reader.readAsDataURL(file);

    } else {
        preparePost();
    }


}
//-----------------------------------------------------------------------------------------------------------------//
var listEmpresas = function() {
    function listEmpresasCallback(oresponse) {
        $('#loading-indicator').hide();

        //var myObj = JSON.parse(this.responseText);

        if (oresponse !== "") {

            jsonConsulta = JSON.parse(oresponse);
            $("#selectfiliais").empty();
          
            $("#selectfiliais").append(" <option value = '" +'0' + "' > " + 'Incluir novo/Limpar' +      "</option>");
                for (i = 0; i < jsonConsulta.listHelper.length; i++) {
                    var id = jsonConsulta.listHelper[i].cnpj;
                    var name = jsonConsulta.listHelper[i].cnpj + '-' + jsonConsulta.listHelper[i].razaoSocial
                    $("#selectfiliais").append(" <option value = '" + id + "' > " + name +      "</option>");
                }
            }

        };
        $('#loading-indicator').show();

        basicRequest("GET", _CT_SERVER_NFE_EMPRESA, "", listEmpresasCallback);

    
};

//*----------------------------------------------------------------------------------------------

empresaConfigMain = function() {
    "use strict";
    $('#small-version').text("version 21.06.02.1900");
    return {

        init: function() {



            inputPfx = document.querySelector('input[type=file]');
            $("#empresagravar").click(function() {
                setEmpresa();
            });

            $("#empresainserir").click(function() {
                prepareInsert();
            });

            $('#selectfiliais').change(function() {

                ocnpj = $('#selectfiliais').val();
                if (ocnpj == 0) {
                    prepareInsert();
                    return;
                };
                setTimeout(getEmpresas(ocnpj), 1000);
            });

            $("#empresareload").click(function() {
                $('#selectfiliais').val(0).change();
            });
            $(document).ready(function() {

                setTimeout(listEmpresas(), 10);
                prepareForm.init();

            });
        }
    };
}();

/*----------------------------------------------------------------------------------------------
  
-----------------------------------------------------------------------------------------------*/