'use strict'
'use babel'

module.exports =
class Breakpoint {
  constructor (id, path, line, enable) {
    this.id = id
    this.path = path
    this.line = line
    this.enable = enable
  }
}
