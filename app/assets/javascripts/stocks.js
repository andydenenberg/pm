// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

function SelectPortfolio(portfolio) {
	$.get("/stocks.js", { portfolio_name: portfolio });
};

function SelectDividendPortfolio(portfolio) {
	$.get("/dividends.js", { portfolio_name: portfolio });
};
