'use babel'
'use strict'

const Infinite = require('react-infinite')
const React = require('react')

module.exports =
class ReuseList extends React.Component {
  constructor (props) {
    super()
    this.model = props.model
    this.state = {
      elements: this.model.elements,
      containerHeight: this.model.containerHeight
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
    return <Infinite
      className='reuse-list'
      elementHeight={20}
      containerHeight={this.state.containerHeight}>
      {this.state.elements}
    </Infinite>
  }
}
