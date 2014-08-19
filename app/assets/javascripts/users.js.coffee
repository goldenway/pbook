# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# DataTables sDom syntax:
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

# =============================================================================
# global variables

total_cash = 0.0
total_percent = 0.0

portfolio_rating = 0.0

weeks_data = []
week_date = ""
week_start_value = 0.0
week_end_value = 0.0
week_free_cash = 0.0
portfolio_week_traders = []

# charts ---------------
current_history_chart = 0       # 0 - percent, 1 - cash, 2 - grow
history_chart_data = []         # [weeks, portfolios, percent_values, cash_values]


# =============================================================================

$(document).ready ->
    $.fn.editable.defaults.mode = "inline"
    
    set_charts_options()

    test_chart()
    test_drilldown_chart()

    # get portfolio weeks
    $.ajax(
        type: "GET"
        dataType: "json"
        url: "/users/get_init_data"
        success: (data) ->
            week_start_value = data.week_start_value

            update_weeks_chart(data.weeks)
            update_portfolio_traders_chart(data.portfolio_week_traders)
            update_all_traders_chart(data.all_week_traders)

            count_table_percents()

            process_history_chart_data(data.history_profit)
            return
    ).done(->
        return
    ).fail(->
        alert "fail get_init_data"
        return
    )


    # =========================================================================
    # Portfolios block

    # select portfolio
    $("#portfolio_select").on "change", (e) ->
        $.ajax(
            type: "GET"
            url: "/users/select_portfolio"
            dataType: "json"
            data:
                portfolio_name: $(this).val()
            success: (data) ->
                # update totals
                $("#total_cash").html(data.total_cash)
                $("#total_percent").html(" " + data.total_percent)

                # update portfolio info
                $("#portfolio_rating").html(data.portfolio_rating)
                $("#portfolio_weeks").html(data.portfolio_weeks)

                update_weeks_chart(data.weeks)

                # update week total values
                $("#week_date").val(data.week_date)
                $("#week_start_value").html(data.week_start_value)
                $("#week_end_value").html(data.week_end_value)
                $("#week_free_cash").html(data.week_free_cash)
                $("#week_comment").val(data.week_comment)
                $("#week_profit_cash").html((data.week_end_value - data.week_start_value).toFixed(2))
                $("#week_profit_percent").html(((data.week_end_value / data.week_start_value - 1) * 100).toFixed(2))
                
                update_portfolio_traders_chart(data.portfolio_week_traders)
                update_all_traders_chart(data.all_week_traders)
                return
        ).done(->
            # TODO: fix bug - reloading table with new data
            # main_table.fnDraw()
            # main_table.fnReloadAjax()
            return
        ).fail(->
            alert "fail select_portfolio"
            return
        )
        return

    # open my portfolios modal
    $("#my_portfolios_btn").on "click", (e) ->
        $("#my_portfolios_modal").modal()
        return

    # open new_portfolio form
    $("#new_portfolio_btn").on "click", (e) ->
        $(this).hide()
        $("#new_portfolio_form").show()
        return

    # create portfolio
    $("#create_portfolio_btn").on "click", (e) ->
        $("#new_portfolio_form").hide()
        $("#new_portfolio_btn").show()

        $.ajax(
            type: "GET"
            url: "/users/create_portfolio"
            dataType: "json"
            data:
                portfolio_name: $("#new_portfolio_input").val()
            success: (data) ->
                # add portfolio into modal
                $("#my_portfolios_modal .modal-body").append("<div id='portfolio_" + data.portfolio_name + "'><span style='float:left; width:250px'>" + data.portfolio_name + "</span><button type='button' class='remove_portfolio_btn btn btn-danger btn-xs' value='" + data.portfolio_name + "'>Удалить</button><hr/></div>")
                $("#my_portfolios_modal").modal("hide")

                # add portfolio into portfolios select
                $("#portfolio_select").append("<option value='" + data.portfolio_name + "'>" + data.portfolio_name + "</option>")
                $("#portfolio_select option[value='" + data.portfolio_name + "']").prop("selected", true)

                # update totals
                $("#total_cash").html("")
                $("#total_percent").html("")

                # update portfolio info
                $("#portfolio_rating").html("0.00")
                $("#portfolio_weeks").html("0")

                update_weeks_chart([])

                # update week total values
                $("#week_date").val("")
                $("#week_start_value").html("")
                $("#week_end_value").html("")
                $("#week_free_cash").html("")
                $("#week_comment").val("")
                $("#week_profit_cash").html("")
                $("#week_profit_percent").html("")

                update_portfolio_traders_chart([])
                update_all_traders_chart([])
                return
        ).done(->
            return
        ).fail(->
            alert "fail create_portfolio"
            return
        )
        $("#new_portfolio_input").val("")
        return

    removed_portfolio_name = ""

    # remove_portfolio button handler
    $(".remove_portfolio_btn").live "click", (e) ->
        removed_portfolio_name = $(this).val()
        $("#remove_portfolio_modal").modal()
        return

    $("#remove_portfolio_ok_modal_btn").on "click", (e) ->
        $.ajax(
            type: "GET"
            url: "/users/remove_portfolio"
            dataType: "json"
            data:
                portfolio_name: removed_portfolio_name
            success: (data) ->
                # remove portfolio from modal
                $("#my_portfolios_modal .modal-body #portfolio_" + data.portfolio_name).remove();
                $("#my_portfolios_modal").modal("hide")

                # remove portfolio from portfolios select
                $("#portfolio_select option[value='" + data.portfolio_name + "']").remove();

                # update totals
                $("#total_cash").html(data.total_cash)
                $("#total_percent").html(" " + data.total_percent)

                # update portfolio info
                $("#portfolio_rating").html(data.portfolio_rating)
                $("#portfolio_weeks").html(data.portfolio_weeks)

                update_weeks_chart(data.weeks)

                # update week total values
                $("#week_date").val(data.week_date)
                $("#week_start_value").html(data.week_start_value)
                $("#week_end_value").html(data.week_end_value)
                $("#week_free_cash").html(data.week_free_cash)
                $("#week_comment").val(data.week_comment)
                $("#week_profit_cash").html((data.week_end_value - data.week_start_value).toFixed(2))
                $("#week_profit_percent").html(((data.week_end_value / data.week_start_value - 1) * 100).toFixed(2))

                update_portfolio_traders_chart(data.portfolio_week_traders)
                update_all_traders_chart(data.all_week_traders)

                process_history_chart_data(data.history_profit)
                return
        ).done(->
            return
        ).fail(->
            alert "fail remove_portfolio"
            return
        )

        $("#remove_portfolio_modal").modal "hide"
        return

    $("#remove_portfolio_cancel_modal_btn").on "click", (e) ->
        $("#remove_portfolio_modal").modal "hide"
        return


    # =========================================================================
    # Weeks block

    # create week methods
    $("#create_week_empty_btn").on "click", (e) ->
        create_week("empty")
        return

    $("#create_week_reinvest_btn").on "click", (e) ->
        create_week("reinvest")
        return

    # remove week methods
    $("#remove_week_btn").on "click", (e) ->
        $("#remove_week_modal").modal()
        return

    $("#remove_week_ok_modal_btn").on "click", (e) ->
        $.ajax(
            type: "GET"
            url: "/users/remove_week"
            dataType: "json"
            success: (data) ->
                # update totals
                $("#total_cash").html(data.total_cash)
                $("#total_percent").html(" " + data.total_percent)

                # update portfolio info
                $("#portfolio_rating").html(data.portfolio_rating)
                $("#portfolio_weeks").html(data.portfolio_weeks)

                update_weeks_chart(data.weeks)

                # update week total values
                $("#week_date").val(data.week_date)
                $("#week_start_value").html(data.week_start_value)
                $("#week_end_value").html(data.week_end_value)
                $("#week_free_cash").html(data.week_free_cash)
                $("#week_comment").val(data.week_comment)
                $("#week_profit_cash").html((data.week_end_value - data.week_start_value).toFixed(2))
                $("#week_profit_percent").html(((data.week_end_value / data.week_start_value - 1) * 100).toFixed(2))

                update_portfolio_traders_chart(data.portfolio_week_traders)
                update_all_traders_chart(data.all_week_traders)

                if data.is_history_chart_updated
                    process_history_chart_data(data.history_profit)
                return
        ).done(->
            return
        ).fail(->
            alert "fail remove_week"
            return
        )

        $("#remove_week_modal").modal "hide"
        return

    $("#remove_week_cancel_modal_btn").on "click", (e) ->
        $("#remove_week_modal").modal "hide"
        return


    # =========================================================================
    # Main table

    init_main_table()


    # =========================================================================
    # Main table block

    updated_week_date = ""
    error_message = ""
    # setting week date
    $("#week_date").datepicker(
        format: "dd.mm.yyyy"
        weekStart: 1
    ).on "changeDate", (e) ->
        # new_date = new Date(e.date.getFullYear(), e.date.getMonth(), e.date.getDate())
        date_in_milliseconds = e.date.getTime() - e.date.getTimezoneOffset() * (60 * 1000)

        $.ajax(
            type: "GET"
            url: "/users/update_week_date"
            dataType: "json"
            data:
                date: date_in_milliseconds
            success: (data) ->
                error_message = data.error_message

                if data.is_date_updated == "true"
                    # update week date
                    updated_week_date = data.week_date

                    # update totals
                    $("#total_cash").html(data.total_cash)
                    $("#total_percent").html(" " + data.total_percent)

                    update_weeks_chart(data.weeks)

                    update_all_traders_chart(data.all_week_traders)

                    process_history_chart_data(data.history_profit)
                return
        ).done(->
            $('#week_date').datepicker("hide")
            $("#week_date").val(updated_week_date)
            if error_message
                alert error_message
            return
        ).fail(->
            alert "fail update_week_date"
            return
        )
        return

    # setting start and end total values
    $("#week_start_value").editable
        showbuttons: false
        success: (response, new_value) ->
            $.ajax(
                type: "GET"
                url: "/users/update_week_value"
                dataType: "json"
                data:
                    start_value: new_value
                success: (data) ->
                    # update table percents
                    week_start_value = new_value
                    count_table_percents()

                    start_value = new_value
                    end_value = parseFloat($("#week_end_value").text())

                    # update totals
                    $("#total_cash").html(data.total_cash)
                    $("#total_percent").html(" " + data.total_percent)

                    # update portfolio rating
                    $("#portfolio_rating").html(data.portfolio_rating)

                    update_weeks_chart(data.weeks)

                    $("#week_profit_cash").html((end_value - start_value).toFixed(2))
                    $("#week_profit_percent").html(((end_value / start_value - 1) * 100).toFixed(2))

                    process_history_chart_data(data.history_profit)
                    return
            ).done(->
                return
            ).fail(->
                alert "fail update_week_value (start)"
                return
            )
            return

    $("#week_end_value").editable
        showbuttons: false
        success: (response, new_value) ->
            $.ajax(
                type: "GET"
                url: "/users/update_week_value"
                dataType: "json"
                data:
                    end_value: new_value
                success: (data) ->
                    start_value = parseFloat($("#week_start_value").text())
                    end_value = new_value

                    # update totals
                    $("#total_cash").html(data.total_cash)
                    $("#total_percent").html(" " + data.total_percent)

                    # update portfolio rating
                    $("#portfolio_rating").html(data.portfolio_rating)

                    update_weeks_chart(data.weeks)

                    $("#week_profit_cash").html((end_value - start_value).toFixed(2))
                    $("#week_profit_percent").html(((end_value / start_value - 1) * 100).toFixed(2))

                    process_history_chart_data(data.history_profit)
                    return
            ).done(->
                return
            ).fail(->
                alert "fail update_week_value (end)"
                return
            )
            return

    # setting free cash
    $("#week_free_cash").editable
        showbuttons: false
        success: (response, new_value) ->
            $.ajax(
                type: "GET"
                url: "/users/update_week_free_cash"
                dataType: "script"
                data:
                    free_cash: new_value
            ).done(->
                return
            ).fail(->
                alert "fail update_week_free_cash"
                return
            )
            return


    # =========================================================================
    # Main table methods

    # toggle favorite
    $("#main_table .fav_column").live "click", ->
        tableTools = TableTools.fnGetInstance("main_table")
        tableTools.fnSelectNone()
        alert "favorite - " + this.id
        return

    # handle click on trader name column
    $("#main_table .trader_column").live "click", ->
        tableTools = TableTools.fnGetInstance("main_table")
        tableTools.fnSelectNone()
        return

    # trader tooltip and popover
    $(".trader_column").tooltip
        toggle: "tooltip"
        container: "body"
        trigger: "hover"
        placement: "right"
        delay:
            show: 500
            hide: 100

    $(".trader_column").popover
        toggle: "popover"
        container: "body"
        trigger: "hover"
        placement: "right"
        delay:
            show: 500
            hide: 100
        html: true

    # update table cell (start and end value)
    $("#main_table .start_value_column").editable
        showbuttons: false
        success: (response, new_value) ->
            row = $(this).parent().parent().children().index($(this).parent()) + 2
            trader_account = $("#main_table tr:eq(" + row + ") td:eq(4)").html()

            $.ajax(
                type: "GET"
                url: "/users/update_table_cell"
                dataType: "json"
                data:
                    trader_account: trader_account
                    start_value: new_value
                success: (data) ->
                    count_table_percents(row)
                    count_table_profit(row)

                    update_portfolio_traders_chart(data.portfolio_week_traders)
                    update_all_traders_chart(data.all_week_traders)
                    return
            ).done(->
                return
            ).fail(->
                alert "fail update_table_cell (start)"
                return
            )
            return

    $("#main_table .end_value_column").editable
        showbuttons: false
        success: (response, new_value) ->
            row = $(this).parent().parent().children().index($(this).parent()) + 2
            trader_account = $("#main_table tr:eq(" + row + ") td:eq(4)").html()

            $.ajax(
                type: "GET"
                url: "/users/update_table_cell"
                dataType: "json"
                data:
                    trader_account: trader_account
                    end_value: new_value
                success: (data) ->
                    count_table_profit(row)
                    return
            ).done(->
                return
            ).fail(->
                alert "fail update_table_cell (end)"
                return
            )
            return

    # add row button handler
    $("#add_row_btn").on "click", (e) ->
        $("#trader_select_modal").modal()
        return

    $("#trader_select_modal").on "shown.bs.modal", (e) ->
        trader_select_table.fnAdjustColumnSizing()

    # remove row button handler
    $("#remove_row_btn").on "click", (e) ->
        tableTools = TableTools.fnGetInstance("main_table")
        selectedRows = tableTools.fnGetSelected()
        return unless selectedRows.length

        selected_row_data = tableTools.fnGetSelectedData()

        $.ajax(
            type: "GET"
            url: "/users/remove_table_row"
            dataType: "json"
            data:
                trader_account: selected_row_data[0][4]
            success: (data) ->
                update_portfolio_traders_chart(data.portfolio_week_traders)
                update_all_traders_chart(data.all_week_traders)
                return
        ).done(->
            main_table.fnDeleteRow(selectedRows[0])
            return
        ).fail(->
            alert "fail remove_table_row"
            return
        )
        return

    # custom elements for table
    # $("#main_table_title").html("Неделя 01.02.2014")
    $("#main_table_pay_all_button").html("<button class='btn btn-success btn-xs'
        style='position:relative; left:350px; top:10px;'
        onClick='window.open()'>Пополнить ВСЕ</button>")

    # select row with timeout
    setTimeout ( ->
        tableTools = TableTools.fnGetInstance("main_table")
        #tableTools.fnSelect($("#main_table tbody tr")[0])
    ), 1000

    $("#main_table tr").click( ->
        # $(this).toggleClass("row_selected")
        # alert "Selected row - " + $(this)
    )

    
    # =========================================================================
    # Trader select table

    trader_select_table = $("#trader_select_table").dataTable
        sDom: "<\"H\"> t <\"F\"iT>"
        sScrollY: "270px"
        bScrollCollapse: true
        bPaginate: false
        bJQueryUI: true
        aaSorting: [[3, "asc"]]
        oLanguage:
            sInfo: "_TOTAL_ управляющих"
            sInfoEmpty: "0 управляющих"
            sInfoFiltered: " (из _MAX_)"
            sZeroRecords: "Нет данных для отображения"
        oTableTools:
            sSwfPath: "http://localhost:3000/copy_csv_xls_pdf.swf"
            sRowSelect: "single"
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


    # =========================================================================
    # Trader select modal methods
    
    # brocker filter
    $("#brocker_select").change( ->
        trader_select_table.fnFilter(this.value, 0)
    )

    # favorite filter
    $("#favorite_select").change( ->
        trader_select_table.fnFilter(this.value, 1)
    )

    # trader filter
    $("#trader_input").keyup( ->
        trader_select_table.fnFilter(this.value, 2)
    )

    # account filter
    $("#account_input").keyup( ->
        trader_select_table.fnFilter(this.value, 3)
    )

    # add modal button handler
    $("#trader_select_add_modal_btn").on "click", (e) ->
        tableTools = TableTools.fnGetInstance("trader_select_table")
        selected_row_data = tableTools.fnGetSelectedData()

        if selected_row_data
            $.ajax(
                type: "GET"
                url: "/users/add_table_row"
                dataType: "json"
                data:
                    trader_account: selected_row_data[0][3]
                success: (data) ->
                    if data.is_table_row_added == "true"
                        update_portfolio_traders_chart(data.portfolio_week_traders)
                        update_all_traders_chart(data.all_week_traders)
                    return
            ).done(->
                tr = $("<tr/>")
                $("#portfolio_week_table").append tr
                
                i = 0
                while i < 16
                    tr.append "<td>cell</td>"
                    i++
                
                #main_table.fnSort [[5, "asc"]]

                # main_table.fnAddData [
                #     "1", "2", "2", "2", selected_row_data[0][3], "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2"
                # ]
                # TODO: add events to columns fav, управ, pay (or maybe reload table)
                return
            ).fail(->
                alert "fail add_table_row"
                return
            )

        $("#trader_select_modal").modal "hide"
        return

    # cancel modal button handler
    $("#trader_select_cancel_modal_btn").on "click", (e) ->
        $("#trader_select_modal").modal "hide"
        return


    # =========================================================================
    # Comment

    $("#week_comment").counter
        target: "#comment_counter"
        goal: 200
        msg: "символов"
        text: false

    $("#save_comment_button").on "click", (e) ->
        $.ajax(
                type: "GET"
                url: "/users/update_week_comment"
                dataType: "script"
                data:
                    comment: document.getElementById("week_comment").value
            ).done(->
                return
            ).fail(->
                alert "fail update_week_comment"
                return
            )
        return

    return





# =========================================================================
# ============================ Functions ==================================
# =========================================================================





# =========================================================================
# Main table

init_main_table = ->
    main_table = $("#main_table").dataTable
        sDom: "<'H'TC> t <'F'i<'#main_table_pay_all_button'>>"
        bStateSave: true
        sScrollX: "0px"               # TODO: remove
        # sScrollY: "150px"             # 540px - 20,5 rows
        bScrollCollapse: true
        bPaginate: false
        # bJQueryUI: true
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
                aTargets: [1]
                mRender: (data, type, row) ->
                    "# " + data
            }
            {
                aTargets: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
                sWidth: "50px"
            }
        ]
        oColVis:
            buttonText: "Колонки"
            sAlign: "right"
            aiExclude: [0,1,2,3,4,11,12,13,14]
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
        #fnFooterCallback: (nFoot, aData, iStart, iEnd, aiDisplay) ->
        #    nFoot.getElementsByTagName('th')[9].innerHTML = "Всего:"
        #    nFoot.getElementsByTagName('th')[10].innerHTML = "100%"
        #
        #    sumStart = 0
        #    sumEnd = 0
        #    sumProfit = 0
        #    i = 0
        #
        #    while i < aData.length
        #        sumStart += aData[i][11]*1
        #        sumEnd += aData[i][12]*1
        #        sumProfit += aData[i][13]*1
        #        i++
        #
        #    nFoot.getElementsByTagName('th')[11].innerHTML = sumStart.toFixed(2)       # parseInt(sumStart * 100) / 100
        #    nFoot.getElementsByTagName('th')[12].innerHTML = sumEnd.toFixed(2)
        #    nFoot.getElementsByTagName('th')[13].innerHTML = sumProfit.toFixed(2)
        #    nFoot.getElementsByTagName('th')[14].innerHTML = ((sumProfit / sumStart) * 100).toFixed(2)
        #    return
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
    return





