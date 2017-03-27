'use babel'
'use strict'

const {Emitter} = require('atom')

// Base class of debug service
// Override this class and implement vm specific debug protocol
// based on chrome dev tool debugger protocol
// https://chromedevtools.github.io/debugger-protocol-viewer/tot/Debugger/

class DebugService {
  // @name matches name in project config file
  // debug frontend will choose corresponding service base on name
  constructor () {
    this.name = undefined
    this.emitter = new Emitter()
  }

  // @file actual file of the breakpoint
  // @line actual line the breakpoint resolves into
  setBreakpoint (file, line) {
    console.log(`set breakpoint at ${file}, ${line}`)
  }

  removeBreakpoint (file, line) {
    console.log(`removeBreakpoint`)
  }

  // debug control
  startDebug (entranceURL) {
    console.log(`startDebug on url ${entranceURL}`)
  }

  stopDebug () {
    console.log(`stopDebug`)
  }

  stepOver () {
    console.log(`stepOver`)
  }

  stepInto () {
    console.log(`stepInto`)
  }

  stepOut () {
    console.log(`stepOut`)
  }

  pause () {
    console.log(`pause`)
  }

  resume () {
    console.log(`resume`)
  }

  //
  // getCallStack () {
  //   console.log(`getCallStack`)
  // }

  selectCallFrame (callFrameId) {

  }

  // events
  // @hander has parameter of a payload.
  onPaused (handler) {
    return this.emitter.on('paused', handler)
  }

  // payload format in '../types/payload.js'
  paused (payload) {
    this.emitter.emit('paused', payload)
  }

  onNotify (handler) {
    return this.onPaused(handler)
  }

  notify (payload) {
    this.paused(payload)
  }

  destroy () {
    this.emitter.dispose()
  }

  // https://chromedevtools.github.io/debugger-protocol-viewer/tot/Runtime/#method-getProperties
  // @param objectId Identifier of the object to return properties for.
  // @return array [ PropertyDescriptor ]
  getProperties (objectId) {
    return undefined
  }
}

module.exports = DebugService
