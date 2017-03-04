{$, $$, View} = require 'atom-space-pen-views'
$ = window.$ = window.jQuery = require 'jquery'
require './jquery-ui.js'


module.exports =
class ConsoleView extends View
  @selectTab:1
  @content: ->
    @div id: 'atom-console', class: 'view-resizer panel',outlet: 'atomConsole', =>
      @div class: 'view-resize-handle', outlet: 'resizeHandle'
      @div class: 'panel-heading', dblclick: 'toggle', outlet: 'heading', =>
        #@button class: 'btn pull-right', click: 'clear', 'Clear'
        @div class: 'panel-heading panel-simulator-info', =>
          @select class: 'target-selector', name: 'targetSelect', outlet: 'targetSelect', =>
            # @option value: 'device', 'device', selected: true
            # @option value: 'H60-L01 iphone', 'H60-L01 iphone'
          # @span class:'fa fa-apple',style:"color:rgb(160,160,160)"
          # @span 'iPhone7 Plus',style:"color:rgb(160,160,160)"
          # @span '-',style:"color:rgb(160,160,160)"
          # @span '10.1.1(14B100)',style:"color:rgb(160,160,160)"
          # @span '-',style:"color:rgb(160,160,160)"
          # @span '1080x1920',style:"color:rgb(160,160,160)"
          # @span ' '
          # @span class:'fa fa-wifi',style:"color:rgb(194,194,194)"
          # @span '192.168.1.199:8888',style:"color:rgb(194,194,194)"
          # @span ' '
          @span class:'fa fa-heartbeat',style:"color:rgb(60,184,121)"
          @span 'Oreo-Server was running',style:"color:rgb(60,184,121)", id: 'oreo-server-status'


      @div id:'tabs',style:"background:rgb(14,17,18);border-width:0", =>
        @ul outlet: 'selectTabUl',=>
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


        @div id:'tabs-1', =>
          @div class: 'panel-body closed view-scroller', outlet: 'body', =>
            @pre class: 'native-key-bindings', outlet: 'output', tabindex: -1

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
    @body.height serializeState?.height
    @body4Debugger.height serializeState?.height
    @body4Device.height serializeState?.height
    @body4SubPreview.height serializeState?.height
    @targetSelect.change((e) => @targetChanged(e.currentTarget))

    atom.workspace.addBottomPanel(item: @element, priority: 100)
    @hide()
    @handleEvents()



  # Returns an object that can be retrieved when package is activated
  # serialize: ->
    #test use it...
    #height: @body.height
    #atom.commands.dispatch(atom.views.getView(atom.workspace), 'console:log',['UIKit                               0x3748c9eb -[UIApplication sendAction:to:from:forEvent:] + 62','debug'])
    #atom.commands.dispatch(atom.views.getView(atom.workspace), 'console:log',['UIKit                               0x3748c9a7 -[UIApplication sendAction:toTarget:fromSender:forEvent:] + 30','debug'])
    #atom.commands.dispatch(atom.views.getView(atom.workspace), 'console:log',['UIKit                               0x3748c985 -[UIControl sendAction:to:forEvent:] + 44','debug'])
    #atom.commands.dispatch(atom.views.getView(atom.workspace), 'console:log',['UIKit                               0x3748c985 -[UIControl sendAction:to:forEvent:] + 44','debug'])
    #atom.commands.dispatch(atom.views.getView(atom.workspace), 'console:log',['#define FeLogError(format,...)        writeCinLog(__FUNCTION__,CinLogLevelError,format,##__VA_ARGS__)','error'])


  # Tear down any state and detach
  destroy: ->
    @disposables?.dispose()

  show: ->
    $('#atom-console').show('blind', null, 300, null)

  hide: ->
    $('#atom-console').hide('blind', null, 300, null)


  toggle: ->
    if $('#atom-console').is(":visible")
      @hide()
    else
      @show()

  targetChanged: (selector) ->
    selectedOption = selector.options[selector.options.selectedIndex];
    target = selectedOption.tag;
    atom.commands.dispatch(atom.views.getView(atom.workspace), "thera-debugger:debugger:main-device", target);

  updateTargets: (targets) ->
    targets = targets || [];
    selectView = @targetSelect[0];  # <select/>
    options = selectView.options    # [<option/>]
    # Remember current selected target.
    selectedOption = options[options.selectedIndex]
    selectedTarget = if selectedOption then selectedOption.tag else null

    prvTargetIndex = -1; # Previous connected target is still there.
    @targetSelect.empty()
    for target, i in targets
      do (target, i) =>
        option = document.createElement('option')
        option.text = "#{target.model} - #{target.deviceId.split('|')[1]} - #{target.weexVersion}"
        option.val = target.deviceId
        option.tag = target
        selectView.add(option);
        if selectedTarget and selectedTarget.deviceId == target.deviceId
          prvTargetIndex = i;

    if targets.length == 0  # Clear shadow...
      selectView.add(document.createElement('option'))
      @targetSelect.empty()

    if prvTargetIndex >= 0      # Keep previous selected option
      selectView.options[prvTargetIndex].selected = true
    else if targets.length > 0  # Select first option by default
      selectView.options[0].selected = true
      @targetChanged(selectView)


  log: (message, level) ->
    # if $('#atom-console').is(":visible")
    at_bottom = (@body.scrollTop() + @body.innerHeight() + 10 > @body[0].scrollHeight)

    if typeof message == 'string'
      @output.append $$ ->
        @p class: 'level-' + level, js_yyyy_mm_dd_hh_mm_ss() + ' ' + message
    else
      @output.append message

    if at_bottom
      @body.scrollTop(@body[0].scrollHeight)

  log4Server: (message, level) ->
    # if $('#atom-console').is(":visible")
    at_bottom = (@body4Debugger.scrollTop() + @body4Debugger.innerHeight() + 10 > @body4Debugger[0].scrollHeight)

    if typeof message == 'string'
      @output4Debugger.append $$ ->
        @p class: 'level-' + level, js_yyyy_mm_dd_hh_mm_ss() + ' ' + message
    else
      @output4Debugger.append message

    if at_bottom
      @body4Debugger.scrollTop(@body4Debugger[0].scrollHeight)

  log4Device: (message, level) ->
    # if $('#atom-console').is(":visible")
    at_bottom = (@body4Device.scrollTop() + @body4Device.innerHeight() + 10 > @body4Device[0].scrollHeight)

    if typeof message == 'string'
      @output4Device.append $$ ->
        @p class: 'level-' + level, js_yyyy_mm_dd_hh_mm_ss() + ' ' + message
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


    #@hide()

  handleEvents: ->
    @on 'dblclick', '.view-resize-handle', =>
      @resizeToFitContent()

    @on 'mousedown', '.view-resize-handle', (e) => @resizeStarted(e)

  resizeStarted: =>
    $(document).on('mousemove', @resizeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizeView)
    $(document).off('mouseup', @resizeStopped)

  resizeView: ({which, pageY}) =>
    return @resizeStopped() unless which is 1

    # @selectedTab = $('#tabs').tabs('option', 'active')

    # if @selectedTab == 0
    #   @body.height($(document.body).height() - pageY - @heading.outerHeight() - @selectTabUl.outerHeight() - @resizeHandle.outerHeight()*2)
    # else if @selectedTab == 1
    #   console.log "todo.."
    # else
    #   @body4Device.height($(document.body).height() - pageY - @heading.outerHeight() - @selectTabUl.outerHeight() - @resizeHandle.outerHeight()*2)
    @tabHeight = $(document.body).height() - pageY - @heading.outerHeight() - @selectTabUl.outerHeight() - @resizeHandle.outerHeight()*2
    tab.height(@tabHeight) for tab in [@body, @body4Debugger, @body4Device, @body4SubPreview]


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


  js_yyyy_mm_dd_hh_mm_ss = ->
    now = new Date
    year = '' + now.getFullYear()
    month = '' + (now.getMonth() + 1)
    if month.length == 1
      month = '0' + month
    day = '' + now.getDate()
    if day.length == 1
      day = '0' + day
    hour = '' + now.getHours()
    if hour.length == 1
      hour = '0' + hour
    minute = '' + now.getMinutes()
    if minute.length == 1
      minute = '0' + minute
    second = '' + now.getSeconds()
    if second.length == 1
      second = '0' + second

    year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second + '.' + now.getMilliseconds()
