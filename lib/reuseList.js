'use strict'

const Infinite = require('react-infinite')
const React = require('react')

const defaultElementHeight = 19

module.exports =
class ReuseList extends React.Component {
  constructor (props) {
    super()
    this.model = props.model
    this.state = {
      elements: this.model.elements,
      containerHeight: this.model.containerHeight,
      elementHeight: props.elementHeight || defaultElementHeight
    }
  }

  componentDidMount () {
    const _this = this
    this.model.onChange(() => {
      _this.setState({
        elements: _this.model.elements,
        containerHeight: _this.model.containerHeight
      })
    })
  }

  render () {
    return React.createElement(Infinite, {
      className: "reuse-list", 
      elementHeight: this.state.elementHeight, 
      containerHeight: this.state.containerHeight, 
      displayBottomUpwards: true
      }, 
      this.state.elements
    )
  }
}