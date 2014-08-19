# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$(document).ready ->
    $("#portfolios_table").dataTable
        sDom: "<\"H\"Tf> t <\"F\"ilp>"
        bStateSave: true
        sPaginationType: "full_numbers"
        bJQueryUI: true
        oLanguage:
            sSearch: "Портфель / инвестор: _INPUT_"
            sInfo: "_START_ - _END_ из _TOTAL_ портфелей"
            sInfoEmpty: "0 - 0 из 0 портфелей"
            sInfoFiltered: " (всего _MAX_)"
            sZeroRecords: "Нет данных для отображения"
            sLengthMenu:
                "<select>"+
                "<option value=\"10\">10</option>"+
                "<option value=\"20\">20</option>"+
                "<option value=\"50\">50</option>"+
                "</select>"
        oTableTools:
            aButtons: []
            sRowSelect: "single"
            fnRowSelected: (nodes) ->
                tableTools = TableTools.fnGetInstance("portfolios_table")
                selected_row_data = tableTools.fnGetSelectedData()

                if selected_row_data
                	$.ajax(
                		type: "GET"
                		url: "/portfolios/show_portfolio_data"
                		dataType: "script"
                		data:
                			portfolio_name: selected_row_data[0][1]
                	).done(->
                		return
                	).fail(->
                		alert "fail"
                		return
                	)
                return

            fnRowDeselected: (nodes) ->
            	$.ajax(
            		type: "GET"
            		url: "/portfolios/hide_portfolio_data"
            		dataType: "script"
            	).done(->
            		return
            	).fail(->
            		alert "fail"
            		return
            	)
            	return

    $("#portfolio_data_block").css "display", "none"

    return