# =========================================================================
# ============================== Charts ===================================
# =========================================================================





set_charts_options = ->
    # TODO: set all options

    Highcharts.setOptions
        legend:
            enabled: false
        plotOptions:
            series:
                pointWidth: 10
                borderWidth: 1
                borderColor: 'white'
                dataLabels:
                    enabled: true
                    format: "{point.y:.2f}"


# =========================================================================
# Weeks chart

update_weeks_chart = (data) ->
    weeks_ids = []
    weeks_dates = []
    weeks_values = []

    $.each data, (index, elem) ->
        $.each elem, (key, val) ->
            if key == "week_id"
                weeks_ids.push val
            else if key == "week_date"
                weeks_dates.push val
            else if key == "week_profit"
                weeks_values.push parseFloat(val)
            return

    weeks_data = []
    $.each weeks_values, (i) ->
        item = {
            name: weeks_ids[i]
            y: weeks_values[i]
            drilldown: true
        }
        weeks_data.push item

    $("#weeks_chart").highcharts
        chart:
            type: "column"
            borderWidth: 1
            # plotBackgroundColor: "rgba(255, 255, 255, .9)"
            plotShadow: true
            plotBorderWidth: 1
            events:
                drilldown: (e) ->
                    $.ajax(
                        type: "GET"
                        url: "/users/select_week"
                        dataType: "json"
                        data:
                            week_id: e.point.name
                        success: (data) ->
                            if data.is_selected_new_week == "true"
                                # init_main_table(data)
                                # main_table.fnReloadAjax("select_week.txt")

                                # update totals
                                $("#total_cash").html(data.total_cash)
                                $("#total_percent").html(" " + data.total_percent)

                                # update table total values
                                $("#week_date").val(data.week_date)
                                $("#week_start_value").html(data.week_start_value)
                                $("#week_end_value").html(data.week_end_value)
                                $("#week_free_cash").html(data.week_free_cash)
                                $("#week_comment").val(data.week_comment)
                                $("#week_profit_cash").html((data.week_end_value - data.week_start_value).toFixed(2))
                                $("#week_profit_percent").html(((data.week_end_value / data.week_start_value - 1) * 100).toFixed(2))

                                update_portfolio_traders_chart(data.portfolio_week_traders)
                                update_all_traders_chart(data.all_week_traders)

                                $.each data.traders, (index, elem) ->
                                    $.each elem, (key, val) ->
                                        # alert val
                                        return
                            return
                    ).done(->
                        return
                    ).fail(->
                        alert "fail select_week"
                        return
                    )
                    return
        series: [
            data: weeks_data
            name: "Портфель1"
        ]
        plotOptions:
            series:
                pointWidth: 15
                borderWidth: 2,
                borderColor: 'black'
            # column:
                # pointInterval: 3
        title:
            text: ""
        subtitle:
            text: "Недели:"
        xAxis:
            categories: weeks_ids
        yAxis:
            title:
                text: "Профит"
        credits:
            enabled: false
        legend:
            enabled: false
    return


