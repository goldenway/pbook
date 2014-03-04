# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# sDom syntax:
# l - Show 10 entries
# f - search
# r - processing
# t - table
# i - Showing 1 to 10 of 25 entries
# p - pagination
# C - ColVis
# T - TableTools
# < > - div element
# <"some_class"> - div with a class


$(document).ready ->
    $.fn.editable.defaults.mode = "inline"

    $("#portfolio_week_table .start_value_column").editable
        title: "Start value"
        mode = "inline"

    $("#portfolio_week_table .end_value_column").editable
        title: "End value"

    # =========================================================================
    # 1.Portfolio week table

    portfolio_week_table = $("#portfolio_week_table").dataTable(
        sDom: "<\"H\"T<\"#portfolio_week_table_title\">C> t
            <\"F\"i<\"#portfolio_week_table_pay_all_button\">>"
        bStateSave: true
        sScrollY: "540px"               # 20,5 rows
        bScrollCollapse: true
        bPaginate: false
        bJQueryUI: true
        aaSorting: [[4, "asc"]]
        oLanguage:
            sInfo: "Всего _TOTAL_ управляющих"

        aoColumns: [
            null
            null
            { asSorting: ["asc"] }
            { asSorting: ["asc"] }
            { asSorting: ["asc"] }
            { asSorting: ["desc", "asc"] }
            null
            { asSorting: ["desc", "asc"] }
            { asSorting: ["desc"] }
            null
            { asSorting: ["desc"] }
            { asSorting: ["desc", "asc"] }
            { asSorting: ["desc", "asc"] }
            { asSorting: ["desc", "asc"] }
            { asSorting: ["desc", "asc"] }
        ]

        aoColumnDefs: [
            {
                aTargets: [0]
                bSortable: false
            }
            {
                aTargets: [1,2,6,7,8,9]
                sClass: "center"
            }
            {
                aTargets: [15]
                sClass: "center pay_column_bg"
            }
            {
                aTargets: [1]
                mRender: (data, type, row) ->
                    "# " + data
            }
            {
                aTargets: [0,1,2,3,4,5,6,7,8,9,10]
                sWidth: "100px"                             #not work
            }
        ]
        oColVis:
            buttonText: "Колонки"
            sAlign: "right"
            aiExclude: [0,1,2,3,4,11,12,13,14,15]
            fnLabel: (index, title, th) ->
                (index + 1) + ". " + title

        oTableTools:
            sSwfPath: "http://localhost:3000/copy_csv_xls_pdf.swf"
            sRowSelect: "single"
            aButtons: [
                {
                    sExtends: "text"
                    sButtonText: "Add"
                    fnClick: (nButton, oConfig, oFlash) ->
                        alert "Add"
                        return
                }
                {
                    sExtends: "text"
                    sButtonText: "Edit"
                    fnClick: (nButton, oConfig, oFlash) ->
                        alert "Edit"
                        return
                }
                {
                    sExtends: "text"
                    sButtonText: "Remove"
                    fnClick: (nButton, oConfig, oFlash) ->
                        alert "Remove"
                        return
                }
                {
                    sExtends: "xls"
                    mColumns: "visible"
                    sFileName: "My_week.xls"
                }
                {
                    sExtends: "pdf"
                    mColumns: "visible"
                    sPdfOrientation: "landscape"
                    sFileName: "My_week.pdf"
                    sTitle: "PBook"
                    sPdfMessage: "Week #27"
                }
                {
                    sExtends: "collection"
                    sButtonText: "Еще..."
                    aButtons: [
                        {
                            sExtends: "copy"
                            mColumns: "visible"
                        }
                        {
                            sExtends: "print"
                            mColumns: "visible"
                            sInfo: "Some text in modal view (PBook)"
                            sMessage: "Some message above the table (PBook)"
                        }
                        {
                            sExtends: "text"
                            sButtonText: "Открыть в новой вкладке"
                            fnClick: (nButton, oConfig, oFlash) ->
                                alert "Open in new tab"
                                return
                        }
                        {
                            sExtends: "text"
                            sButtonText: "JPEG / PNG (в отдельной программе)"
                            sToolTip: "Программа для сохранения скриншотов FastStone Capture"
                            fnClick: (nButton, oConfig, oFlash) ->
                                alert "Save JPEG / PNG"
                                return
                        }
                    ]
                }
                "select_single"
                "ajax"
            ]

        fnFooterCallback: (nFoot, aData, iStart, iEnd, aiDisplay) ->
            nFoot.getElementsByTagName('th')[9].innerHTML = "Всего:"
            nFoot.getElementsByTagName('th')[10].innerHTML = "100%"

            sumStart = 0
            sumEnd = 0
            sumProfit = 0
            i = 0

            while i < aData.length
                sumStart += aData[i][11]*1
                sumEnd += aData[i][12]*1
                sumProfit += aData[i][13]*1
                i++

            nFoot.getElementsByTagName('th')[11].innerHTML = sumStart.toFixed(2)       # parseInt(sumStart * 100) / 100
            nFoot.getElementsByTagName('th')[12].innerHTML = sumEnd.toFixed(2)
            nFoot.getElementsByTagName('th')[13].innerHTML = sumProfit.toFixed(2)
            nFoot.getElementsByTagName('th')[14].innerHTML = ((sumProfit / sumStart) * 100).toFixed(2)
            return

        # first column - counter
        fnDrawCallback: (oSettings) ->
            #alert "DataTables has redrawn the table"

            that = this

            # need to redo the counters if filtered or sorted
            if oSettings.bSorted or oSettings.bFiltered
                @$("td:first-child",
                    filter: "applied"
                ).each (i) ->
                    that.fnUpdate i+1, @parentNode, 0, false, false
                    return
            return

        fnRowCallback: (nRow, aData, iDisplayIndex) ->
            if aData[14] < 0
                $("td:eq(13)", nRow).css "background-color", "#ebb"
                $("td:eq(14)", nRow).css "background-color", "#ebb"
            else
                $("td:eq(13)", nRow).css "background-color", "#ffa"
                $("td:eq(14)", nRow).css "background-color", "#ffa"
            return

        fnCreatedRow: (nRow, aData, iDataIndex) ->
            #alert "New row created"
    )
    
    # custom elements for table
    $("#portfolio_week_table_title").html("Неделя 01.02.2014")
    $("#portfolio_week_table_pay_all_button").html("<button class=\"btn btn-success\"
        onClick=\"window.open()\">Пополнить ВСЕ</button>")

    # select row with timeout
    setTimeout ( ->
        tableTools = TableTools.fnGetInstance("portfolio_week_table")
        #tableTools.fnSelect($("#portfolio_week_table tbody tr")[0])
    ), 1000

    # handle click on favorite column
    $("#portfolio_week_table .fav_column").live "click", ->
        tableTools = TableTools.fnGetInstance("portfolio_week_table")
        tableTools.fnSelectNone()
        alert "favorite - " + this.id
        return

    # handle click on trader name column
    $("#portfolio_week_table .trader_column").live "click", ->
        tableTools = TableTools.fnGetInstance("portfolio_week_table")
        tableTools.fnSelectNone()
        return

    # handle click on pay column
    $("#portfolio_week_table .pay_column").live("click", ->
        tableTools = TableTools.fnGetInstance("portfolio_week_table")
        tableTools.fnSelectNone()
        alert "pay - " + this.id
        return
    )

    # show tooltip when hover over trader name
    $( ->
        portfolio_week_table.$("td").tooltip
            delay:
                show: 500
                hide: 100

            track: true
            fade: 250
        return
    )

    # add row button handler
    $("#add_row_button").click( ->
        return if false         # if button is inactive

        portfolio_week_table.fnAddData [
            "1", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2"
        ]
        # TODO: add events to columns fav, управ, pay (or maybe reload table)
        return
    )

    # remove row button handler
    selectedRowIndex = null
    portfolio_week_table.$("tr").click( ->
        selectedRowIndex = $(this).index()
        return
    )

    $("#remove_row_button").click( ->
        tableTools = TableTools.fnGetInstance("portfolio_week_table")
        selectedRows = tableTools.fnGetSelected()
        // #alert(selectedRows[0])
        
        return unless selectedRows.length         # if no row is selected

        portfolio_week_table.fnDeleteRow(selectedRows[0])

        // #alert(selectedRowIndex)
        // #$("tr").eq(selectedRowIndex).remove()
        return
    )

    # search in trader column only
    $("#trader_input").keyup( ->
        portfolio_week_table.fnFilter(this.value, 3)
    )

    # select brocker
    $("#brocker_select").change( ->
        portfolio_week_table.fnFilter(this.value, 1)
    )

    $("#portfolio_week_table tr").click( ->
        # $(this).toggleClass("row_selected")
        # alert "Selected row - " + $(this)
    )


    # =========================================================================
    # 2.Traders table

    $("#traders_table").dataTable(
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
    )

    # =========================================================================
    # 3.Portfolios table

    $("#portfolios_table").dataTable(
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
                document.getElementById("selected_portfolio_data").innerHTML = selected_row_data
                return

            fnRowDeselected: (nodes) ->
                document.getElementById("selected_portfolio_data").innerHTML = ""
                return
    )

    # =========================================================================
    # 4.Trader select table

    $("#trader_select_table").dataTable(
        sDom: "t <iT>"
        sScrollY: "270px"
        bScrollCollapse: true
        bPaginate: false
        bJQueryUI: true
        oLanguage:
            sInfo: "_TOTAL_ управляющих"
            sInfoEmpty: "0 управляющих"
            sInfoFiltered: " (из _MAX_)"
            sZeroRecords: "Нет данных для отображения"
        oTableTools:
            sSwfPath: "http://localhost:3000/copy_csv_xls_pdf.swf"
            sRowSelect: "multi"
            aButtons: [
                {
                    sExtends: "text"
                    sButtonText: "Добавить"
                    fnClick: (nButton, oConfig, oFlash) ->
                        tableTools = TableTools.fnGetInstance("trader_select_table")
                        selected_row_data = tableTools.fnGetSelectedData()
                        alert "Добавить\n" + selected_row_data
                        return
                }
                {
                    sExtends: "text"
                    sButtonText: "Отмена"
                    fnClick: (nButton, oConfig, oFlash) ->
                        alert "Отмена"
                        return
                }
            ]
    ).columnFilter(
        aoColumns: [
            { 
                sSelector: "#brocker_filter"
                type: "select"
                values: [
                    "FX"
                    "Panteon"
                ]
            }
            {
                sSelector: "#favorite_filter"
                type: "select"
            }
            {
                sSelector: "#trader_name_filter"
                type: "text"
            }
            {
                sSelector: "#trader_account_filter"
                type: "text"
            }
        ]
    )

    return







