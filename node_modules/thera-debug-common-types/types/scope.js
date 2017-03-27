'use babel'
'use strict'

// https://chromedevtools.github.io/debugger-protocol-viewer/tot/Debugger/#type-Scope
//
// @type. string. Scope type. Allowed values: global, local, with, closure, catch, block, script, eval, module.
// @object. RemoteObject
//
class Scope {
  constructor (type, object) {
    this.type = type
    this.object = object
  }
}

// https://chromedevtools.github.io/debugger-protocol-viewer/tot/Runtime/#type-RemoteObject
// For primitives, display @value, for object display its @className
//
// @type: string. Object type. Allowed values: object, function, undefined, string, number, boolean, symbol.
// @className: string. Object class (constructor) name. Specified for object type values only.
// @value: any. Remote object value in case of primitive values or JSON values (if it was requested).
// @id. string. Unique object identifier (for non-primitive values).
// @properties. array[PropertyDescriptor]. properties of a given object
//
class RemoteObject {
  constructor (type, className, value, objectId) {
    this.type = type
    this.className = className
    this.value = value
    this.objectId = objectId
  }

  isPrimitive () {
    return this.type !== ObjectType.OBJECT && this.type !== ObjectType.FUNCTION
  }

  hasChildren () {
    return this.objectId && this.type !== ObjectType.SYMBOL
  }
}

// https://chromedevtools.github.io/debugger-protocol-viewer/tot/Runtime/#type-PropertyDescriptor
//
// @name: string. Property name or symbol description.
// @value: RemoteObject. The value associated with the property.
//
class PropertyDescriptor {
  constructor (name, value) {
    this.name = name
    this.value = value
  }
}

var ObjectType = Object.freeze({
  OBJECT: 'object',
  FUNCTION: 'function',
  UNDEFINED: 'undefined',
  STRING: 'string',
  NUMBER: 'number',
  BOOLEAN: 'boolean',
  SYMBOL: 'symbol'
})

module.exports = {
  Scope: Scope,
  RemoteObject: RemoteObject,
  PropertyDescriptor: PropertyDescriptor,
  ObjectType: ObjectType
}