# =========================================================================
# Traders pie charts

update_portfolio_traders_chart = (data) ->
    trader_accounts = []
    trader_names = []
    trader_values = []

    $.each data, (index, elem) ->
        $.each elem, (key, val) ->
            if key == "trader_account"
                trader_accounts.push val
            else if key == "trader_name"
                trader_names.push val
            else if key == "trader_value"
                trader_values.push parseFloat(val)
            return

    traders_data = []
    $.each trader_names, (i) ->
        if !trader_values[i]
            trader_values[i] = 0
        item = {
            name: trader_names[i] + " (" + trader_accounts[i] + ")"
            y: trader_values[i]
            drilldown: true
        }
        traders_data.push item

    $("#current_portfolio_traders_chart").highcharts
        chart:
            type: "pie"
            borderWidth: 1
            # plotBackgroundColor: "rgba(255, 255, 255, .9)"
            plotShadow: true
            plotBorderWidth: 1
            events:
                drilldown: (e) ->
                    alert e.point.name
                    return
        series: [
            data: traders_data
            name: "Портфель1"
        ]
        plotOptions:
            series:
                pointWidth: 15
                borderWidth: 2,
                borderColor: 'black'
            # column:
                # pointInterval: 100
        title:
            text: ""
        subtitle:
            text: "Доли управляющих - текущий портфель"
        xAxis:
            categories: trader_names
        yAxis:
            title:
                text: "Профит"
        credits:
            enabled: false
        legend:
            enabled: false
    return

