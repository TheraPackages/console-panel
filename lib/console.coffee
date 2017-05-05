ConsoleView = require './console-view'
ConsoleManager = require './console-manager'
{CompositeDisposable} = require 'atom'

Array::first ?= (n) ->
  if n? then @[0...(Math.max 0, n)] else @[0]

Array::last ?= (n) ->
  if n? then @[(Math.max @length - n, 0)...] else @[@length - 1]

module.exports = Console =
  consoleView: null
  subscriptions: null
  debuggerService: null

  activate: (state) ->
    @consoleView = new ConsoleView(state.consoleViewState)
    @consoleManager = new ConsoleManager(@consoleView)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'console:toggle': =>
      @consoleManager.toggle()

    @subscriptions.add atom.commands.add 'atom-workspace', 'console:log': ({detail}) =>
      @consoleView.log(detail.first(),detail.last())

    @subscriptions.add atom.commands.add 'atom-workspace', 'server:log': ({detail}) =>
      @consoleView.log4Server(detail.first(),detail.last())

    @subscriptions.add atom.commands.add 'atom-workspace', 'console:devicelog': ({detail}) =>
      @consoleView.log4Device(detail.first(),detail.last())

    @subscriptions.add atom.commands.add 'atom-workspace', 'console:find': (event) =>
      @consoleView.find(event)

    @subscriptions.add atom.commands.add 'atom-workspace', 'console:changeLogDevice': ({detail}) =>
      @consoleView.changeLogcatToDevice(detail)

    @subscriptions.add atom.commands.add 'atom-workspace', 'console:close-find': (event) =>
      @consoleView.closeFind(event)
      
  deactivate: ->
    @subscriptions.dispose()
    @consoleView.destroy()

  provideConsolePanel: ->
    @consoleManager

  # Service container: [weex, luaview]
  cosumeDebugService: (serviceProvider) ->
    console.log('Consume service provider:', serviceProvider)
    @consoleView.setDebugServiceProvider(serviceProvider);
