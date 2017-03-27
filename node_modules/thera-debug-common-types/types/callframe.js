'use babel'
'use strict'

module.exports =
class CallFrame {
  constructor (callFrameId, functionName, location, fileURL) {
    this.callFrameId = callFrameId
    this.functionName = functionName
    this.location = location
    this.fileURL = fileURL
  }
}
