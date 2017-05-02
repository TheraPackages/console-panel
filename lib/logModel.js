'use babel'
'use strict'

const {Disposable, Emitter} = require('atom')

module.exports = class LogModel {
  constructor () {
    this.elements = []
    this.disposable = new Disposable()
    this.emitter = new Emitter()
    this.containerHeight = 200
  }

  push (element) {
    this.elements.push(element)
    this.emitter.emit('change', this)
  }

  setContainerHeight (height) {
    this.containerHeight = height
    this.emitter.emit('change', this)
  }

  onChange (callback) {
    return this.emitter.on('change', callback)
  }
}
