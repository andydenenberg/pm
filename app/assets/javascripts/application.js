// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .

$(document).ready(function() {
  feather.replace() ;	
 });

var myVar = setInterval(myTimer, 1000);
var poll = true ;

function myTimer() {
    var d = new Date();
	var minutes = d.getMinutes();
	document.getElementById("time").innerHTML = 10 - (minutes % 10) ;
//    document.getElementById("time").innerHTML = d.toLocaleTimeString();
if (poll) {
	$.getJSON( "poll_check.js", function( data ) {

	if (data['poll_request'] == 'Updating') {
		$("#poll_request_button").removeClass("btn-warning");  
		$("#poll_request_button").addClass("btn-primary");  		
	} else if ( data['poll_request'] == 'Waiting' ) {
		$("#poll_request_button").removeClass("btn-secondary");  
		$("#poll_request_button").addClass("btn-warning");  		
	} else if ( data['poll_request'] == 'Complete' ) {
		$("#poll_request_button").removeClass("btn-primary");  
		$("#poll_request_button").addClass("btn-success");  		
	}

	document.getElementById("poll_request_time").innerHTML = data['poll_request_time'] ; 
	document.getElementById("poll_request").innerHTML = data['poll_request'] ; 

	});	
}
	
};

function RefreshPrices(stock_option) {
	$(".refresh_button").toggleClass("d-none"); 
	$(".refresh_spinner").toggleClass("d-none"); 	
	$.get("portfolios.js", { stock_option: stock_option } );
};

function ToggleActivePoll(stock_option) {
if (poll) { 
	poll = false ;
	$("#poll_active_button").removeClass("btn-success");  
	$("#poll_active_button").addClass("btn-danger");  			
	} else { 
	poll = true
	$("#poll_active_button").removeClass("btn-danger");  
	$("#poll_active_button").addClass("btn-success");  			
	};
};
