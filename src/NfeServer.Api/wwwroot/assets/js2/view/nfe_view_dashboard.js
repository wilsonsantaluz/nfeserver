/*
Linx  2019
implementado por wilson luz -2021
*/
var vdata_vendas = [];
var vdata_hist_nfse = [];
var areachart;
var donutchart;
var vupdatepanel;
//var vdata_hist_nfse = '[{ "x": "2019-02-01", "y": 60, "z": 30 } , { "x": "2019-03-01", "y": 25, "z": 41}]';

var
    blue = '#348fe2',
    blueLight = '#5da5e8',
    blueDark = '#1993E4',
    aqua = '#49b6d6',
    aquaLight = '#6dc5de',
    aquaDark = '#3a92ab',
    green = '#00acac',
    greenLight = '#33bdbd',
    greenDark = '#008a8a',
    orange = '#f59c1a',
    orangeLight = '#f7b048',
    orangeDark = '#c47d15',
    dark = '#2d353c',
    grey = '#b6c2c9',
    purple = '#727cb6',
    purpleLight = '#8e96c5',
    purpleDark = '#5b6392',
    red = '#ff5b57';

var getMonthName = function (number) {
    var month = [];
    month[0] = "Janeiro";
    month[1] = "Fevereiro";
    month[2] = "Março";
    month[3] = "Abril";
    month[4] = "Maio";
    month[5] = "Junho";
    month[6] = "Julho";
    month[7] = "Agosto";
    month[8] = "Setembro";
    month[9] = "Outubro";
    month[10] = "Novembro";
    month[11] = "Dezembro";
    return month[number];
};

var getDate = function (date) {
    var currentDate = new Date(date);
    var dd = currentDate.getDate();
    var mm = currentDate.getMonth() + 1;
    var yyyy = currentDate.getFullYear();

    if (dd < 10) {
        dd = '0' + dd;
    }
    if (mm < 10) {
        mm = '0' + mm;
    }
    currentDate = yyyy + '-' + mm + '-' + dd;

    return currentDate;
};
var dataAmericana = function (idata) {
    var data = idata.split("T")[0];
    return data
};
//----------------------------------------------------------------------------------------------------
var handlewidgetstat = function (ojson) {


    $("#icovalidadas").text('').fadeOut(800);
    $("#icocancel").text('').fadeOut(800);
    $("#iinutilizadas").text('').fadeOut(800);

    $("#nfe_validadas").text(ojson.notasEmitidas);
    $("#nfe_canceladas").text(ojson.notasCanceladas);
    $("#nfe_inutilizadas").text(ojson.notasInutilizadas);

    setInterval(function () {
        $("#icovalidadas").show("pulsate", 800);
    }, 1000);
    setInterval(function () {
        $("#icocancel").show("pulsate", 800);
    }, 1600);
    setInterval(function () {
        $("#icopendentes").show("pulsate", 800);
    }, 2100);


}
//----------------------------------------------------------------------------------------------------

var updatelegenda = function () {
    $('#legend').empty();
    if (vdata_vendas !== undefined) {
        donutchart.segments.forEach(function (segment) {
            try {

                var legendText = vdata_vendas[segment.index].label + " (" + vdata_vendas[segment.index].value + ")";
                var legendColor = segment.color;
                var legendItem = $('<li></li>').text(legendText).css('color', 'black');
                var legendColorDot = $('<span></span>').html("&#9632; ").addClass('colorDot').css('color', legendColor).css('font-size', '20px');
                $(legendItem).prepend(legendColorDot)
                $('#legend').append(legendItem);
            }
            catch (err) {

            }
        }

        );
    }
}

