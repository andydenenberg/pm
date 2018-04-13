//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/



function RefreshPrices() {
	document.getElementById("last_update").innerHTML = "Refreshing Prices" ; 

	$(".refresh_button").toggleClass("d-none"); 
	$(".refresh_spinner").toggleClass("d-none"); 

	
	$.get("portfolios.js" );
};
