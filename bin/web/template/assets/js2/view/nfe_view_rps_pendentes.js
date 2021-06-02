/*----------------------------------------------------------------------------------------------
                                         linx 2019
                                      wilson santa luz
----------------------------------------------------------------------------------------------
*/
var objDataTableRps;
var indcol = 0;
var Frps = new Trps_class(0);
var glbidRps ;
var glbcdfilial ;
var versionFile ="21.04.14.1000";


function popularModal() {
    $('#ID_RPS').val(padleft(Frps.ID, 6));
    $('#CD_EMP').val(Frps.CD_EMP);
    $('#CD_FILIAL').val(padleft((Frps.CD_FILIAL).toString(), 3));
    $('#DT_COMP').val(isostrtodate(Frps.DT_COMP));
    $('#DT_EMIS').val(isostrtodate(Frps.DT_EMIS));
    $('#TP_RPS').val(Frps.TP_RPS);
    $('#NUM_RPS').val(padleft((Frps.NUM_RPS).toString(), 6));
    $('#SERIE_RPS').val(Frps.SERIE_RPS);
    $('#CD_NT_OP_SERVICO').val(Frps.CD_NT_OP_SERVICO);
    $('#REG_ESP_TRIB').val(Frps.REG_ESP_TRIB);
    $('#OPT_SIMPLES').val(Frps.OPT_SIMPLES);
    $('#INCENT_FISCAL').val(Frps.INCENT_FISCAL);
    $('#TRIB_MUN').val(Frps.TRIB_MUN);
    $('#TRIB_PREST').val(parseFloat(Frps.TRIB_PREST).toFixed(2));
    $('#VLR_SERVICOS').val(parseFloat(Frps.VLR_SERVICOS).toFixed(2));
    $('#VLR_DEDUCOES').val(parseFloat(Frps.VLR_DEDUCOES).toFixed(2));
    $('#VLR_PIS').val(parseFloat(Frps.VLR_PIS).toFixed(2));
    $('#VLR_COFINS').val(parseFloat(Frps.VLR_COFINS).toFixed(2));
    $('#VLR_INSS').val(parseFloat(Frps.VLR_INSS).toFixed(2));
    $('#VLR_CSLL').val(parseFloat(Frps.VLR_CSLL).toFixed(2));
    $('#VLR_ISS').val(parseFloat(Frps.VLR_ISS).toFixed(2));
    $('#VLR_ISS_RED').val(parseFloat(Frps.VLR_ISS_RET).toFixed(2));
    $('#VLR_OTR_RETENCOES').val(parseFloat(Frps.VLR_OTR_RETENCOES).toFixed(2));
    $('#VLR_BASE_CALCULO').val(parseFloat(Frps.VLR_BASE_CALCULO).toFixed(2));
    $('#PERC_ALQ_ISS').val(parseFloat(Frps.PERC_ALQ_ISS).toFixed(2));
    $('#VLR_LIQUIDO_NFSE').val(parseFloat(Frps.VLR_LIQUIDO_NFSE).toFixed(2));
    $('#VLR_DESC_INCONDICIONADO').val(parseFloat(Frps.VLR_DESC_INCONDICIONADO).toFixed(2));
    $('#VLR_DESC_CONDICIONADO').val(parseFloat(Frps.VLR_DESC_CONDICIONADO).toFixed(2));
    $('#VLR_RED_BC').val(parseFloat(Frps.VLR_RED_BC).toFixed(2));
    $('#VLR_REPASSE').val(parseFloat(Frps.VLR_REPASSE).toFixed(2));
    $('#VLR_APROX_IMPOSTO').val(parseFloat(Frps.VLR_APROX_IMPOSTO).toFixed(2));
    $('#PERC_ALQ_APROX_IMPOSTO ').val(parseFloat(Frps.PERC_ALQ_APROX_IMPOSTO).toFixed(2));
    $('#CNPJ_TOMADOR').val(Frps.CNPJ_TOMADOR);
    $('#RZ_TOMADOR').val(Frps.RZ_TOMADOR);
    $('#END_TOMADOR ').val(Frps.END_TOMADOR);
    $('#NR_TOMADOR').val(Frps.NR_TOMADOR);
    $('#CPL_TOMADOR').val(Frps.CPL_TOMADOR);
    $('#BAIRRO_TOMADOR').val(Frps.BAIRRO_TOMADOR);
    $('#CD_MUN_TOMADOR').val(Frps.CD_MUN_TOMADOR);
    $('#UF_TOMADOR').val(Frps.UF_TOMADOR);
    $('#CEP_TOMADOR').val(Frps.CEP_TOMADOR);
    $('#CNPJ_PRESTADOR').val(Frps.CNPJ_PRESTADOR);
    $('#INSC_MUN_PRESTADOR').val(Frps.INSC_MUN_PRESTADOR);
    $('#END_PRESTADOR').val(Frps.END_PRESTADOR);
    $('#NR_PRESTADOR ').val(Frps.NR_PRESTADOR);
    $('#CPL_PRESTADOR').val(Frps.CPL_PRESTADOR);
    $('#BAIRRO_PRESTADOR').val(Frps.BAIRRO_PRESTADOR);
    $('#UF_PRESTADOR').val(Frps.UF_PRESTADOR);
    $('#CEP_PRESTADOR').val(Frps.CEP_PRESTADOR);
    $('#CD_PAIS_PRESTADOR').val(Frps.CD_PAIS_PRESTADOR);
    $('#DDD_PRESTADOR').val(Frps.DDD_PRESTADOR);
    $('#TEL_PRESTADOR').val(Frps.TEL_PRESTADOR);
    $('#RZ_PRESTADOR').val(Frps.RZ_PRESTADOR);
    $('#EMAIL_PRESTADOR').val(Frps.EMAIL_PRESTADOR);
    $('#CIDADE_TOMADOR').val(Frps.CIDADE_TOMADOR);
    $('#CIDADE_PRESTADOR').val(Frps.CIDADE_PRESTADOR);
    $('#INDENTIFICACAO').val(Frps.INDENTIFICACAO);
    $('#RPS_SUBSTITUIDO ').val(Frps.RPS_SUBSTITUIDO);
    $('#CODIGO_VERIFICACAO').val(Frps.CODIGO_VERIFICACAO);
    $('#CHAVE_ACESSO').val(Frps.CHAVE_ACESSO);
    $('#CD_PROD').val(Frps.CD_PROD);
    $('#DS_PROD').val(Frps.DS_PRO);
    $('#CD_CNAE').val(Frps.CD_CNAE);
    $('#CD_TRIB_MUNICIPIO').val(Frps.CD_TRIB_MUNICIPIO);
    $('#DESC_SERVICO').val(Frps.DESC_SERVICO);
    $('#VLR_ISS_RETIDO').val(parseFloat(Frps.VLR_ISS_RETIDO).toFixed(2));
    $('#ITEM_LISTA_SERVICO').val(Frps.ITEM_LISTA_SERVICO);
    $('#CD_MUN_INCIDENCIA').val(Frps.CD_MUN_INCIDENCIA);
    $('#QTD_SERV').val(Frps.QTD_SERV);
    $('#SERIE_PRESTACAO').val(Frps.SERIE_PRESTACAO);
    $('#SERV_TRIBUTAVEL').val(Frps.SERV_TRIBUTAVEL);
    $('#TP_RECOLHIMENTO').val(Frps.TP_RECOLHIMENTO);
    $('#VLR_DESCONTO').val(parseFloat(Frps.VLR_DESCONTO).toFixed(2));
    $('#VLR_TOTAL').val(parseFloat(Frps.VLR_TOTAL).toFixed(2));
    $('#VLR_UNITARIO').val(parseFloat(Frps.VLR_UNITARIO).toFixed(2));
    if (Frps.STATUS == 0) {
        $('#STATUS').val('Não processado');
    };
    if (Frps.STATUS == 1) {
        $('#STATUS').val('Validado');
    };
    if (Frps.STATUS == 2) {
        $('#STATUS').val('Erro');
    }
    if (Frps.STATUS == 3) {
        $('#STATUS').val('Cancelado');
    }
     if (Frps.STATUS == 4) {
        $('#STATUS').val('Enviado');
    }
     $('#rpsgravar').prop( "disabled", false );
    $('#CNPJ_TOMADOR').prop('readOnly',false);
    $('#RZ_TOMADOR').prop('readOnly',false);
    $('#END_TOMADOR').prop('readOnly',false);
    $('#NR_TOMADOR').prop('readOnly',false);
    $('#CPL_TOMADOR').prop('readOnly',false);
    $('#BAIRRO_TOMADOR').prop('readOnly',false); 
    $('#CD_MUN_TOMADOR').prop('readOnly',false);
    $('#UF_TOMADOR').prop('readOnly',false);
    $('#CEP_TOMADOR').prop('readOnly',false);
    $('#DESC_SERVICO').prop('readOnly',false);
  
    
    handleFormMaskedInput();
    handleDatepicker();
}

