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
	document.getElementById("time").innerHTML = minutes % 10 ;
//    document.getElementById("time").innerHTML = d.toLocaleTimeString();
};

function RefreshPrices(stock_option) {
	
	document.getElementById("last_update").innerHTML = "Refreshing " + stock_option + " Prices" ; 

	$(".refresh_button").toggleClass("d-none"); 
	$(".refresh_spinner").toggleClass("d-none"); 

	
	$.get("portfolios.js", { stock_option: stock_option } );
};