update_all_traders_chart = (data) ->
    trader_accounts = []
    trader_names = []
    trader_values = []

    $.each data, (index, elem) ->
        $.each elem, (key, val) ->
            if key == "trader_account"
                trader_accounts.push val
            else if key == "trader_name"
                trader_names.push val
            else if key == "trader_value"
                trader_values.push parseFloat(val)
            return

    traders_data = []
    $.each trader_names, (i) ->
        if !trader_values[i]
            trader_values[i] = 0
        item = {
            name: trader_names[i] + " (" + trader_accounts[i] + ")"
            y: trader_values[i]
            drilldown: true
        }
        traders_data.push item

    $("#all_portfolios_traders_chart").highcharts
        chart:
            type: "pie"
            borderWidth: 1
            # plotBackgroundColor: "rgba(255, 255, 255, .9)"
            plotShadow: true
            plotBorderWidth: 1
            events:
                drilldown: (e) ->
                    alert e.point.name
                    return
        series: [
            data: traders_data
            name: "Портфель1"
        ]
        plotOptions:
            series:
                pointWidth: 15
                borderWidth: 2,
                borderColor: 'black'
            # column:
                # pointInterval: 100
        title:
            text: ""
        subtitle:
            text: "Доли управляющих - все портфели"
        xAxis:
            categories: trader_names
        yAxis:
            title:
                text: "Профит"
        credits:
            enabled: false
        legend:
            enabled: false
    return


