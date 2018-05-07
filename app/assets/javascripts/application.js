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

function myTimer() {
    var d = new Date();
	var minutes = d.getMinutes();
	document.getElementById("time").innerHTML = 10 - (minutes % 10) ;
//    document.getElementById("time").innerHTML = d.toLocaleTimeString();

	$.getJSON( "poll_check.js", function( data ) {
	  var poll_state = data[1];
	  var poll_check_request = data[0];
	  console.log(data) ;
//	  console.log(poll_check_request) ;

	document.getElementById("poll_request_time").innerHTML = data['poll_request_time'] ; 
	document.getElementById("poll_request").innerHTML = data['poll_request'] ; 

			//  $.each( data, function( key, val ) {
			//    items.push( "<li id='" + key + "'>" + val + "</li>" );
			//  });
			// 
			//  $( "<ul/>", {
			//    "class": "my-new-list",
			//    html: items.join( "" )
			//  }).appendTo( "body" );
	});
	
};

function RefreshPrices(stock_option) {
	
	document.getElementById("poll_request_time").innerHTML = "Refreshing " + stock_option + " Prices" ; 

	$(".refresh_button").toggleClass("d-none"); 
	$(".refresh_spinner").toggleClass("d-none"); 

	$("#poll_request_button").removeClass("btn-secondary");  
	$("#poll_request_button").addClass("btn-warning");  
	
	$.get("portfolios.js", { stock_option: stock_option } );
};
