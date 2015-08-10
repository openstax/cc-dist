_ = require 'underscore'

React = require 'react'
Router = require 'react-router'
camelCase = require 'camelcase'
BS = require 'react-bootstrap'

CoursePlanDetails = require './plan-details'
CoursePlanPublishingDetails = require './plan-publishing-details'

{PlanPublishStore, PlanPublishActions} = require '../../flux/plan-publish'

# TODO drag and drop, and resize behavior
CoursePlan = React.createClass
  displayName: 'CoursePlan'

  contextTypes:
    router: React.PropTypes.func

  propTypes:
    item: React.PropTypes.object.isRequired
    activeHeight: React.PropTypes.number.isRequired

  getDefaultProps: ->
    # CALENDAR_EVENT_LABEL_ACTIVE_STATIC_HEIGHT
    activeHeight: 35

  getInitialState: ->
    isViewingStats: false
    publishStatus: ''
    isPublishing: false
    isHovered: false

  # utility functions for functions called in lifecycle methods
  _doesPlanMatchesRoute: ->
    {planId} = @context.router.getCurrentParams()
    planId is @props.item.plan.id

  _isPlanNotMatchingRouteOpen: ->
    {planId} = @context.router.getCurrentParams()
    not @_doesPlanMatchesRoute() and @refs.details?

  _isPlanMatchRouteNotOpen: ->
    {planId} = @context.router.getCurrentParams()
    @_doesPlanMatchesRoute() and not @refs.details?

  _getExpectedRoute: (isViewingStats) ->
    closedRouteName = 'calendarByDate'
    openedRouteName = 'calendarViewPlanStats'

    if isViewingStats then openedRouteName else closedRouteName

  _getExpectedParams: (isViewingStats) ->
    planId = @props.item.plan.id

    params = @context.router.getCurrentParams()
    closedParams = _.omit(params, 'planId')
    openedParams = _.extend({}, params, {planId})

    if isViewingStats then openedParams else closedParams

  _updateRoute: (isViewingStats) ->
    expectedRoute = @_getExpectedRoute(isViewingStats)
    expectedParams = @_getExpectedParams(isViewingStats)
    currentParams = @context.router.getCurrentParams()

    @context.router.transitionTo(expectedRoute, expectedParams) unless _.isEqual(currentParams, expectedParams)

  # handles when route changes and modal show/hide needs to sync
  # i.e. when using back or forward on browser
  syncStatsWithState: ->
    if @_isPlanMatchRouteNotOpen()
      if @refs.trigger?
        triggerEl = @refs.trigger.getDOMNode()
        triggerEl.click()
      else
        @setIsViewingStats(false)
    else if @_isPlanNotMatchingRouteOpen()
      @refs.trigger?.hide()

  # handles when plan is clicked directly and viewing state and route both need to update
  setIsViewingStats: (isViewingStats) ->
    @_updateRoute(isViewingStats)
    @setState({isViewingStats})

  checkPublishingStatus: (published) ->
    if published.publishFor is @props.item.plan.id
      planStatus =
        publishStatus: published.status
        isPublishing: (['working', 'queued'].indexOf(published.status) > -1)

      @setState(planStatus)
      PlanPublishStore.off('planPublish.*', @checkPublishingStatus) if published.status is 'completed'

  subscribeToPublishing: (item) ->
    {plan} = item
    {id, isPublishing, publish_job_uuid} = plan

    if isPublishing and not PlanPublishStore.isPublishing(id)
      PlanPublishActions.published({id, publish_job_uuid}) if publish_job_uuid?

    PlanPublishStore.on('planPublish.*', @checkPublishingStatus) if isPublishing or PlanPublishStore.isPublishing(id)

  componentWillMount: ->
    @subscribeToPublishing(@props.item)

  componentWillReceiveProps: (nextProps) ->
    @subscribeToPublishing(nextProps.item)
    @closePlanOnModalHide()

  componentWillUnmount: ->
    PlanPublishStore.off('planPublish.*', @checkPublishingStatus)

  componentDidMount: ->
    @closePlanOnModalHide()
    @syncStatsWithState()

  componentDidUpdate: ->
    @syncStatsWithState()

  findPlanNodes: (planNode) ->
    container = @getDOMNode().parentElement.parentElement
    classes = '.' + Array.prototype.join.call(planNode.classList, '.')
    samePlans = Array.prototype.slice.call(container.querySelectorAll(classes))

  closePlanOnModalHide: ->
    if @refs.trigger?
      hide = @refs.trigger.hide
      syncClosePlan = @syncClosePlan

      # alias modal hide to also make plan look un-selected
      @refs.trigger.hide = ->
        hide()
        syncClosePlan()

  syncOpenPlan: ->
    @setIsViewingStats(true) unless @state.isViewingStats

  syncClosePlan: ->
    @setIsViewingStats(false) if @state.isViewingStats

  syncHover: ->
    @setState(isHovered: true) unless @state.isHovered

  removeHover: ->
    @setState(isHovered: false) if @state.isHovered

  renderLabel: (rangeDuration, durationLength, plan, index, offset) ->
    # Adjust width based on plan duration, helps with label centering on view...for the most part.
    # CALENDAR_EVENT_LABEL_DYNAMIC_WIDTH
    rangeLength = rangeDuration.length('days')
    planLabelStyle =
      width: rangeLength / durationLength * 100 + '%'

    # label should float right if the plan is cut off at the beginning of the week
    if offset < 0
      planLabelStyle.float = 'right'

    labelClass = 'continued' unless index is 0

    label = <label
      data-opens-at={plan.opensAt}
      style={planLabelStyle}
      ref='label'
      className={labelClass}>{plan.title}</label>

  renderOpenPlan: (planStyle, planClasses, label, index) ->
    {item, courseId} = @props
    {isPublishing} = @state
    {plan} = item

    if isPublishing and not plan.isPublished
      planModal = <CoursePlanPublishingDetails
        plan={plan}
        courseId={courseId}
        className={planClasses}
        ref='details'/>
    else
      planModal = <CoursePlanDetails
        plan={plan}
        courseId={courseId}
        className={planClasses}
        ref='details'/>

    planOnly = <div style={planStyle}
      className={planClasses}
      onMouseEnter={@syncHover}
      onMouseLeave={@removeHover}
      onClick={@syncOpenPlan}
      ref='plan'>
      {label}
    </div>

    if index is 0
      # only trigger modal if this is the first component representing the plan
      planInterface = <BS.ModalTrigger modal={planModal} ref='trigger'>
        {planOnly}
      </BS.ModalTrigger>
    else
      # otherwise, if this plan continues into the next week, don't add an additional modal
      planInterface = planOnly

    planInterface

  renderEditPlan: (planStyle, planClasses, label, index) ->
    {item, courseId} = @props
    {plan} = item

    linkTo = camelCase("edit-#{plan.type}")
    params = {id: plan.id, courseId}

    <div
      style={planStyle}
      className={planClasses}
      onMouseEnter={@syncHover}
      onMouseLeave={@removeHover}
      ref='plan'>
      <Router.Link
        to={linkTo}
        params={params}>
          {label}
      </Router.Link>
    </div>

  render: ->
    {item, courseId} = @props
    {publishStatus, isPublishing, isHovered, isViewingStats} = @state
    {plan, displays} = item

    plan.isFailed = publishStatus is 'failed'
    plan.isKilled = publishStatus is 'killed'

    planClasses = [
      'plan'
      "#{plan.type}"
      "course-plan-#{plan.id}"
    ]

    planClasses.push('is-published') if plan.isPublished or (publishStatus is 'completed')
    planClasses.push('is-failed') if plan.isFailed
    planClasses.push('is-killed') if plan.isKilled
    planClasses.push('is-publishing') if isPublishing
    planClasses.push('is-open') if plan.isOpen
    planClasses.push('is-trouble') if plan.isTrouble

    planClasses.push('active') if isHovered or isViewingStats

    planClasses.push('plan-label-long')

    planClasses = planClasses.join(' ')

    planDisplays = _.map(displays, (display) =>
      {duration, rangeDuration, offset, index, weekTopOffset, order} = display

      durationLength = duration.length('days')
      # Adjust width based on plan duration and left position based on offset of plan from start of week
      # CALENDAR_EVENT_DYNAMIC_WIDTH and CALENDAR_EVENT_DYNAMIC_POSITION
      # top is calculated by using:
      #   weekTopOffset -- the distance from the top of the calendar for plans in the same week
      #   order -- the order the plan should be from the bottom, is an int more than 1 when a plan needs to
      #       stack on top of other plans that overlap in duration.
      planStyle =
        width: durationLength * 100 / 7 + '%'
        left: offset * 100 / 7 + '%'
        top: (weekTopOffset + 4 - order * 3) + 'rem'

      label = @renderLabel(rangeDuration, durationLength, plan, index, offset)

      renderFn = 'renderEditPlan'
      renderFn = 'renderOpenPlan' if plan.isPublished or (isPublishing) or (publishStatus is 'completed')

      @[renderFn](planStyle, planClasses, label, index)
    )

    <div>
      {planDisplays}
    </div>


module.exports = CoursePlan