# =========================================================================
# history charts

$("#percent_history_chart_button").live "click", ->
    this.disabled = true
    document.getElementById("cash_history_chart_button").disabled = false
    document.getElementById("grow_history_chart_button").disabled = false

    current_history_chart = 0
    update_history_chart()
    return

$("#cash_history_chart_button").live "click", ->
    this.disabled = true
    document.getElementById("percent_history_chart_button").disabled = false
    document.getElementById("grow_history_chart_button").disabled = false

    current_history_chart = 1
    update_history_chart()
    return

$("#grow_history_chart_button").live "click", ->
    this.disabled = true
    document.getElementById("percent_history_chart_button").disabled = false
    document.getElementById("cash_history_chart_button").disabled = false

    current_history_chart = 2
    update_history_chart()
    return

process_history_chart_data = (data) ->
    weeks = []
    portfolios = []
    percent_values = []
    cash_values = []
    $.each data, (index, elem) ->
        $.each elem, (key, val) ->
            if key == "week_date"               # && weeks.indexOf(val) < 0  # only unique weeks
                weeks.push val
            else if key == "portfolio_name"
                portfolios.push val
            else if key == "week_profit_percent"
                percent_values.push parseFloat(val)
            else if key == "week_profit_cash"
                cash_values.push parseFloat(val)
            return
        return
    history_chart_data = [weeks, portfolios, percent_values, cash_values]
    update_history_chart()
    return

