function cancelamentoClass(params) {
    this.listar = function(oretlistar, astatus) {
        var fcalback = function(oresponse) {
            if (oresponse !== "") {
                jsonConsulta = null;
                if (IsJsonString(oresponse)) {
                    jsonConsulta = JSON.parse(oresponse);

                    oretlistar(jsonConsulta);

                } else {
                    doalert('error', 'Erro inteno', oresponse);

                }
            }
        }
        if (typeof params === 'undefined' || params == '') {
            params = "{}";
        };
        basicRequest("GET", _CT_SERVER_CANC + '?' + params, params, fcalback);

    };

}