/*----------------------------------------------------------------------------------------------
                                        FUNCÕES DE ACESSO AO SERVIDOR
------------------------------------------------------------------------------------------------
*/
function gravarRps (){
  function oret(cod){
      $('#loading-indicator').hide();
      if (cod =='200') {
            doalert('success', 'Atualização',jsonResult.msgretorno);
        } else
        {
          doalert('error', 'Atualização',jsonResult.msgretorno);  
            } ;
  };
  $('#loading-indicator').show();  
  Frps.gravar(glbidRps, glbcdfilial, oret);     
};
function excluirRps(codigo, cdfilial) {
    function fcalback() {
        listarRps();
       $('#loading-indicator').hide();  
    }
    $('#loading-indicator').show(); 
    Frps.excluir(codigo, cdfilial, fcalback);
};
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function validarselecionados() {
    function fcalback() {
        listarRps();
        $('#loading-indicator').hide();
    }
    $('#loading-indicator').show();
    try {
        var data = objDataTableRps.rows({
            selected: true
        }).data();
        var newarray = [];
        for (var i = 0; i < data.length; i++) {
            newarray.push(data[i][1]);

        }
        if (newarray.length < 1) {
            $('#loading-indicator').hide();
            doalert('error', 'Nehum Rps selecionado ');

        } else {

            pdata = newarray.join();
            Frps.validarRps(pdata, 0, fcalback);
        }
    } catch {
        $('#loading-indicator').hide();

    }
};
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function validarRps(idrps, cdfilial) {
    function oret() {

        $('#loading-indicator').hide();
        listarRps();
    };
    $('#loading-indicator').show();
    Frps.validarRps(idrps, cdfilial, oret);
};

