{$, $$, View} = require 'atom-space-pen-views'
$ = window.$ = window.jQuery = require 'jquery'
require './jquery-ui.js'
{ ReplHistory } = require './console-repl'

module.exports =
class ConsoleView extends View
  @selectTab:1
  replId: 0
  @content: ->
    @div id: 'atom-console', class: 'view-resizer panel', outlet: 'atomConsole', =>
      @div class: 'view-resize-handle', outlet: 'resizeHandle'
      @div class: 'panel-heading', dblclick: 'toggle', outlet: 'heading'
      @div id:'tabs', style:"border-width:0;padding:0px;", =>
        @ul style:"height: 38px;", class: "thera-console-tab", outlet: 'selectTabUl',=>
          @li class:'button hvr-hang' ,=>
            @a href:'#tabs-1',' logcat', =>
              @span class:'fa fa-exclamation-triangle'
          @li class:'button hvr-hang' ,=>
            @a href:'#tabs-2',' Server', =>
              @span class:'fa fa-bug'

          @li class:'button hvr-hang' ,=>
            @a href:'#tabs-3',' Device', =>
              @span class:'fa fa-tablet'

          @li class:'button hvr-hang' ,=>
            @a href:'#tabs-4',' Preview-Device', =>
              @span class:'fa fa-bars'

          @li class:'fa fa-trash-o logclearButton button hvr-grow',outlet: 'consoleClearButton', click: 'clear'

        @div id:'tabs-1', class: 'thera-console', =>
          @div class: 'panel-body closed view-scroller', outlet: 'body', =>
            @pre class: 'thera-log native-key-bindings', outlet: 'output', tabindex: -1
          @div class: 'repl-bar', =>
            @span class: 'fa fa-chevron-right'
            @div => # https://www.zhihu.com/question/37208845
              @input class: 'native-key-bindings', type: 'text', outlet: 'input'

        @div id:'tabs-2', =>
          @div class: 'panel-body closed view-scroller', outlet: 'body4Debugger', =>
            @pre class: 'native-key-bindings', outlet: 'output4Debugger', tabindex: -1

        @div id:'tabs-3', =>
          @div class: 'panel-body closed view-scroller', outlet: 'body4Device', =>
            @pre class: 'native-key-bindings', outlet: 'output4Device', tabindex: -1

        @div id:'tabs-4', =>
          @div class: 'panel-body closed view-scroller', outlet: 'body4SubPreview', =>
            @pre class: 'native-key-bindings', outlet: 'output4SubPreview', tabindex: -1

    $ ->
      $('#tabs').tabs({
        hide: { effect: "blind", duration: 0 }
        show: { effect: "blind", duration: 0 }
        })
      return

  initialize: (serializeState) ->
    @tabHeight = serializeState?.height || 200
    tab.height(@tabHeight - 18) for tab in [@body]    # 18px height for REPL bar
    tab.height(@tabHeight) for tab in [@body4Debugger, @body4Device, @body4SubPreview]
    pre.css('minHeight', @tabHeight - 18) for pre in [@output]
    pre.css('minHeight', @tabHeight) for pre in [@output4Debugger, @output4Device, @output4SubPreview]

    $ =>  # Bring the whole bottom panel front to overlay panes's file tab.
      $('#atom-console').parent().parent().addClass('z-index-3')
      $('#tabs').height(@tabHeight + 38)

    @input[0].addEventListener('input', (e) => @inputChanged(e.currentTarget))
    @input[0].addEventListener('keydown', (e) => @inputKeyDown(e))
    @replHistory = new ReplHistory()

    @panel = atom.workspace.addBottomPanel(item: @element, priority: 100, visible: false)
    @handleEvents()

  # Tear down any state and detach
  destroy: ->
    @disposables?.dispose()

  show: ->
    @panel.show()
    $('#atom-console').show('blind', null, 300, null)
    activePanel = $('.thera-console-tab').filter((index, ele) -> ele.style.display isnt 'none')[0]
    $(activePanel).append $$ ->
      @div class: 'thera-find-bar', =>
        @p =>
          @input id: 'console-find-input', class: 'native-key-bindings', type: 'text', outlet: 'find', placeholder:'Find in console'
          # @button click: 'findClick'

    $('#console-find-input').keypress((event) => @findPress(event))


  hide: ->
    $('#atom-console').hide('blind', null, 300, null)

  toggle: ->
    if $('#atom-console').is(":visible")
      @hide()
    else
      @show()

  handleEvents: ->
    @on 'dblclick', '.view-resize-handle', =>
      @resizeToFitContent()

    @on 'mousedown', '.view-resize-handle', (e) => @resizeStarted(e)

  resizeStarted: ({pageY}) =>
    $(document).on('mousemove', @resizeView)
    $(document).on('mouseup', @resizeStopped)
    @resizeStartY = pageY   # Remember the down pos for calculate offset when moving
    @resizeStartHeight = @tabHeight

  resizeStopped: =>
    $(document).off('mousemove', @resizeView)
    $(document).off('mouseup', @resizeStopped)

  resizeView: ({which, pageY}) =>
    return @resizeStopped() unless which is 1
    @tabHeight = (@resizeStartY - pageY) + @resizeStartHeight
    @tabHeight = 0 if @tabHeight < 0

    atomConsole = $('#atom-console')  # 26 for status bar at bottom
    # If panel has reached the top? 26px for status bar
    if atomConsole.offset().top + atomConsole.outerHeight() + 26 >= $(document.body).height() and pageY <= atomConsole.offset().top
      @tabHeight = $(document.body).height() - atomConsole.offset().top - @heading.outerHeight() - @selectTabUl.outerHeight() - 26 - 4

    # Set height explicitly to force editor to account for the tab height when adjust area at bottom
    $('#tabs').height(@tabHeight + @selectTabUl.outerHeight())
    tab.height(@tabHeight - 18) for tab in [@body]    # 18px height for REPL bar
    tab.height(@tabHeight) for tab in [@body4Debugger, @body4Device, @body4SubPreview]
    pre.css('minHeight', @tabHeight - 18) for pre in [@output]
    pre.css('minHeight', @tabHeight) for pre in [@output4Debugger, @output4Device, @output4SubPreview]

  resizeToFitContent: ->
    @selectedTab = $('#tabs').tabs('option', 'active')
    if @selectedTab == 0
      @body.height(1) # Shrink to measure the minimum width of list
      @body.height(@body.find('>').outerHeight())
    else if @selectedTab == 1
      console.log "todo.."
    else
      @body4Device.height(1) # Shrink to measure the minimum width of list
      @body4Device.height(@body4Device.find('>').outerHeight())

  log: (message, level) ->
    # if $('#atom-console').is(":visible")
    at_bottom = (@body.scrollTop() + @body.innerHeight() + 10 > @body[0].scrollHeight)

    if typeof message == 'string'
      @output.append $$ ->
        @p class: 'searchable level-' + level, js_yyyy_mm_dd_hh_mm_ss() + ' ' + message
    else if typeof message == 'object' and message.evalLog
      @evalObject(message, level)
    else
      @output.append message

    if at_bottom
      @body.scrollTop(@body[0].scrollHeight)

  log4Server: (message, level) ->
    # if $('#atom-console').is(":visible")
    at_bottom = (@body4Debugger.scrollTop() + @body4Debugger.innerHeight() + 10 > @body4Debugger[0].scrollHeight)

    if typeof message == 'string'
      @output4Debugger.append $$ ->
        @p class: 'searchable level-' + level, js_yyyy_mm_dd_hh_mm_ss() + ' ' + message
    else
      @output4Debugger.append message

    if at_bottom
      @body4Debugger.scrollTop(@body4Debugger[0].scrollHeight)

  log4Device: (message, level) ->
    # if $('#atom-console').is(":visible")
    at_bottom = (@body4Device.scrollTop() + @body4Device.innerHeight() + 10 > @body4Device[0].scrollHeight)

    if typeof message == 'string'
      @output4Device.append $$ ->
        @p class: 'searchable level-' + level, js_yyyy_mm_dd_hh_mm_ss() + ' ' + message
    else
      @output4Device.append message

    if at_bottom
      @body4Device.scrollTop(@body4Device[0].scrollHeight)
      #@show()


  clear: ->
    @selectedTab = $('#tabs').tabs('option', 'active')

    if @selectedTab == 0
      @output.empty()
    else if @selectedTab == 1
      @output4Debugger.empty()
    else
      @output4Device.empty()


  changeLogcatToDevice:(deviceName)->
    @output.empty()
    deviceInfo  = 'current device: '+deviceName
    @output.append deviceInfo

  js_yyyy_mm_dd_hh_mm_ss = ->
    now = new Date
    year = '' + now.getFullYear()
    month = '' + (now.getMonth() + 1)
    day = '' + now.getDate()
    hour = '' + now.getHours()
    minute = '' + now.getMinutes()
    second = '' + now.getSeconds()
    millis = '' + now.getMilliseconds()

    if month.length == 1
      month = '0' + month
    if day.length == 1
      day = '0' + day
    if hour.length == 1
      hour = '0' + hour
    if minute.length == 1
      minute = '0' + minute
    if second.length == 1
      second = '0' + second
    if millis.length < 3
      millis = (if millis.length == 2 then '0' else '00') + millis

    "#{month}-#{day} #{hour}:#{minute}:#{second}.#{millis}"
    # year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second + '.' + now.getMilliseconds()

  setDebugServiceProvider: (serviceProvider) ->
    @debugServiceProvider = serviceProvider

  inputChanged: (view) ->
    # TODO: suggest prompt here
    # console.log(view.value, view)

  inputKeyDown: (e) ->
    if e.keyCode == 13      # Enter pressed
      value = @input[0].value
      @input[0].value = ''
      if value
        @log("> " + value, 'debug')
        @evaluateExpression(value)
        @replHistory.add(value)
    else if e.keyCode == 38 # ArrowUp pressed
      @input[0].value = @replHistory.prev()
    else if e.keyCode == 40 # ArrowDown pressed
      @input[0].value = @replHistory.next()
    else if e.keyCode == 9  # Tab pressed
      console.log(e)

  evaluateExpression: (expression) ->
    service = @debugServiceProvider?.currentProvider()
    if not service
      @log('Debug service not available!', 'error')
      return
    try
      promise = service.runtimeEvaluate(expression, 'REPL')
      promise.then((res) => @evaluateSuccess(res)).catch((err) => @evaluateFail(err));
    catch error
      console.error(error);

  # RemoteObject
  evaluateSuccess: (res) ->
    console.log(res)
    if not res
      return
    res.evalLog = true
    @log(res, 'debug')

  # string or exception RemoteObject
  evaluateFail: (err) ->
    console.log(err);
    if not err
      return
    if typeof err == 'object' and err.objectId
      err.evalLog = true
      @log(err, 'error')
    else if typeof err == 'string'
      @log(err, 'error')
    else
      @log(JSON.stringify(err), 'error')

  getReplId: ->
    return ++@replId

  expandClick: (holder, view) ->
    icon = holder.parent().prev()[0]
    icon.classList.remove('evaluate-result-expand-icon')
    icon.classList.remove('evaluate-result-collapse-icon')
    icon.classList.remove('fa-plus-square')
    icon.classList.remove('fa-minus-square')
    if holder.children().length > 0
      console.log('Children count = ' + holder.children().length)
      holder.toggle()
      icon.classList.add(if holder.is(':visible') then 'evaluate-result-collapse-icon' else 'evaluate-result-expand-icon')
      icon.classList.add(if holder.is(':visible') then 'fa-minus-square' else 'fa-plus-square')
      return false

    data = view.data
    if data?.objectId
      @getProperties(holder, data.objectId)
      holder.show()
      icon.classList.add('fa-minus-square')
      icon.classList.add('evaluate-result-collapse-icon')
    else
      console.error('Primitive object cannot be expanded', data)
    return false

  getProperties: (holder, objectId) ->
    service = @debugServiceProvider?.currentProvider()
    if not service
      @log('Debug service not available !', 'error');
      return
    else if not objectId
      @log('objectId cannot be empty !', 'error')
      return
    try
      promise = service.getProperties(objectId)
      promise.then((res) => @propertySuccess(holder, res)).catch((err) => @propertyFail(holder, err));
    catch error
      console.error(error)

  propertySuccess: (holder, res) ->
    console.log(holder, res)
    for prop in res
      @propObject(holder, prop)

  propertyFail: (holder, err) ->
    console.log(holder, err)

  # message {
  #   className: undefined
  #   description: "DedicatedWorkerGlobalScope"
  #   evalLog: true
  #   objectId: '{"injectedScriptId":3,"id":106}'
  #   subtype: undefined
  #   type: "object"
  #   value: undefined
  # }
  evalObject: (object, level) ->
    id = @getReplId()
    rowId = 'eval-expand-' + id
    holderId = 'eval-expand-holder-' + id
    self = this
    hasChildren = object.objectId and object.type != 'symbol'
    if hasChildren
      @output.append $$ ->
        @div class: 'eval-block', id: rowId, =>
          # plus-square minus-square
          @span class: 'fa fa-plus-square evaluate-result-expand-icon'
          @div =>
            @p class: '', object.className || object.description
            @div style: 'display: none', id: holderId
      $ ->
        holder = $('#'+holderId)
        $('#'+rowId).click(object, self.expandClick.bind(self, holder))
    else
      @output.append $$ ->
        @p class: 'level-' + level, object.value + '' # Primitive value
    @body.scrollTop(@body[0].scrollHeight)

  propObject: (holder, prop) ->
    id = @getReplId()
    rowId = 'prop-expand-' + id
    holderId = 'prop-expand-holder-' + id
    self = this
    # Extract string representing the object value
    value = prop.value
    hasChildren = value.objectId and value.type != 'symbol'
    if hasChildren
      valStr = value.className || value.description
    else
      valStr = '' + value.value
    # Render value to ui
    if hasChildren
      holder.append $$ ->
        @div class: 'eval-block', id: rowId, =>
          @span class: 'fa fa-plus-square evaluate-result-expand-icon'
          @div =>
            @p class: '', prop.name + ": " + valStr
            @div id: holderId
      $ ->
        holder = $('#'+holderId)
        $('#'+rowId).click(prop.value, self.expandClick.bind(self, holder))
    else
      holder.append $$ ->
        @div class: 'eval-block', id: rowId, =>
          @span class: 'evaluate-result-empty-icon'
          @div =>
            @p class: '', prop.name + ": " + valStr
            @div id: holderId
      $ ->
        holder = $('#'+holderId)
        $('#'+rowId).click(prop.value, self.expandClick.bind(self, holder))

  find: (event) ->
    $('#console-find-input').focus()
    # if $('.thera-find-bar').length is 0
    #   @indexToFind = undefined
      # activePanel = $('.thera-console-tab').filter((index, ele) -> ele.style.display isnt 'none')[0]
      # $(activePanel).append $$ ->
      #   @div class: 'thera-find-bar', =>
      #     @p =>
      #       @input id: 'console-find-input', class: 'native-key-bindings', type: 'text', outlet: 'find', placeholder:'Find in console'
      #       # @button click: 'findClick'
      #
      # $('#console-find-input').keypress((event) => @findPress(event))



  closeFind: (event) ->
    @clearFindResult()
    @indexToFind = undefined
    atom.document.getElementById('console-find-input').value = ""
    # $('.thera-find-bar').remove()

  findPress: (event) ->
    if event.which is 13 # enter key
      stringToFind = atom.document.getElementById('console-find-input').value
      @clearFindResult()
      if event.shiftKey
        @findLast(stringToFind)
      else
        @findNext(stringToFind)

  findLast: (stringToFind) ->
    @clearFindResult()

    if @indexToFind is undefined
      @indexToFind = 1

    --@indexToFind
    @startFind(stringToFind, @indexToFind)


  findNext: (stringToFind) ->
    @clearFindResult()

    if @indexToFind is undefined
      @indexToFind = -1

    ++@indexToFind
    @startFind(stringToFind, @indexToFind)


  startFind: (stringToFind, highlightIndex) ->
    array = $("div.ui-tabs-panel:visible").find("p.searchable:contains('"+stringToFind+"')")
    array.each( (i, element) ->
      content = $(element).text()

      if i is ((highlightIndex + array.length * 100) % array.length)
        element.innerHTML = content.replace( stringToFind, '<span class="search-found highlight">' + stringToFind + '</span>' )
        element.scrollIntoView()
      else
        element.innerHTML = content.replace( stringToFind, '<span class="search-found">' + stringToFind + '</span>' )
    )

  clearFindResult: ->
    $('span.search-found').each((i, element) ->
      $(element).replaceWith($(element).text())
    )
