
  _HOST ='http://localhost:4475';

var _CT_SERVER_NFE         =  _HOST + '/dfeapi/nfe';
var _CT_SERVER_NFE_INFO    =  _HOST +'/dfeapi/nfe/info';
var _CT_SERVER_NFE_EMPRESA  =  _HOST + '/dfeapi/nfe/empresa';
var _CT_SERVER_NFSE_WEBSOCK = 'http://localhost:30086';

var _socksclient;
var wsLastMsg = "INITIALIZING";
//var event = new Event('OnWsreceiptInfo');
//var event = document.createEvent('OnWsreceiptInfo');
//var event = new CustomEvent('OnWsreceiptInfo', { 'INFOJASON':"{}" });



function basicRequest(type, adress, params, fcalback) {
    var xhr = new XMLHttpRequest(); //xhr
    xhr.async =true;
    xhr.onreadystatechange = function () {
        if (this.readyState == 4) {
            oresponse = "";
            if (this.status == 200) {
                oresponse = this.responseText;

            } else {
                var sstatus = this.status + ' - ' + this.responseText;
                switch (this.status) {
                    case 0:
                        sstatus = "Erro na conexão - Servidor offline ou erro de rede.";
                        break;
                    case 404:
                        sstatus = "404 - A URL informada não e válida ou servidor fora do ar";
                        break;
                    case 401:
                        sstatus = "401 - Acesso negado";
                        break;
                    case 500:
                        sstatus = "500 - Erro " + this.responseText;
                        break;
                    case 599:
                        sstatus = "599 -" + msgServer;
                        break;
                }
                doalert('error', 'Erro de acesso', sstatus);
            }
            fcalback(this.responseText);
        }
    };
    xhr.open(type, adress, true);
    xhr.setRequestHeader("Set-Cookie", "session=abc");
    xhr.setRequestHeader('Content-Type', 'application/json');
    if (params !== "") {
        xhr.send(params);
    } else {
        xhr.send();
    }
};

function doalert(atype, atitle, amsg) {
    $('#loading-indicator').hide();
    swal({
        type: atype,
        title: atitle,
        text: amsg
    });
};

function IsJsonString(str) {
    try {
        JSON.parse(str);
    } catch (e) {
        return false;
    }
    return true;
}


function processSokstMsg(areceived_msg) {
    if (IsJsonString(areceived_msg)) {
        var ojson = JSON.parse(areceived_msg);
        if (ojson.msgtype !== undefined) {
            if (ojson.msgtype == 'INFO') {
                setTimeout(function () {
                    $.gritter.add({
                        title: 'Mensage recebida do servidor!',
                        text: ojson.msgcontent,
                        image: 'ico/knob/info.png',
                        sticky: true,
                        time: '1500',
                        class_name: 'my-sticky-class'
                    });

                }, 1000);
            };
            if (ojson.msgtype == 'SUCESS') {
                setTimeout(function () {
                    $.gritter.add({
                        title: 'Mensage recebida do servidor!',
                        text: ojson.msgcontent,
                        image: 'ico/knob/sucess.png',
                        sticky: true,
                        time: '1500',
                        class_name: 'my-sticky-class'
                    });

                }, 1000);
            };
            if (ojson.msgtype == 'ERROR') {
                setTimeout(function () {
                    $.gritter.add({
                        title: 'Mensage recebida do servidor!',
                        text: ojson.msgcontent,
                        image: 'ico/knob/error.png',
                        sticky: true,
                        time: '1500',
                        class_name: 'my-sticky-class'
                    });

                }, 1000);

            }

            if (ojson.msgtype == 'UPDATEINFONFSE') {
                

            }  
        }
    }


}

function processSoksclose(areceived_msg) {
    setTimeout(function () {
        $.gritter.add({
            title: 'Conexão com o servidor perdida!',
            text: 'Conexão websockt fechada .',
            image: 'ico/knob/alert.gif',
            sticky: false,
            time: 10000,
            class_name: 'my-sticky-class'
        });
    }, 1000);


}

function WebSocketInitialize() {

    if ("WebSocket" in window) {
        if (_socksclient !== undefined) {
            _socksclient = new WebSocket("ws://" + _CT_SERVER_NFSE_WEBSOCK);

            _socksclient.onopen = function () {
                if (wsLastMsg !== "")
                    _socksclient.send(wsLastMsg);
                wsLastMsg = "";
            };

            _socksclient.onmessage = function (evt) {
                var received_msg = evt.data;
                processSokstMsg(received_msg);
            };

            _socksclient.onclose = function () {

                processSoksclose(close)
            };
        }
    } else {


        alert("WebSocket não esta implentado neste browser!");
    }
}

function SendWsMessage(omsg) {
    if (_socksclient !== undefined) {

        if (_socksclient.readyState == 1) {
            _socksclient.send(omsg);

        } else {
            wsLastMsg = omsg
            WebSocketInitialize();
        }
    } else {
        wsLastMsg = omsg
        WebSocketInitialize();


    }

}

var appCache = window.applicationCache;
var forceupd = function () {
    try {
        appCache.update();
    } catch (err){

    }

    if (appCache.status == window.applicationCache.UPDATEREADY) {
        appCache.swapCache();
    }
}

SendWsMessage('INICIANDO')