update_history_chart = ->
    if current_history_chart == 0
        update_history_percent_chart(history_chart_data[0], history_chart_data[1], history_chart_data[2])
    else if current_history_chart == 1
        update_history_cash_chart(history_chart_data[0], history_chart_data[1], history_chart_data[3])
    else
        update_history_grow_chart(history_chart_data[0], history_chart_data[3])
    return

update_history_percent_chart = (weeks, portfolios, values) ->
    categories = {}
    categories_data = []
    subcategories = {}
    subcategories_data = []

    $.each weeks, (i) ->
        week = weeks[i]
        portfolio = portfolios[i]

        unless categories[week]
            categories[week] = values[i]
        else
            categories[week] += values[i]

        if portfolio isnt null
            subcategories[week] = []  unless subcategories[week]
            subcategories[week].push [
                portfolio
                values[i]
            ]
        return

    $.each categories, (key, value) ->
        categories_data.push
            name: key
            y: value
            drilldown: (if subcategories[key] then key else null)
        return

    categories_data.sort (a, b) ->
        # converted dates from format "%d.%m.%Y" to format "%Y.%m.%d" (for correct comparison)
        dateA = a.name.split('.')[2].toString() + a.name.split('.')[1].toString() + a.name.split('.')[0].toString()
        dateB = b.name.split('.')[2].toString() + b.name.split('.')[1].toString() + b.name.split('.')[0].toString()

        return -1  if dateA < dateB
        return 1  if dateA > dateB
        return 0

    $.each subcategories, (key, value) ->
        subcategories_data.push
            name: key
            id: key
            data: value
        return

    # chart options
    options =
        chart:
            type: "column"
        title:
            text: "Total profit - history chart"
        subtitle:
            text: "(click the columns to view profit by portfolios)"
        xAxis:
            type: "category"
            labels:
                rotation: -60
                color: '#FFFFFF'    # not work
                style:
                    fontSize: '11px'
                    fontFamily: 'Verdana, sans-serif'
        yAxis:
            title:
                text: "Total week profit, %"
        tooltip:
            headerFormat: "<span style=\"font-size:11px\">{series.name}</span><br>"
            pointFormat: "<span style=\"color:{point.color}\">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>"
        series: [
            name: "Weeks"
            colorByPoint: true
            data: categories_data
        ]
        drilldown:
            series: subcategories_data

    $("#history_chart").highcharts(options)
    return

