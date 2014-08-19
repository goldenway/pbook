# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
    # =========================================================================
    # 2.Traders table

    traders_table = $("#traders_table").dataTable
        sDom: "<\"H\"fT> t <\"F\"ilp>"
        bStateSave: true
        sPaginationType: "full_numbers"
        bJQueryUI: true
        oLanguage:
            sSearch: "Управляющий / счет: _INPUT_"
            sInfo: "_START_ - _END_ из _TOTAL_ управляющих"
            sInfoEmpty: "0 - 0 из 0 управляющих"
            sInfoFiltered: " (всего _MAX_)"
            sZeroRecords: "Нет данных для отображения"
            sLengthMenu: "<select>"+
                "<option value=\"10\">10</option>"+
                "<option value=\"20\">20</option>"+
                "<option value=\"50\">50</option>"+
                "</select>"
        oTableTools:
            sSwfPath: "http://localhost:3000/copy_csv_xls_pdf.swf"
            aButtons: [
                {
                    sExtends: "text"
                    sButtonText: "Добавить в портфель"
                    fnClick: (nButton, oConfig, oFlash) ->
                        tableTools = TableTools.fnGetInstance("traders_table")
                        selected_row_data = tableTools.fnGetSelectedData()
                        alert "Добавить в портфель\n" + selected_row_data
                        return
                }
            ]
            sRowSelect : "single"
            fnRowSelected: (nodes) ->
                # TODO: activate Add button
                return

            fnRowDeselected: (nodes) ->
                # TODO: deactivate Add button
                return

    $.fn.dataTableExt.afnFiltering.push (oSettings, aData, iDataIndex) ->
        return true unless oSettings.nTable is document.getElementById("traders_table")

        checked_fx = $("#fx_checkbox").is(":checked")
        checked_panteon = $("#panteon_checkbox").is(":checked")
        # TODO: handle indexes

        return true if (checked_fx and aData[0] is "FX") or 
                       (checked_panteon and aData[0] is "Panteon")
        false

    $("#fx_checkbox").on "click", (e) ->
        traders_table.fnDraw()
        return

    $("#panteon_checkbox").on "click", (e) ->
        traders_table.fnDraw()
        return

    $("#indexes_checkbox").on "click", (e) ->
        traders_table.fnDraw()
        return

    # ==================================
    # other elements

    # add to portfolio - modal methods
    $("#add_to_portfolio_btn").on "click", (e) ->
        tableTools = TableTools.fnGetInstance("traders_table")
        selected_row_data = tableTools.fnGetSelectedData()
        if selected_row_data
            $("#adding_trader").html(selected_row_data[0][3])
            $("#portfolio_select_modal").modal()
        return

    $("#portfolio_select_ok_modal_btn").on "click", (e) ->
        tableTools = TableTools.fnGetInstance("traders_table")
        selected_row_data = tableTools.fnGetSelectedData()

        checked_values = $("input[name=portfolio_checkbox]:checked").map(->
            $(this).val()
        ).get()

        $.ajax(
            type: "GET"
            url: "/traders/add_to_portfolio"
            dataType: "script"
            data:
                trader_account: selected_row_data[0][3]
                portfolio_names: checked_values
        ).done(->
            return
        ).fail(->
            alert "fail"
            return
        )

        $("#portfolio_select_modal").modal "hide"
        return

    $("#portfolio_select_cancel_modal_btn").on "click", (e) ->
        $("#portfolio_select_modal").modal "hide"
        return

    # uncheck all checkboxes before modal will appear
    $("#portfolio_select_modal").on "show.bs.modal", (e) ->
        $("input[name=portfolio_checkbox]").prop "checked", false
        return






    # ==================================
    # TEST AJAX:
    $("#test_ajax").on "click", (e) ->
        $.ajax(
            type: "GET"
            url: "/traders/test_ajax"
        ).done(->
            # alert "success"
            return
        ).fail(->
            alert "fail"
            return
        )
        return

    $("#test_get").on "click", (e) ->
        $.ajax(
            type: "GET"
            url: "/traders/test_get"
        ).done(->
            # alert "success"
            return
        ).fail(->
            alert "fail"
            return
        )
        return

    $("#test_post").on "click", (e) ->
        $.ajax(
            type: "POST"
            url: "/traders/test_post"
        ).done(->
            # alert "success"
            return
        ).fail(->
            alert "fail"
            return
        )
        return

    return


