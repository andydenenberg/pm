//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/



function RefreshPrices(stock_option) {
	
	document.getElementById("last_update").innerHTML = "Refreshing " + stock_option + " Prices" ; 

	$(".refresh_button").toggleClass("d-none"); 
	$(".refresh_spinner").toggleClass("d-none"); 

	
	$.get("portfolios.js", { stock_option: stock_option } );
};
