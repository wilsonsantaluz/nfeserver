/*----------------------------------------------------------------------------------------------
                                         linx 2021
                                      wilson santa luz
----------------------------------------------------------------------------------------------
*/

var objtblEmitidos;
var indcol = 0;
var otimer;

var FNFe = new TNFe_class(0);
var versionFile ="21.06.10.1000";

function popularModal() {
  
  handleFormMaskedInput();   
  handleDatepicker();
}

/*----------------------------------------------------------------------------------------------
                                        FUNCÕES DE ACESSO AO SERVIDOR
------------------------------------------------------------------------------------------------
*/

  glbidNFe =ichave;
function listarInutilizacoes() {
  function oretlistar(jsonConsulta) {
    array_notas = [];

    for (var i = 0; i < jsonConsulta.listHelper.length; i++) {
      var notas = [
        '',        
        jsonConsulta.listHelper[i].cnpj,
        jsonConsulta.listHelper[i].numero,
        jsonConsulta.listHelper[i].serie,
        jsonConsulta.listHelper[i].justificativa,       
        jsonConsulta.listHelper[i].status,
        jsonConsulta.listHelper[i].motivo,
        jsonConsulta.listHelper[i].protocolo
      ];
      array_notas.push(notas);
    }


    objtblEmitidos.clear();
    objtblEmitidos.rows.add(array_notas);
    objtblEmitidos.draw();
    $('#loading-indicator').hide();


  };

  var ostatus = 1;
  objtblEmitidos.clear();
  var prep_arrray = [];
  objtblEmitidos.rows.add(prep_arrray);
  objtblEmitidos.draw();
  $('#loading-indicator').show(); 
  FNFe.listarInutilizacoes(oretlistar, ostatus);
};


/*----------------------------------------------------------------------------------------------
                            PREPARAR O DATATABLE
------------------------------------------------------------------------------------------------
*/
var configDataTable = function () {
  "use strict";

  if ($('#data-table-inutilizacoes').length !== 0) {
    objtblEmitidos = $('#data-table-inutilizacoes').DataTable({

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

        }, {

          titleAttr: "Atualizar",
          className: "btn btn-success",
          text: "<i style=\"font-size:14px ;\" class=\"fa fa-refresh\"> </i>  Atualizar",
          style: "font-weight: 600 !important;margin-left: 15px",
          type: "POST",
          action: function (e, dt, node, config, pdata) {
            listarInutilizacoes()
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
          "sTitle": "Numero",
          "sClass": "calingleft",
          render: function (data, type, row) {
            return padleft(row[2], 6)
          }
        },
        {
          "sTitle": "Serie",
           render: function (data, type, row) {
            return padleft(row[3], 3)
          }
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
      

      "columnDefs": [

        {
          "data": null,
          orderable: false,
          "targets": 0,
          "defaultContent": "<div class= \"dropdown autodropdon\"  style=\"font-size:18;\" > " +
            "<a href=\"javascript:;\" class=\"dropdown-toggle\" data-toggle=\"dropdown\"> " +
            "<img id=\"ImgUser\" src=\"ico/gear.png\" style=\"font-size:16;\" alt=\"\"></a> " +
            "<ul class=\"dropdown-menu\"  style=\"font-size:18;\" >  " +
            "<li class=\"dropdown-header bg-indigo text-white\"></li>  " +
            "<li><a href=\"#\" id=\"ieditar\"     class=\"popconsulta fa fa-eye\">  Visualizar NFe</a></li>  " +
            "<li><a href=\"#\" id=\"iimprimir\"   class=\"popconsulta fa fa-print \">  Imprimir NFe</a></li> " +
            "<li><a href=\"#\" id=\"icancelar\"   class=\"popconsulta fa fa-times\">  Cancelar NFe</a></li> " +
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
      processing:true
    });

    $("#data-table-inutilizacoes thead").on("click", "#boxsel", function () {

      if ($("#boxsel").hasClass("selected")) {
        objtblEmitidos.rows().deselect();
        $("#boxsel").removeClass("selected");
      } else {
        objtblEmitidos.rows({
          filter: "applied"
        }).select();
        $("#boxsel").addClass("selected");
      }
    });

    $("#data-table-inutilizacoes tbody").on("dblclick", "td", function () {
      indcol = $(this).index();
    });
    $("#data-table-inutilizacoes tbody").on("click", "td", function () {
      indcol = $(this).index();
    });
    $("#data-table-inutilizacoes tbody").on("click", "tr", function () {
      var rowData = objtblEmitidos.row($(this)).data();
      var ttipo = "clk";
      var col = indcol
      var id = objtblEmitidos.row($(this)).data()[0];

    });

  }
  $("#data-table-inutilizacoes_wrapper").css("padding", "15px");
};

var consultarNFe = function () {
	  
 alert  ("Usuario não definido para consulta"); 
};	

inutilizacaoviewMain = function () {
  "use strict";
  $('#small-version').text("version "+versionFile);
  return {
    
    init: function () { 
     
      configDataTable();
      $("#data-table-inutilizacoes_wrapper").css("padding", "15px");
      $("#NFeconsultar").click(function () {
        consultarNotas();
      });
	
      $( document ).ready(function() {       
        setTimeout(listarInutilizacoes(), 1000);
      });      
    }
  };
}();

