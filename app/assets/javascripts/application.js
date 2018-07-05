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

//= require chartkick

//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .

$(document).ready(function() {
  feather.replace() ;	
 });


function RefreshPrices(stock_option) {
	$(".refresh_button").toggleClass("d-none"); 
	$(".refresh_spinner").toggleClass("d-none"); 	
	$.get("portfolios.js", { stock_option: stock_option } );
};

function RefreshSet() {
//	$(".refresh_button").toggleClass("d-none"); 
//	$(".refresh_spinner").toggleClass("d-none"); 	
	$.get("poll_set.js");
};

function ToggleActivePoll(stock_option) {
if (poll) { 
	poll = false ;
	$("#poll_active_button").removeClass("btn-success");  
	$("#poll_active_button").addClass("btn-danger");
	$('#poll_active_dot').find("path, polygon, circle").attr("fill", "red");
	} else { 
	poll = true
	$("#poll_active_button").removeClass("btn-danger");  
	$("#poll_active_button").addClass("btn-success");  			
	$('#poll_active_dot').find("path, polygon, circle").attr("fill", "green");
	};
};