var updateVendasItens = function (ojson) {
    var dados = '';
    var total = 0;
    for (var i = 0; i < ojson.itenvendas.length; i++) {
        total = total + ojson.itenvendas[i].QUANTIDADE;
        var linha =
            '{' +
            '"label" : "' + ojson.itenvendas[i].DS_PROD.substring(0, 15) + '" , ' +
            '"value" : ' + ojson.itenvendas[i].QUANTIDADE +
            ' }';
        if (dados == '') {
            dados = '[ ' + linha
        } else {
            dados = dados + ',' + linha;
        }
    }
    dados = dados + ' ]';
    $("#divitensemtidos").text(total);
    vdata_vendas = JSON.parse(dados);
    if (donutchart !== undefined) {
        try {
            donutchart.setData(vdata_vendas);
        } catch (err) {

            handleNfseStatus();
        }

        updatelegenda();


    } else {

        handleNfseStatus();
    }

}
//----------------------------------------------------------------------------------------------------
var updateHistoricoNfse = function (ojson) {
    var vvalidadas = 0;
    var vcanceladas = 0;
    if (ojson.analissemensal.listHelper.length > 0) {
        var dados = '[';
        for (var i = 0; i < ojson.analissemensal.listHelper.length; i++) {
            vvalidadas = 0;
            vcanceladas = 0;
            if (ojson.analissemensal.listHelper[i].tipo == 'VALIDADAS') {
                vvalidadas = ojson.analissemensal.listHelper[i].valor
            }
            if (ojson.analissemensal.listHelper[i].tipo == 'CANCELADAS') {
                vcanceladas = ojson.analissemensal.listHelper[i].valor
            };
            var linha =
                '{' +
                '"Data" : "' + dataAmericana(ojson.analissemensal.listHelper[i].data) + '" , ' +
                '"Emitidas" : ' + vvalidadas + ',' +
                '"Canceladas" : ' + vcanceladas +
                ' }';
            if (dados == '[') {
                dados = '[ ' + linha
            } else {
                dados = dados + ',' + linha;
            }
        }
        dados = dados + ' ]';
        vdata_hist_nfse = JSON.parse(dados);
        if (areachart !== undefined) {
            try {
                areachart.setData(vdata_hist_nfse);

            } catch (err) {

                handleHistoricoNfse();
            }
        } else {

            handleHistoricoNfse();
        }
    }
}

//----------------------------------------------------------------------------------------------------
var functionCalback = function (oresponse) {
    if (oresponse !== "") {

        $("#dataupdate").text('').fadeOut(1000);
        $("#dataupdate").text('  dados atualizados :' + new Date().toLocaleString());
        setInterval(function () {
            $("#dataupdate").show("drop", 2200);
        }, 1000);
        jsonConsulta = null;
        jsonConsulta = JSON.parse(oresponse);

        if (typeof jsonConsulta.notasEmitidas !== "undefined") {
            handlewidgetstat(jsonConsulta);

        }

        if (typeof jsonConsulta.analissemensal !== "undefined") {
            updateHistoricoNfse(jsonConsulta);
        }
        if (typeof jsonConsulta.itenvendas !== "undefined") {
            updateVendasItens(jsonConsulta);
        }
    }
}
//----------------------------------------------------------------------------------------------------
var updatePanel = function () {

    if (document.getElementById('dataupdate') instanceof Object) {
        $("#dataupdate").text('  Atualizando dados no servidor....');

        basicRequest("GET", _CT_SERVER_NFE_INFO, "", functionCalback);
    } else {

        clearInterval(vupdatepanel);
        vdata_vendas = undefined;
        vdata_hist_nfse = undefined;
        areachart = undefined;
        donutchart = undefined;
        vupdatepanel = undefined;
    }
};
//----------------------------------------------------------------------------------------------------
var handleHistoricoNfse = function () {
    areachart =
        Morris.Area({
            element: 'morris-area-chart',
            data: vdata_hist_nfse,
            xkey: 'Data',
            ykeys: ['Emitidas', 'Canceladas'],
            labels: ['Emitidas', 'Canceladas'],
            pointSize: 2,
            hideHover: 'auto',
            resize: true,
            lineColors: [greenDark, orange]
        });
};
var handleNfseStatus = function () {

    donutchart = Morris.Donut({
        element: 'morris-donut-chart',
        data: vdata_vendas,
        formatter: function (y) {
            return y + "%"
        },
        resize: true,
        colors: [greenDark, blue, orange, purple, red, grey]

    });
    updatelegenda();
};
var handleNotificacao = function () {
    $(window).load(function () {
        setTimeout(function () {
            $.gritter.add({
                title: 'Status da operação!',
                text: 'Informações atualizadas .',
                image: 'assets/img/user-14.jpg',
                sticky: true,
                time: '',
                class_name: 'my-sticky-class'
            });
        }, 1000);
    });
};


var DashboardV2 = function () {
    $('#small-version').text("version 21.04.17.1900");
    "use strict";
    return {
        //main function
        init: function () {
            $.getScript('assets/plugins/morris/raphael.min.js').done(function () {
                $.getScript('assets/plugins/morris/morris.js').done(function () {
                    vdata_vendas = undefined;
                    vdata_hist_nfse = undefined;
                    areachart = undefined;
                    donutchart = undefined;
                    vupdatepanel = undefined;
                    handleNfseStatus();
                    handleHistoricoNfse();
                });
            });
            $.getScript('assets/plugins/gritter/js/jquery.gritter.js').done(function () {
                handleNotificacao();
            });

            updatePanel();
            vupdatepanel = setInterval(updatePanel, 30000);
            
        }
    };
}();