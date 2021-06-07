/*

Wilson santa luz 2021
*/
 var padleft = function (avalue,alen){
   
    var rvar  = avalue;

    if (rvar ==undefined){
        rvar ="0";
          
      };
    while(rvar.length <  parseInt( alen) ){
        rvar ='0'+ rvar;
     }
   
    return rvar;
 } 
 function formattedDate(odata) {
   var d = moment(odata);
   let month = String(d.getMonth() + 1);
   let day = String(d.getDate());
   const year = String(d.getFullYear());

   if (month.length < 2) month = '0' + month;
   if (day.length < 2) day = '0' + day;
 
   return `${day}/${month}/${year}`;
 }

 function isostrtodate(dateStr) {                                
    var sdate = dateStr.split("T")[0] ; 
    const [year,month,day] =sdate.split("-"); 
    var d =new Date(year, month - 1, day); 
    
     
    if (  typeof dateStr.split("T")[1] == "undefined") {
     
      return  d.getDate() +'/'+ String( parseInt(d.getMonth()) +1)  +'/'+  d.getFullYear()   
    }else
    {                           
       
        
        var vstime = dateStr.split("T")[1] ;
     
       const [hour,minuts,seconds] =vstime.split(":");      
       return  d.getDate() +'/'+ String( parseInt(d.getMonth()) +1)  +'/'+  d.getFullYear() +' '+hour +':'+ minuts;
    
    }
 }   
 
var handleDatepicker = function() {
    $('.datepicker-default').datepicker({
        todayHighlight: true
    });

   
    $('#datepicker-inline').datepicker({
        todayHighlight: true
    });
    $('.input-daterange').datepicker({
        todayHighlight: true
    });
    $('#datepicker-disabled-past').datepicker({
        todayHighlight: true
    });
    $('#datepicker-autoClose').datepicker({
        todayHighlight: true,
        autoclose: true
    });
};


var handleFormMaskedInput = function() {
    "use strict";


  $('.campodata').mask("99/99/9999");
  $('.time').mask("00:00:00");
  $('.date_time').mask("00/00/0000 00:00:00");
  $('.campocep').mask("99999-999");
  $('.campofone').mask("999-9999");
  $('.campofoneddd').mask("(99) 9999-9999?9");
  $('.mixed').mask('AAA 000-S0S');
  $('.campocpf').mask("999.999.99-99");
  $('.campocnpj').mask("99.999.999/9999-99");
  $('.campomoney').mask("999.999.999.999.999,99");


};

jQuery( function($){
    $(".campofonedd").mask("(99) 9999-9999?9");
    $(".campofonedd").blur(function(event) {
        if($(this).val().length == 15){
          $('.campofonedd').mask("(99) 99999-999?9");
        } else {
          $('.campofonedd').mask("(99) 9999-9999?9");
        }
    });
});

$(document).ready(function(){
   
  });


var handleJqueryAutocomplete = function() {
    var availableTags = [
        'ActionScript',
        'AppleScript',
        'Asp',
        'BASIC',
        'C',
        'C++',
        'Clojure',
        'COBOL',
        'ColdFusion',
        'Erlang',
        'Fortran',
        'Groovy',
        'Haskell',
        'Java',
        'JavaScript',
        'Lisp',
        'Perl',
        'PHP',
        'Python',
        'Ruby',
        'Scala',
        'Scheme'
    ];
    $('#jquery-autocomplete').autocomplete({
        source: availableTags
    });
};

var handleTagsInput = function() {
    $('.bootstrap-tagsinput input').focus(function() {
        $(this).closest('.bootstrap-tagsinput').addClass('bootstrap-tagsinput-focus');
    });
    $('.bootstrap-tagsinput input').focusout(function() {
        $(this).closest('.bootstrap-tagsinput').removeClass('bootstrap-tagsinput-focus');
    });
};

var  dataAmericana = function(idata) {
  var data  = idata.split("T")[0];
  return data
};

var handleSelect2 = function() {
    $(".default-select2").select2();
    $(".multiple-select2").select2({ placeholder: "Select a state" });
};


var   prepareForm = function() {
	"use strict";
    return {
        //main function
        init: function () {
			
			handleFormMaskedInput();			
			handleJqueryAutocomplete();			
			handleTagsInput();
		;			
		
        }
    };
}();