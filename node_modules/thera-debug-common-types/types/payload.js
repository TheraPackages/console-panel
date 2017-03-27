'use strict'
'use babel'

class Payload {
  constructor (command) {
    this.command = command
  }
}

class CallStackPayload extends Payload {
  constructor (callFrames, reason, hitBreakpoints, currentCallFrameId) {
    super(COMMAND.UPDATE_CALLSTACK)
    this.callFrames = callFrames
    this.reason = reason
    this.hitBreakpoints = hitBreakpoints
    this.currentCallFrameId = currentCallFrameId
  }
}

class CallFramePayload extends Payload {
  constructor (id, functionName, scopeChain, location, thisObject) {
    super(COMMAND.CALLFRAME)
    this.id = id
    this.functionName = functionName
    this.scopeChain = scopeChain
    this.location = location
    this.thisObject = thisObject
  }
}

class ResolveBreakpointPayload extends Payload {
  constructor (breakpoint) {
    super(COMMAND.RESOLVE_BREAKPOINT)
    this.breakpoint = breakpoint
  }
}

class RemoveBreakpointPayload extends Payload {
  constructor (path, line) {
    super(COMMAND.REMOVE_BREAKPOINT)
    this.path = path
    this.line = line
  }
}

class SourceCodePayload extends Payload {
  constructor (sourceURL, localURL, isRemote, content) {
    super(COMMAND.ADD_SOURCECODE)
    this.sourceURL = sourceURL
    this.localURL = localURL
    this.isRemote = isRemote
    this.content = content
  }
}

class ResumedPayload extends Payload {
  constructor () {
    super(COMMAND.DEBUGGER_RESUMED)
    // Empty Payload
  }
}

var COMMAND = Object.freeze({
  UPDATE_CALLSTACK: 'UPDATE_CALLSTACK',
  RESOLVE_BREAKPOINT: 'RESOLVE_BREAKPOINT',
  REMOVE_BREAKPOINT: 'REMOVE_BREAKPOINT',
  CALLFRAME: 'CALLFRAME',
  ADD_SOURCECODE: 'ADD_SOURCECODE',
  DEBUGGER_RESUMED: 'DEBUGGER_RESUMED'
})

module.exports = {
  COMMAND: COMMAND,
  CallStackPayload: CallStackPayload,
  ResolveBreakpointPayload: ResolveBreakpointPayload,
  RemoveBreakpointPayload: RemoveBreakpointPayload,
  CallFramePayload: CallFramePayload,
  SourceCodePayload: SourceCodePayload,
  ResumedPayload: ResumedPayload
}
