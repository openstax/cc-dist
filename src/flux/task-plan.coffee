# coffeelint: disable=no_empty_functions
_ = require 'underscore'
moment = require 'moment-timezone'
validator = require 'validator'

{CrudConfig, makeSimpleStore, extendConfig} = require './helpers'
{TocStore} = require './toc'
{TimeStore} = require './time'
{ExerciseStore} = require './exercise'
{PlanPublishActions, PlanPublishStore} = require './plan-publish'
{CourseActions, CourseStore} = require './course'
TaskHelpers = require '../helpers/task'
TimeHelper = require '../helpers/time'

TUTOR_SELECTIONS =
  default: 3
  max: 4
  min: 2

PLAN_TYPES =
  HOMEWORK: 'homework'
  READING: 'reading'
  EXTERNAL: 'external'
  EVENT: 'event'

sortTopics = (topics) ->
  _.sortBy(topics, (topicId) ->
    topic = TocStore.getSectionInfo(topicId)
    TaskHelpers.chapterSectionToNumber(topic.chapter_section)
  )

TaskPlanConfig =

  _stats: {}
  _asyncStatusStats: {}
  _server_copy: {}

  _loaded: (obj, planId) ->
    @_server_copy[planId] = obj
    obj

  # Somewhere, the local copy gets taken apart and rebuilt.
  # Keep a copy of what was served.
  _getOriginal: (planId) ->
    @_server_copy[planId]

  _getPlan: (planId) ->
    @_local[planId] ?= {}
    @_local[planId].settings ?= {}
    @_local[planId].settings.page_ids ?= []

    if @_local[planId]?.type is PLAN_TYPES.HOMEWORK or @_changed[planId]?.type is PLAN_TYPES.HOMEWORK
      @_local[planId].settings.exercise_ids ?= []
      @_local[planId].settings.exercises_count_dynamic ?= TUTOR_SELECTIONS.default

    #TODO take out once TaskPlan api is in place
    _.extend({}, @_local[planId], @_changed[planId])
    obj = _.extend({}, @_local[planId], @_changed[planId])

    # iReadings should not contain exercise_ids and will cause a silent 422 on publish
    if obj.type is PLAN_TYPES.READING
      delete obj.settings.exercise_ids
      delete obj.settings.exercises_count_dynamic

    obj

  FAILED: -> # used by API


  enableTasking: (id, target_id, opens_at, due_at) ->
    plan = @_getPlan(id)
    {tasking_plans} = plan
    unless @_findTasking(tasking_plans, target_id)
      tasking_plans = _.clone(tasking_plans)
      tasking_plans.push(
        {target_type: 'period', target_id, opens_at, due_at}
      )
      @_change(id, {tasking_plans})

  disableTasking: (id, target_id) ->
    plan = @_getPlan(id)
    {tasking_plans} = plan
    tasking_plans = _.reject tasking_plans, (plan) ->
      plan.target_id is target_id
    @_change(id, {tasking_plans})

  _removeEmptyTaskings: (tasking_plans) ->
    _.reject tasking_plans, (tasking) ->
      not (tasking.due_at and tasking.opens_at)

  # Returns copies of the given property names from settings
  # Copies are returned so that the store can be reset
  _getClonedSettings: (id, names...) ->
    plan = @_getPlan(id)
    settings = {}
    for name in names
      settings[name] = _.clone(plan.settings[name])
    return settings

  _changeSettings: (id, attributes) ->
    plan = @_getPlan(id)
    @_change(id, settings: _.extend({}, plan.settings, attributes))

  setPeriods: (id, periods) ->
    plan = @_getPlan(id)
    curTaskings = plan?.tasking_plans
    findTasking = @_findTasking

    tasking_plans = _.map periods, (period) ->
      tasking = findTasking(curTaskings, period.id)
      if not tasking
        tasking = target_id: period.id, target_type:'period'

      _.extend( _.pick(period, 'opens_at', 'due_at'),
        tasking
      )

    if not @exports.isNew(id)
      tasking_plans = @_removeEmptyTaskings(tasking_plans)

    @_change(id, {tasking_plans})

    @_setInitialPlan(id)

  replaceTaskings: (id, taskings) ->
    @_change(id, {tasking_plans: taskings})

  _findTasking: (tasking_plans, periodId) ->
    _.findWhere(tasking_plans, {target_id:periodId, target_type:'period'})

  _getPeriodDates: (id, period) ->
    throw new Error('BUG: Period is required arg') unless period
    plan = @_getPlan(id)
    {tasking_plans} = plan
    if tasking_plans
      @_findTasking(tasking_plans, period)
    else
      null

  # detects if all taskings are set to the same due_at/opens_at date
  # if so the date is returned, else null
  _getTaskingsCommonDate: (id, attr) ->
    {tasking_plans} = @_getPlan(id)
    # do all the tasking_plans have the same date?
    dates = _.compact _.uniq _.map(tasking_plans, (plan) ->
      date = TimeHelper.getMomentPreserveDate(plan[attr]).toDate() if plan[attr]?
      if isNaN(date?.getTime()) then 0 else date.getTime()
    )
    if dates.length is 1 then new Date(_.first(dates)) else null

  _getFirstTaskingByOpenDate: (id) ->
    {tasking_plans} = @_getPlan(id)
    sortedTaskings = _.sortBy(tasking_plans, 'opens_at')
    if sortedTaskings?.length
      sortedTaskings[0]

  _getFirstTaskingByDueDate: (id) ->
    tasking_plans = @_getPlan(id)?.tasking_plans or @_changed[id]?.tasking_plans or @_getOriginal(id)?.tasking_plans
    sortedTaskings = _.sortBy(tasking_plans, 'due_at')
    sortedTaskings[0] if sortedTaskings?.length

  updateTutorSelection: (id, direction) ->
    {exercises_count_dynamic} = @_getClonedSettings(id, 'exercises_count_dynamic')

    exercises_count_dynamic += direction

    exercises_count_dynamic = Math.min(TUTOR_SELECTIONS.max, exercises_count_dynamic)
    exercises_count_dynamic = Math.max(TUTOR_SELECTIONS.min, exercises_count_dynamic)
    @_changeSettings(id, {exercises_count_dynamic})

  updateTitle: (id, title) ->
    @_change(id, {title})

  updateDescription:(id, description) ->
    plan = @_getPlan(id)
    @_change(id, {description: description})

  # updates due_at/opens_at dates for taskings
  # If a periodId is given, only that tasking is updated.
  # If not, all taskings are set to that date
  updateDateAttribute: (id, attr, date, periodId) ->
    plan = @_getPlan(id)
    {tasking_plans} = plan
    tasking_plans ?= []
    tasking_plans = tasking_plans[..] # Clone it
    throw new Error('id is required') unless id
    throw new Error("#{attr} is required") unless date

    # use of moment(date).toDate() will make sure to convert
    # any type of date (string, js date, moment, etc) to date for
    # the BE to accept.
    if periodId
      tasking = @_findTasking(tasking_plans, periodId)
      tasking[attr] = TimeHelper.getMomentPreserveDate(date, [TimeStore.getFormat()]).format('YYYY-MM-DD')
    else
      for tasking in tasking_plans
        tasking[attr] = TimeHelper.getMomentPreserveDate(date, [TimeStore.getFormat()]).format('YYYY-MM-DD')

    @_change(id, {tasking_plans})

  clearDueAt: (id) ->
    plan = @_getPlan(id)
    {tasking_plans} = plan
    tasking_plans ?= []
    tasking_plans = tasking_plans[..] # Clone it

    for tasking in tasking_plans
      tasking['due_at'] = null

    @_change(id, {tasking_plans})

  updateOpensAt: (id, opens_at, periodId) ->
    @updateDateAttribute(id, 'opens_at', opens_at, periodId)

  updateDueAt: (id, due_at, periodId) ->
    @updateDateAttribute(id, 'due_at', due_at, periodId)

  updateUrl: (id, external_url) ->
    @_change(id, {settings: {external_url}})

  setEvent: (id) ->
    @_change(id, {settings: {}})

  sortTopics: (id) ->
    {page_ids} = @_getClonedSettings(id, 'page_ids')
    @_changeSettings(id, page_ids: sortTopics(page_ids))

  addTopic: (id, topicId) ->
    {page_ids} = @_getClonedSettings(id, 'page_ids')
    page_ids.push(topicId) unless page_ids.indexOf(topicId) >= 0
    @_changeSettings(id, {page_ids})

  removeTopic: (id, topicId) ->
    {page_ids, exercise_ids} = @_getClonedSettings(id, 'page_ids', 'exercise_ids')
    index = page_ids?.indexOf(topicId)
    page_ids?.splice(index, 1)
    exercise_ids = ExerciseStore.removeTopicExercises(exercise_ids, topicId)
    @_changeSettings(id, {page_ids, exercise_ids })

  updateTopics: (id, page_ids) ->
    @_changeSettings(id, {page_ids})

  addExercise: (id, exercise) ->
    {exercise_ids} = @_getClonedSettings(id, 'exercise_ids')
    unless exercise_ids.indexOf(exercise.id) >= 0
      exercise_ids.push(exercise.id)
    @_changeSettings(id, {exercise_ids})

  removeExercise: (id, exercise) ->
    {exercise_ids} = @_getClonedSettings(id, 'exercise_ids')
    index = exercise_ids?.indexOf(exercise.id)
    exercise_ids?.splice(index, 1)
    @_changeSettings(id, {exercise_ids})

  updateExercises: (id, exercise_ids) ->
    # NOTE.  The previous method set page_ids to null here, but I think that was a bug
    @_changeSettings(id, {exercise_ids})

  moveReading: (id, topicId, step) ->
    {page_ids} = @_getClonedSettings(id, 'page_ids')
    curIndex = page_ids?.indexOf(topicId)
    newIndex = curIndex + step

    if (newIndex < 0)
      newIndex = 0
    if not (newIndex < page_ids.length)
      newIndex = page_ids.length - 1

    page_ids[curIndex] = page_ids[newIndex]
    page_ids[newIndex] = topicId

    @_changeSettings(id, {page_ids})

  moveExercise: (id, exercise, step) ->
    {exercise_ids} = @_getClonedSettings(id, 'exercise_ids')
    curIndex = exercise_ids?.indexOf(exercise.id)
    newIndex = curIndex + step

    if (newIndex < 0)
      newIndex = 0
    if not (newIndex < exercise_ids.length)
      newIndex = exercise_ids.length - 1

    exercise_ids[curIndex] = exercise_ids[newIndex]
    exercise_ids[newIndex] = exercise.id

    @_changeSettings(id, {exercise_ids})

  _getStats: (id) ->
    @_stats[id]

  loadStats: (id) ->
    delete @_stats[id]
    @_asyncStatusStats[id] = 'loading'
    @emitChange()

  loadedStats: (obj, id) ->
    @_stats[id] = obj
    @_asyncStatusStats[id] = 'loaded'
    @emitChange()

  publish: (id) ->
    @emit('publishing', id)
    @_change(id, {is_publish_requested: true})

  _saved: (obj, id) ->
    if obj.is_publish_requested
      PlanPublishActions.queued(obj, id)
      @emit('publish-queued', id)
    obj

  resetPlan: (id) ->
    @_local[id] = _.clone(@_server_copy[id])
    @clearChanged(id)


  _isDeleteRequested: (id) ->
    deleteStates = [
      'deleting'
      'deleted'
    ]
    deleteStates.indexOf(@_asyncStatus[id]) > -1

  _setInitialPlan: (id) ->
    @_local[id].defaultPlan = _.extend({}, @exports.getChanged.call(@, id))

  exports:
    hasTopic: (id, topicId) ->
      plan = @_getPlan(id)
      plan?.settings.page_ids?.indexOf(topicId) >= 0

    getTopics: (id) ->
      plan = @_getPlan(id)
      plan?.settings.page_ids

    getEcosystemId: (id, courseId) ->
      plan = @_getPlan(id)
      plan.ecosystem_id or CourseStore.get(courseId)?.ecosystem_id

    hasExercise: (id, exerciseId) ->
      plan = @_getPlan(id)
      plan?.settings.exercise_ids?.indexOf(exerciseId) >= 0

    getExercises: (id) ->
      plan = @_getPlan(id)
      plan?.settings.exercise_ids

    getDescription: (id) ->
      plan = @_getPlan(id)
      plan?.description

    isHomework: (id) ->
      plan = @_getPlan(id)
      plan.type is PLAN_TYPES.HOMEWORK

    isValid: (id) ->
      plan = @_getPlan(id)

      isValidDates = ->
        flag = true
        # TODO: check that all periods are filled in
        _.each plan.tasking_plans, (tasking) ->
          unless tasking.due_at and tasking.opens_at
            flag = false
        flag and plan.tasking_plans?.length

      if (plan.type is 'reading')
        return plan.title and isValidDates() and plan.settings?.page_ids?.length > 0
      else if (plan.type is 'homework')
        return plan.title and isValidDates() and plan.settings?.exercise_ids?.length > 0
      else if (plan.type is 'external')
        return plan.title and isValidDates() and validator.isURL(plan.settings?.external_url)
      else if (plan.type is 'event')
        return plan.title and isValidDates()

    isPublished: (id) ->
      plan = @_getPlan(id)
      !!plan?.published_at

    isDeleteRequested: (id) -> @_isDeleteRequested(id)

    isOpened: (id) ->
      firstTasking = @_getFirstTaskingByOpenDate(id)
      new Date(firstTasking?.opens_at) <= TimeStore.getNow()

    isVisibleToStudents: (id) ->
      plan = @_getPlan(id)
      firstTasking = @_getFirstTaskingByOpenDate(id)
      (!!plan?.published_at or !!plan?.is_publish_requested) and new Date(firstTasking?.opens_at) <= TimeStore.getNow()

    getFirstDueDate: (id) ->
      due_at = @_getFirstTaskingByDueDate(id)?.due_at

    isEditable: (id) ->
      plan = @_getPlan(id)
      firstDueTasking = @_getFirstTaskingByDueDate(id)
      isPublishedOrPublishing = !!plan?.published_at or !!plan?.is_publish_requested
      isPastDue = new Date(firstDueTasking?.due_at) < TimeStore.getNow()
      # cannot be a publishing/published past due assignment, and
      # cannot be/being deleted
      not ((isPublishedOrPublishing and isPastDue) or @_isDeleteRequested(id))

    isPublishing: (id) ->
      @_changed[id]?.is_publish_requested or PlanPublishStore.isPublishing(id)

    canDecreaseTutorExercises: (id) ->
      plan = @_getPlan(id)
      plan.settings.exercises_count_dynamic > TUTOR_SELECTIONS.min

    canIncreaseTutorExercises: (id) ->
      plan = @_getPlan(id)
      plan.settings.exercises_count_dynamic < TUTOR_SELECTIONS.max

    getTutorSelections: (id) ->
      plan = @_getPlan(id)
      plan.settings.exercises_count_dynamic

    getStats: (id) ->
      @_getStats(id)

    getOpensAt: (id, periodId) ->
      if periodId?
        tasking = @_getPeriodDates(id, periodId)
        opensAt = TimeHelper.getMomentPreserveDate(tasking?.opens_at).toDate() if tasking?.opens_at?
      else
        # default opens_at to 1 day from now
        opensAt = @_getTaskingsCommonDate(id, 'opens_at')

      opensAt

    getDueAt: (id, periodId) ->
      if periodId?
        tasking = @_getPeriodDates(id, periodId)
        dueAt = TimeHelper.getMomentPreserveDate(tasking?.due_at).toDate() if tasking?.due_at?
      else
        dueAt = @_getTaskingsCommonDate(id, 'due_at')

      dueAt

    getMinDueAt: (id, periodId) ->
      opensAt = moment(@exports.getOpensAt.call(@, id, periodId))
      if opensAt.isBefore(TimeStore.getNow())
        opensAt = moment(TimeStore.getNow())
      opensAt.startOf('day').add(1, 'day').toDate()

    hasTasking: (id, periodId) ->
      plan = @_getPlan(id)
      {tasking_plans} = plan
      !!@_findTasking(tasking_plans, periodId)

    hasAnyTasking: (id) ->
      plan = @_getPlan(id)
      !!plan?.tasking_plans

    getEnabledTaskings: (id) ->
      plan = @_getPlan(id)
      plan?.tasking_plans

    isStatsLoading: (id) -> @_asyncStatusStats[id] is 'loading'

    isStatsLoaded: (id) -> !! @_stats[id]

    isStatsFailed: (id) -> !! @_stats[id]

    hasChanged: (id) -> not _.isEqual(@exports.getChanged.call(@, id), @_local[id].defaultPlan)

extendConfig(TaskPlanConfig, new CrudConfig())
{actions, store} = makeSimpleStore(TaskPlanConfig)
module.exports = {TaskPlanActions:actions, TaskPlanStore:store}
