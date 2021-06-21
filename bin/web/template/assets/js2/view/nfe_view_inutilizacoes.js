inutilizacaoView = function() {
    "use strict";
    var objTabela;
    var indiceColuna = 0;
    var inuClass = new inutilizacaoClass;

    //-------------------------------------------------------------------------------
    this.listarInutilizacoes = function() {
        function oretlistar(jsonConsulta) {
            var array_inutilizacoes = [];

            for (var i = 0; i < jsonConsulta.listHelper.length; i++) {
                var inutilizacao = [
                    '',
                    jsonConsulta.listHelper[i].cnpj,
                    jsonConsulta.listHelper[i].numeroInicial,
                    jsonConsulta.listHelper[i].numeroFinal,
                    jsonConsulta.listHelper[i].serie,
                    jsonConsulta.listHelper[i].modelo,
                    jsonConsulta.listHelper[i].ano,
                    jsonConsulta.listHelper[i].justificativa,
                    jsonConsulta.listHelper[i].cstat,
                    jsonConsulta.listHelper[i].xmotivo,
                    jsonConsulta.listHelper[i].protocolo
                ];
                array_inutilizacoes.push(inutilizacao);
            }
            objTabela.clear();
            objTabela.rows.add(array_inutilizacoes);
            objTabela.draw();
            $('#loading-indicator').hide();
        };
        var ostatus = 1;
        objTabela.clear();
        var prep_arrray = [];
        objTabela.rows.add(prep_arrray);
        objTabela.draw();
        $('#loading-indicator').show();
        inuClass.listar(oretlistar, ostatus);
    };
    /*----------------------------------------------------------------------------------------------
                                      PREPARAR O DATATABLE
    ------------------------------------------------------------------------------------------------
    */
    this.configDataTable = function() {
        "use strict";
        if ($('#data-table-inutilizacoes').length !== 0) {
            objTabela = $('#data-table-inutilizacoes').DataTable({

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

                    }, {
                        extend: "pdf",
                        className: " btn btn-danger",
                        text: "<i style=\"font-size:14px;\"  class=\"fa fa-file-pdf-o\"></i>",
                        titleAttr: "Exportar pdf",

                    }, {
                        extend: "excel",
                        className: "btn btn-success",
                        titleAttr: "Exportar excel",
                        text: "<i style=\"font-size:14px ;\"  class=\"fa fa-file-excel-o\"> </i> ",

                    }, {

                        titleAttr: "Atualizar",
                        className: "btn btn-success",
                        text: "<i style=\"font-size:14px ;\" class=\"fa fa-refresh\"> </i>  Atualizar",
                        style: "font-weight: 600 !important;margin-left: 15px",
                        type: "POST",
                        action: function(e, dt, node, config, pdata) {
                            oclass.listarInutilizacoes();
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


                        "title": "<input id=\"boxsel\" type=\"checkbox\"></input>",
                        "name": "boxsel"
                    },

                    {
                        "sTitle": "Cnpj",
                        "sClass": "calingleft"
                    },
                    {
                        "sTitle": "Numero Inicial",
                        "sClass": "calingleft",
                        render: function(data, type, row) {
                            return padleft(row[2], 6);
                        }
                    },
                    {
                        "sTitle": "Numero Final",
                        "sClass": "calingleft",
                        render: function(data, type, row) {
                            return padleft(row[2], 6);
                        }
                    },
                    {
                        "sTitle": "Serie",
                        render: function(data, type, row) {
                            return padleft(row[3], 3)
                        }
                    },
                    {
                        "sTitle": "Modelo"
                    },
                    {
                        "sTitle": "Ano"
                    },
                    {
                        "sTitle": "Justificativa"
                    },
                    {
                        "sTitle": "Status"
                    },
                    {
                        "sTitle": "Motivo"
                    },
                    {
                        "sTitle": "Protocolo"
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

            $("#data-table-inutilizacoes thead").on("click", "#boxsel", function() {

                if ($("#boxsel").hasClass("selected")) {
                    objTabela.rows().deselect();
                    $("#boxsel").removeClass("selected");
                } else {
                    objTabela.rows({
                        filter: "applied"
                    }).select();
                    $("#boxsel").addClass("selected");
                }
            });

            $("#data-table-inutilizacoes tbody").on("dblclick", "td", function() {
                indiceColuna = $(this).index();
            });
            $("#data-table-inutilizacoes tbody").on("click", "td", function() {
                indiceColuna = $(this).index();
            });
            $("#data-table-inutilizacoes tbody").on("click", "tr", function() {
                var rowData = objTabela.row($(this)).data();
                var ttipo = "clk";
                var col = indiceColuna
                var id = objTabela.row($(this)).data()[0];

            });

        }
    }
};
//-----------------------------------------------------------------------------
delete(oclass);
var oclass = new inutilizacaoView;
var versionFile = "21.06.10.1000";
//-------------------------------------------------------------------------------
inutilizacaoviewMain = function() {
    "use strict";
    clearTimeout(vupdatepanel);
    return {
        init: function() {

            $('#small-version').text("version " + versionFile);
            oclass.configDataTable();
            $(document).ready(function() {
                $("#data-table-inutilizacoes_wrapper").css("padding", "15px");
                setTimeout(oclass.listarInutilizacoes(), 1000);



            });
        }
    };
}();