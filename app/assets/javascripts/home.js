// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

function ShowMarker() {
    if ($("#show_marker").prop('checked'))
    { chart.data.datasets[0].pointRadius = 3 ; } 
	else 
	{ chart.data.datasets[0].pointRadius = 0 ; }
	chart.update() ;
};

function ToolTip_Millions(value) {
	// Convert the number to a string and splite the string every 3 charaters from the end
	    //value = value.toString().slice(0,-6);
		value = value.toString().split(/(?=(?:...)*$)/);
		// Convert the array to a string and format the output
	    value = '$' + value.join(',');	    
    return value ; //+ 'M' ;
};

function yTickLabel(value, tick_label) {
	// Convert the number to a string and splite the string every 3 charaters from the end
	//    value = value.toString().slice(0,-6);
	if ( (value % tick_label) === 0 ) {
		value = value.toString().split(/(?=(?:...)*$)/);
		// Convert the array to a string and format the output
	    value = '$' + value.join(',');	    
	} else {
		value = ''
	}
    return value ; //+ 'M' ;
};

function HideChart() {
	$("#chartSpinner").removeClass("d-none"); 
	$("#chartCanvas").addClass("d-none");
};
function ShowChart() {
	$("#chartCanvas").removeClass("d-none"); 
	$("#chartSpinner").addClass("d-none");	
};


function ChangePortfolio(portfolio) {
	HideChart() ;
	var period = document.getElementById("period").innerHTML
	console.log(portfolio_name + period) ;
	$.get("home.js", { portfolio:portfolio, period:period });
};

function ChangePeriod(period) {
	HideChart() ;
	var portfolio_name = document.getElementById("portfolio_name").innerHTML
	console.log(portfolio_name + period) ;
	$.get("home.js", { portfolio:portfolio_name, period:period });
};
	

