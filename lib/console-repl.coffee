
module.exports =
  ReplHistory: class ReplHistory

    constructor: () ->
      @history = []
      @cursor = -1

    add: (repl) ->
      if repl and repl.trim()
        @history.push(repl)
      @cursor = @history.length

    prev: ->
      @cursor = @cursor - 1 if @cursor > 0
      return @history[@cursor] || ''

    next: ->
      @cursor = @cursor + 1 if @cursor < @history.length
      return @history[@cursor] || ''
