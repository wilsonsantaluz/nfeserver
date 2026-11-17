cancelamentoView = function() {
    "use strict";
    var objTabela;
    var indiceColuna = 0;
    var cancClass = new cancelamentoClass;

    //-------------------------------------------------------------------------------
    this.listarcancelamentos = function() {
     
	  try {
	  function oretlistar(jsonConsulta) {
           $('#loading-indicator').hide();             
		   var array_cancelamentos = [];
            for (var i = 0; i < jsonConsulta.listHelper.length; i++) {
                var cancelamento = [
                    '',
                    jsonConsulta.listHelper[i].cnpj,
					 jsonConsulta.listHelper[i].ambiente,
                    jsonConsulta.listHelper[i].chave,
                    jsonConsulta.listHelper[i].numero,
                    jsonConsulta.listHelper[i].serie,
                    jsonConsulta.listHelper[i].data,
                    jsonConsulta.listHelper[i].protocoloNota,
                    jsonConsulta.listHelper[i].justificativa,
                    jsonConsulta.listHelper[i].cstat,
                    jsonConsulta.listHelper[i].xmotivo,
                    jsonConsulta.listHelper[i].protocoloCancelamento
                ];
                array_cancelamentos.push(cancelamento);
            }
            objTabela.clear();
            objTabela.rows.add(array_cancelamentos);
            objTabela.draw();
            $('#loading-indicator').hide();
        };
        var ostatus = 1;
        objTabela.clear();
        var prep_arrray = [];
        objTabela.rows.add(prep_arrray);
        objTabela.draw();      
        cancClass.listar(oretlistar, ostatus);
	  }
     catch(err) {
		   
		 $('#loading-indicator').hide(); 
	 } 
    };
    /*----------------------------------------------------------------------------------------------
                                      PREPARAR O DATATABLE
    ------------------------------------------------------------------------------------------------
    */
    this.configDataTable = function() {
        "use strict";
        if ($('#data-table-cancelamentos').length !== 0) {
            objTabela = $('#data-table-cancelamentos').DataTable({

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
                            oclass.listarcancelamentos();
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
                        "sTitle": "Ambiente"
                    },
					{
                        "sTitle": "Chave"
                    },
                    {
                        "sTitle": "Numero",
                        "sClass": "calingleft"
                        
                    },
					{
                        "sTitle": "Serie"
                    },
					{
                        "sTitle": "Data"
                    },
                   
                    {
                        "sTitle": "Protocolo Nota"
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
                        "sTitle": "Protocolo Canc."
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

            $("#data-table-cancelamentos thead").on("click", "#boxsel", function() {

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

            $("#data-table-cancelamentos tbody").on("dblclick", "td", function() {
                indiceColuna = $(this).index();
            });
            $("#data-table-cancelamentos tbody").on("click", "td", function() {
                indiceColuna = $(this).index();
            });
            $("#data-table-cancelamentos tbody").on("click", "tr", function() {
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
var oclass = new cancelamentoView;
var versionFile = "21.06.10.1000";
//-------------------------------------------------------------------------------
cancelamentoviewMain = function() {
    "use strict";
    clearTimeout(vupdatepanel);
    return {
        init: function() {

            $('#small-version').text("version " + versionFile);
            oclass.configDataTable();
            $(document).ready(function() {
                $("#data-table-cancelamentos_wrapper").css("padding", "15px");
                setTimeout(oclass.listarcancelamentos(), 3000);



            });
        }
    };
}();