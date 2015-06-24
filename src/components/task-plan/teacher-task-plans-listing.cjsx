React = require 'react'
moment = require 'moment'
BS = require 'react-bootstrap'
Router = require 'react-router'

LoadableItem = require '../loadable-item'
{TeacherTaskPlanStore, TeacherTaskPlanActions} = require '../../flux/teacher-task-plan'
{CourseStore} = require '../../flux/course'
{TimeStore} = require '../../flux/time'

DATE_FORMAT = 'YYYY-MM-DD'

CourseCalendar = require '../course-calendar'

TeacherTaskPlans = React.createClass

  contextTypes:
    router: React.PropTypes.func

  onEditPlan: ->
    {courseId, plan} = @props
    {id, type} = plan
    if type is 'reading'
      @context.router.transitionTo('editReading', {courseId, id})
    else if type is 'homework'
      @context.router.transitionTo('editHomework', {courseId, id})

  onViewStats: ->
    {courseId, plan} = @props
    {id} = @props.plan
    @context.router.transitionTo('viewStats', {courseId, id})

  render: ->
    {plan} = @props
    start  = moment(plan.opens_at)
    ending = moment(plan.due_at)
    duration = moment.duration( ending.diff(start) ).humanize()

    <div className='-list-item'>
      <BS.ListGroupItem header={plan.title} onClick={@onEditPlan}>
        {start.fromNow()} ({duration})
      </BS.ListGroupItem>
      <BS.Button
        bsStyle='link'
        className='-tasks-list-stats-button'
        onClick={@onViewStats}>View Stats</BS.Button>
    </div>


TeacherTaskPlanListing = React.createClass

  displayName: 'TeacherTaskPlanListing'

  contextTypes:
    router: React.PropTypes.func

  propTypes:
    dateFormat: React.PropTypes.string

  getDefaultProps: ->
    dateFormat: DATE_FORMAT

  componentDidMount: ->
    {courseId} = @context.router.getCurrentParams()

    # Bypass loading if plan is already loaded, as is the case in testing.
    if not TeacherTaskPlanStore.isLoaded(courseId)
      TeacherTaskPlanActions.load( courseId )

  componentWillMount: -> TeacherTaskPlanStore.addChangeListener(@update)
  componentWillUnmount: -> TeacherTaskPlanStore.removeChangeListener(@update)

  update: -> @setState({})

  statics:
    willTransitionTo: (transition, params, query, callback) ->
      {date} = params
      if date? and moment(date, DATE_FORMAT).isValid()
        callback()
      else
        date = moment(TimeStore.getNow())
        params.date = date.format(DATE_FORMAT)
        transition.redirect('calendarByDate', params)
        callback()

  getDateFromParams: ->
    {date} = @context.router.getCurrentParams()
    if date?
      date = moment(date, @props.dateFormat)
    date

  render: ->
    {courseId} = @context.router.getCurrentParams()
    date = @getDateFromParams()

    plansList = TeacherTaskPlanStore.getCoursePlans(courseId)

    <div className="tutor-booksplash-background"
      data-title={CourseStore.getShortName(courseId)}
      data-category={CourseStore.getCategory(courseId)}>

      <BS.Panel
          className='list-courses'
          bsStyle='primary'>

        <LoadableItem
          store={TeacherTaskPlanStore}
          actions={TeacherTaskPlanActions}
          id={courseId}
          renderItem={-> <CourseCalendar plansList={plansList} courseId={courseId} date={date}/>}
          renderLoading={-> <CourseCalendar className='calendar-loading'/>}
          update={@update}
        />

      </BS.Panel>
    </div>

module.exports = TeacherTaskPlanListing