update_history_cash_chart = (weeks, portfolios, values) ->
    categories = {}
    categories_data = []
    subcategories = {}
    subcategories_data = []

    $.each weeks, (i) ->
        week = weeks[i]
        portfolio = portfolios[i]

        unless categories[week]
            categories[week] = values[i]
        else
            categories[week] += values[i]

        if portfolio isnt null
            subcategories[week] = []  unless subcategories[week]
            subcategories[week].push [
                portfolio
                values[i]
            ]
        return

    $.each categories, (key, value) ->
        categories_data.push
            name: key
            y: value
            drilldown: (if subcategories[key] then key else null)
        return

    categories_data.sort (a, b) ->
        # converted dates from format "%d.%m.%Y" to format "%Y.%m.%d" (for correct comparison)
        dateA = a.name.split('.')[2].toString() + a.name.split('.')[1].toString() + a.name.split('.')[0].toString()
        dateB = b.name.split('.')[2].toString() + b.name.split('.')[1].toString() + b.name.split('.')[0].toString()

        return -1  if dateA < dateB
        return 1  if dateA > dateB
        return 0

    $.each subcategories, (key, value) ->
        subcategories_data.push
            name: key
            id: key
            data: value
        return

    $("#history_chart").highcharts
        chart:
            type: "column"
        title:
            text: "Total profit - history chart"
        subtitle:
            text: "(click the columns to view profit by portfolios)"
        xAxis:
            type: "category"
            labels:
                rotation: -60
                color: '#FFFFFF'    # not work
                style:
                    fontSize: '11px'
                    fontFamily: 'Verdana, sans-serif'
        yAxis:
            title:
                text: "Total week profit, $"
        tooltip:
            headerFormat: "<span style=\"font-size:11px\">{series.name}</span><br>"
            pointFormat: "<span style=\"color:{point.color}\">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>"
        series: [
            name: "Weeks"
            colorByPoint: true
            data: categories_data
        ]
        drilldown:
            series: subcategories_data
    return

update_history_grow_chart = (weeks, values) ->
    categories = {}
    categories_data = []

    $.each weeks, (i) ->
        week = weeks[i]

        unless categories[week]
            categories[week] = values[i]
        else
            categories[week] += values[i]
        return

    $.each categories, (key, value) ->
        categories_data.push
            name: key
            y: value
        return

    # sort data by weeks
    categories_data.sort (a, b) ->
        # converted dates from format "%d.%m.%Y" to format "%Y.%m.%d" (for correct comparison)
        dateA = a.name.split('.')[2].toString() + a.name.split('.')[1].toString() + a.name.split('.')[0].toString()
        dateB = b.name.split('.')[2].toString() + b.name.split('.')[1].toString() + b.name.split('.')[0].toString()

        return -1  if dateA < dateB
        return 1  if dateA > dateB
        return 0

    # sum values
    categories_values = []
    $.each categories_data, (index, elem) ->
        for key of elem
            if key == "y"
                categories_values.push elem[key]
        return

    $.each categories_values, (index, elem) ->
        if index > 0
            categories_values[index] += categories_values[index - 1]
        return

    $.each categories_data, (index, elem) ->
        for key of elem
            if key == "y"
                categories_data[index][key] = categories_values[index]
        return

    $("#history_chart").highcharts
        title:
            text: "Total profit - history chart"
        subtitle:
            text: "(subtitle)"
        xAxis:
            type: "category"
            labels:
                rotation: -60
                color: '#FFFFFF'    # not work
                style:
                    fontSize: '11px'
                    fontFamily: 'Verdana, sans-serif'
        yAxis:
            title:
                text: "Total profit, $"
        tooltip:
            headerFormat: "<span style=\"font-size:11px\">{series.name}</span><br>"
            pointFormat: "<span style=\"color:{point.color}\">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>"
        series: [
            name: "Weeks"
            colorByPoint: true
            data: categories_data
        ]
    return





# =========================================================================
# ========================== Other methods ================================
# =========================================================================





