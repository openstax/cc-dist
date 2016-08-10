_ = require 'underscore'

React = require 'react'
BS = require 'react-bootstrap'

CourseGroupingLabel = require '../course-grouping-label'

CourseAddMenuMixin =
  contextTypes:
    router: React.PropTypes.func

  propTypes:
    dateFormat: React.PropTypes.string
    hasPeriods: React.PropTypes.bool.isRequired

  getInitialState: ->
    addDate: null

  getDefaultProps: ->
    dateFormat: 'YYYY-MM-DD'

  goToBuilder: (link) ->
    (clickEvent) =>
      clickEvent.preventDefault()
      @context.router.transitionTo(link.to, link.params, link.query)

  renderAddActions: ->
    {courseId} = @context.router.getCurrentParams()
    {dateFormat, hasPeriods} = @props

    if hasPeriods
      links = [
        {
          text: 'Add Reading'
          to: 'createReading'
          params:
            courseId: courseId
          type: 'reading'
          query:
            due_at: @state.addDate?.format(dateFormat)
        }, {
          text: 'Add Homework'
          to: 'createHomework'
          params:
            courseId: courseId
          type: 'homework'
          query:
            due_at: @state.addDate?.format(dateFormat)
        }, {
          text: 'Add External Assignment'
          to: 'createExternal'
          params:
            courseId: courseId
          type: 'external'
          query:
            due_at: @state.addDate?.format(dateFormat)
        }, {
          text: 'Add Event'
          to: 'createEvent'
          params:
            courseId: courseId
          type: 'event'
          query:
            due_at: @state.addDate?.format(dateFormat)
        }
      ]

    else
      linkText = [
        'Please add a '
        <CourseGroupingLabel lowercase courseId={@props.courseId}/>
        ' in '
        <br/>
        'Course Settings before'
        <br/>
        'adding assignments.'
      ]

      links = [{
        text: linkText
        to: 'courseSettings'
        params:
          courseId: courseId
        type: 'none'
      }]

    _.map(links, (link) =>
      href = @context.router.makeHref(link.to, link.params, link.query)
      <li
        key={link.type}
        data-assignment-type={link.type}
        ref="#{link.type}Link">
        <a href={href} onClick={@goToBuilder(link)} >
          {link.text}
        </a>
      </li>
    )

module.exports = CourseAddMenuMixin