function exibirRps(idRps, cdfilial) {

    function oret() {

        $('#loading-indicator').hide();
        $.get('ajax/modal/nfse_modal.html', function(html) {

            var FobjModal = $('#htmlobjModal');
            FobjModal.remove();
            $(html).appendTo('body').modal();
            popularModal();
        });

    };
    glbidRps =idRps;
    glbcdfilial =cdfilial;
    Frps.exibirRps(idRps, cdfilial, oret, Frps);

}
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function listarRps() {
    function oretlistar(jsonConsulta) {
        var ostatus;
        array_rpspend = [];
        for (var i = 0; i < jsonConsulta.data.length; i++) {
             ostatus = 'Pendente';
            if (jsonConsulta.data[i].STATUS == 1) {
                ostatus = 'Validado';
            };
            if (jsonConsulta.data[i].STATUS == 2) {
                ostatus = 'Erro';
            }
            if (jsonConsulta.data[i].STATUS == 3) {
                ostatus = 'Cancelado';
            }
            if (jsonConsulta.data[i].STATUS == 4) {
                ostatus = 'Enviado';
            }

            var rps = [
                '',
                jsonConsulta.data[i].ID,
                jsonConsulta.data[i].CD_FILIAL,
                jsonConsulta.data[i].DT_EMIS,
                jsonConsulta.data[i].NUM_RPS,
                jsonConsulta.data[i].VLR_LIQUIDO_NFSE,
                jsonConsulta.data[i].RZ_TOMADOR,
                ostatus,
                jsonConsulta.data[i].ERRO
            ];
            array_rpspend.push(rps);

        }

        objDataTableRps.clear();
        objDataTableRps.rows.add(array_rpspend);
        objDataTableRps.draw();
        $('#loading-indicator').hide();

    };

    try {
        var ostatus = 0;
        $('#loading-indicator').show(); 
        Frps.listar(oretlistar, ostatus);
    } catch {
        $('#loading-indicator').hide();
    }
};