create_week = (type) ->
    $.ajax(
        type: "GET"
        url: "/users/create_week"
        dataType: "json"
        data:
            week_type: type
        success: (data) ->
            # update totals
            $("#total_cash").html(data.total_cash)
            $("#total_percent").html(" " + data.total_percent)

            # update portfolio info
            $("#portfolio_weeks").html(data.portfolio_weeks)

            update_weeks_chart(data.weeks)

            # update week total values
            $("#week_date").val(data.week_date)
            $("#week_start_value").html(data.week_start_value)
            $("#week_end_value").html("")
            $("#week_free_cash").html("")
            $("#week_comment").val("")
            $("#week_profit_cash").html("")
            $("#week_profit_percent").html("")

            update_portfolio_traders_chart(data.portfolio_week_traders)
            update_all_traders_chart(data.all_week_traders)

            if data.is_history_chart_updated
                process_history_chart_data(data.history_profit)

            # portfolio traders for "reinvest" week type
            # TODO: apply when DataTables Ajax reloading will be fixed
            
            # $("#info").html(data.portfolio_traders)
            return
    ).done(->
        return
    ).fail(->
        alert "fail create_week"
        return
    )
    return

count_table_percents = (row) ->
    if row
        if week_start_value != 0
            $("#main_table tr:eq(" + row + ") td:eq(10)").html(($("#main_table tr:eq(" + row + ") td:eq(11)").html() / week_start_value * 100).toFixed(2))
        else
            $("#main_table tr:eq(" + row + ") td:eq(10)").html("")
    else
        $("#main_table tr").each (i) ->
            row = i + 2
            if week_start_value != 0
                $("#main_table tr:eq(" + row + ") td:eq(10)").html(($("#main_table tr:eq(" + row + ") td:eq(11)").html() / week_start_value * 100).toFixed(2))
            else
                $("#main_table tr:eq(" + row + ") td:eq(10)").html("")
    return

count_table_profit = (row) ->
    start_value = $("#main_table tr:eq(" + row + ") td:eq(11)").html()
    end_value = $("#main_table tr:eq(" + row + ") td:eq(12)").html()

    if start_value && end_value
        $("#main_table tr:eq(" + row + ") td:eq(13)").html((end_value - start_value).toFixed(2))
        $("#main_table tr:eq(" + row + ") td:eq(14)").html(((end_value / start_value - 1) * 100).toFixed(2))
    else
        # not work
        $("#main_table tr:eq(" + row + ") td:eq(13)").html("")
        $("#main_table tr:eq(" + row + ") td:eq(14)").html("")
    return












































# =========================================================================
# ============================ Test functions =============================
# =========================================================================





test_chart = ->
    $("#test_chart").highcharts
        chart:
            type: "column"
            backgroundColor:
                linearGradient: [
                    0
                    0
                    500
                    500
                ]
                stops: [
                    [
                        0
                        "rgb(255, 255, 255)"
                    ]
                    [
                        1
                        "rgb(140, 140, 255)"
                    ]
                ]
            borderWidth: 2
            plotBackgroundColor: "rgba(255, 255, 255, .9)"
            plotShadow: true
            plotBorderWidth: 1
        title:
            text: "Chart name"
        xAxis:
            categories: [
                "category1"
                "category1"
                "category1"
            ]
        yAxis:
            title:
                text: "Y axis name"
        series: [
            {
                name: "Igor"
                data: [
                    1
                    0
                    4
                ]
            }
            {
                name: "2"
                data: [
                    5
                    7
                    3
                ]
            }
            {
                name: "3"
                data: [
                    29.9
                    21.5
                    16.4
                    35.6
                    24.4
                ]
                pointStart: 0.0
                pointInterval: 1.0
            }
        ]
    return

# -------------------------------------------------------------------------------------

test_drilldown_chart = ->
    categories = {}
    categories_data = []
    subcategories = {}
    subcategories_data = []

    weeks = [
        7
        14
        21
        28
    ]
    values = [
        [
            11
            12
            13
        ]
        [
            21
            22
            23
        ]
        [
            31
            32
            33
        ]
        [
            41
            null
            0
        ]
    ]
    portfolios = [
        "port1"
        "port2"
        "port3"
    ]

    $.each weeks, (i) ->
        $.each portfolios, (j) ->
            week = weeks[i]
            portfolio = portfolios[j]

            unless categories[week]
                categories[week] = values[i][j]
            else
                categories[week] += values[i][j]

            if portfolio isnt null
                subcategories[week] = []  unless subcategories[week]
                subcategories[week].push [
                    portfolio
                    values[i][j]
                ]
            return

    $.each categories, (key, value) ->
        categories_data.push
            name: key
            y: value
            drilldown: (if subcategories[key] then key else null)
        return

    $.each subcategories, (key, value) ->
        subcategories_data.push
            name: key
            id: key
            data: value
        return

    $("#test_drilldown_chart").highcharts
        chart:
            type: "column"
        title:
            text: "Total profit - history chart"
        subtitle:
            text: "(click the columns to view profit by portfolios)"
        xAxis:
            type: "category"
        yAxis:
            title:
                text: "Total week profit"
        legend:
            enabled: false
        plotOptions:
            series:
                borderWidth: 0
                dataLabels:
                    enabled: true
                    format: "{point.y:.1f}%"
        tooltip:
            headerFormat: "<span style=\"font-size:11px\">{series.name}</span><br>"
            pointFormat: "<span style=\"color:{point.color}\">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>"
        series: [
            name: "Weeks"
            colorByPoint: true
            data: categories_data
        ]
        drilldown:
            series: subcategories_data
    return