/*----------------------------------------------------------------------------------------------
                            PREPARAR O DATATABLE
------------------------------------------------------------------------------------------------
*/
var configDataTable = function() {
    "use strict";

    if ($('#data-table-rpspendentes').length !== 0) {
        objDataTableRps = $('#data-table-rpspendentes').DataTable({

            dom: 'lBfrtip',

            buttons: [{
                    extend: "copyHtml5",

                    text: "<i style=\"font-size:14px ;\" class=\"fa fa-files-o\"></i>",
                    className: " btn btn-primary ",
                    titleAttr: "Copiar para area de trabalho"
                },
                {
                    extend: "print",
                    className: " btn btn-info  ",
                    text: "<i style=\"font-size:14px; \"  class=\"fa fa-print\"></i>",
                    titleAttr: "Imprimir",

                }

                , {
                    extend: "pdf",
                    className: " btn btn-danger",
                    text: "<i style=\"font-size:14px;\"  class=\"fa fa-file-pdf-o\"></i>",
                    titleAttr: "Exportar pdf",

                }, {
                    extend: "excel",
                    className: "btn btn-success",
                    titleAttr: "Exportar excel",
                    text: "<i style=\"font-size:14px ;\"  class=\"fa fa-file-excel-o\"> </i> ",

                },
                {

                    titleAttr: "Atualizar",
                    className: "btn btn-success",
                    text: "<i style=\"font-size:14px ;\" class=\"fa fa-refresh \"> </i>  Atualizar",
                    style: "font-weight: 600 !important;margin-left: 5px",
                    type: "POST",
                    action: function(e, dt, node, config, pdata) {
                        objDataTableRps.clear();
                        objDataTableRps.rows.add([]);
                        objDataTableRps.draw();
                        listarRps();
                    }
                }

                , {

                    titleAttr: "Reprocessar",
                    className: "btn btn-warning",
                    text: "<i style=\"font-size:14px ;\" class=\"fa fa-retweet \"> </i>  Reprocessar",
                    style: "font-weight: 600 !important;margin-left: 5px",
                    type: "POST",
                    action: function(e, dt, node, config, pdata) {
                        validarselecionados();

                    }
                }
            ],
            responsive: true,
            autoFill: true,
            colReorder: false,
            keys: false,
            rowReorder: false,
            select: true,
            lengthMenu: [100, 200, 500, 1000],
            "aoColumns": [{

                    "name": "FieldMaster",
                    "title": "<input id=\"boxsel\" type=\"checkbox\"></input>",
                    "name": "boxsel"
                },
                {
                    "sTitle": "Cód",
                    "sClass": "calingleft",
                    render: function(data, type, row) {
                        return padleft(row[1], 6)
                    }
                },

                {
                    "sTitle": "Filial",
                    "sClass": "calingleft",
                    render: function(data, type, row) {
                        return padleft(row[2], 6)
                    }
                },
                {
                    "sTitle": "Data"
                },
                {
                    "sTitle": "N°",
                    "sClass": "calingleft",
                    render: function(data, type, row) {
                        return padleft(row[4], 6)
                    }
                },
                {
                    "sTitle": "Valor",
                    render: $.fn.dataTable.render.number(',', '.', 2, 'R$'),
                    "sClass": "calingleft"
                },
                {
                    "sTitle": "Tomador"
                },
                {
                    "sTitle": "Status"
                },
                {
                    "sTitle": "Erro"
                }

            ],

            "columnDefs": [

                {

                    "data": null,
                    orderable: false,
                    "targets": 0,
                    "defaultContent": "<div class= \"dropdown autodropdon\" style=\"font-size:18px\"> " +
                        "<a href=\"javascript:;\" class=\"dropdown-toggle\" data-toggle=\"dropdown\"> " +
                        "<img id=\"ImgUser\" src=\"ico/gear.png\" style=\"font-size:16;\" alt=\"\"></a> " +
                        "<ul class=\"dropdown-menu\" style=\"font-size:18;\">  " +
                        "<li class=\"dropdown-header bg-indigo text-white\"></li>  " +
                        "<li><a href=\"#\" id=\"ivalidar\"    class=\"popconsulta fa fa-cloud-upload\">  Enviar rps</a></li>  " +
                        "<li><a href=\"#\" id=\"ieditar\"     class=\"popconsulta fa fa-eye\">  Visualizar rps</a></li>  " +
                        "<li><a href=\"#\" id=\"icancelar\"   class=\"popconsulta fa fa-ban\">  Excluir rps</a></li> " +
                        "</ul> " +
                        "</div> "

                }
               
            ],
            language: {
                "lengthMenu": "Mostrar  _MENU_  itens ",
                "zeroRecords": "Nada encontrado",
                "info": "Total: _MAX_ Registro(s) -  Pagina:  _PAGE_ /  _PAGES_ ",
                "infoEmpty": "Sem dados",
                "loadingRecords": "Carregando...",
                "processing": "Carregando...",
                "search": "Pesquisa:",
                "infoFiltered": "(Filtrado _TOTAL_ )",
                "select": {
                    "rows": {
                        "0": "",
                        "1": "Selecionado 1 linha",
                        "_": "Selecionados %d linhas"
                    }
                },
                "paginate": {
                    "previous": "Anterior",
                    "next": "Proximo",
                    "last": "Ultima",
                    "First": "Primeira"
                }
            },
            processing: true
        });
        $('#data-table tbody').on('click', '#bteditar', function() {
            var data = objDataTableRps.row($(this).parents('tr')).data();
            doalert('error', 'Erro inteno', 'validação não disponivel');
        });

        $('#data-table tbody').on('click', '#cancelar', function() {
            var data = objDataTableRps.row($(this).parents('tr')).data();
            doalert('error', 'Erro inteno', 'cancelamento não disponivel');

        });

        $("#data-table-rpspendentes thead").on("click", "#boxsel", function() {

            if ($("#boxsel").hasClass("selected")) {
                objDataTableRps.rows().deselect();
                $("#boxsel").removeClass("selected");
            } else {
                objDataTableRps.rows({
                    filter: "applied"
                }).select();
                $("#boxsel").addClass("selected");
            }
        });

        $("#data-table-rpspendentes tbody").on("click", "#ivalidar", function() {
            var rowData = objDataTableRps.row($(this).parents("tr")).data();
            var id = objDataTableRps.row($(this).parents("tr")).data()[1];
            var cdfilial = objDataTableRps.row($(this).parents("tr")).data()[2];
            validarRps(id, cdfilial);
        });

        $("#data-table-rpspendentes tbody").on("click", "#ieditar", function() {
            var rowData = objDataTableRps.row($(this).parents("tr")).data();
            var id = objDataTableRps.row($(this).parents("tr")).data()[1];
            var cdfilial = objDataTableRps.row($(this).parents("tr")).data()[2];
            $(this).addClass("selected");
            exibirRps(id, cdfilial);
        });

        $("#data-table-rpspendentes tbody").on("click", "#iconsultar", function() {
            var rowData = objDataTableRps.row($(this).parents("tr")).data();
            var id = objDataTableRps.row($(this).parents("tr")).data()[1];
            $(this).addClass("selected");
            doalert('success', 'Painel NFSE', 'Inciada consulta da  RPS:   ' + id);
        });

        $("#data-table-rpspendentes tbody").on("click", "#icancelar", function() {
            var rowData = objDataTableRps.row($(this).parents("tr")).data();
            var id = objDataTableRps.row($(this).parents("tr")).data()[1];
            var cdfilial = objDataTableRps.row($(this).parents("tr")).data()[2];
            $(this).addClass("selected");
            excluirRps(id, cdfilial);
        });
        $("#data-table-rpspendentes tbody").on("dblclick", "td", function() {
            indcol = $(this).index();
        });
        $("#data-table-rpspendentes tbody").on("click", "td", function() {
            indcol = $(this).index();
        });
        $("#data-table-rpspendentes tbody").on("click", "tr", function() {
            var rowData = objDataTableRps.row($(this)).data();
            var ttipo = "clk";
            var col = indcol
            var id = objDataTableRps.row($(this)).data()[0];

        });

    }
};
/*----------------------------------------------------------------------------------------------
                       
------------------------------------------------------------------------------------------------
*/
rpsviewMain = function() {
    "use strict";
    $('#small-version').text("version "+versionFile);
    return {
        //main function
        init: function() {
            configDataTable();

            $(document).ready(function() {
                setTimeout(listarRps(), 1000);
            });
        }
    };
}();

/*----------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
*/