moment        = require 'moment'
_ = require 'underscore'
axios         = require 'axios'
STORAGE_KEY = 'ox-notifications'

class Poller
  constructor: (@type, @notices, @interval) ->
    @localStorageKey = STORAGE_KEY + '-' + @type
    _.bindAll(@, 'poll', 'onReply', 'onError')

  setUrl: (@url) ->
    @startPolling() unless @polling

  startPolling: ->
    @polling = @notices.windowImpl.setInterval(@poll, @interval.asMilliseconds())
    @poll()

  poll: ->
    return if @notices.windowImpl.document.hidden is true
    axios.get(@url).then(@onReply).catch(@onError)

  onReply: ({data}) ->
    console.warn "base onReply method called unnecessarily"

  onError: (resp) ->
    console.warn resp

  getActiveNotifications: ->
    _.values @_activeNotices

  acknowledge: (notice) ->
    @_setObservedNoticeIds(
      @_getObservedNoticeIds().concat(notice.id)
    )
    delete @_activeNotices[notice.id]
    @notices.emit('change')

  _setObservedNoticeIds: (newIds) ->
    @notices.windowImpl.localStorage.setItem(@localStorageKey, JSON.stringify(newIds) )

  _getObservedNoticeIds: ->
    JSON.parse(@notices.windowImpl.localStorage.getItem(@localStorageKey) or '[]')

  _setActiveNotices: (newActiveNotices, currentIds) ->
    @_activeNotices = newActiveNotices
    @notices.emit('change')
    observedIds = @_getObservedNoticeIds()

    # Prune the list of observed notice ids so it doesn't continue to fill up with old notices
    outdatedIds = _.difference(observedIds, _.without(currentIds, _.keys(newActiveNotices)...))
    unless _.isEmpty(outdatedIds)
      @_setObservedNoticeIds( _.without(observedIds, outdatedIds...) )


class TutorNotices extends Poller
  constructor: (type, notices) ->
    super(type, notices, moment.duration(5, 'minutes'))
    @active = {}

  onReply: ({data}) ->
    observedIds = @_getObservedNoticeIds()
    newActiveNotices = {}
    currentIds = []
    for notice in data
      currentIds.push(notice.id)
      continue unless observedIds.indexOf(notice.id) is -1
      newActiveNotices[notice.id] = _.extend(notice, {type: @type})

    @_setActiveNotices(newActiveNotices, currentIds)


class AccountsNagger extends Poller
  constructor: (type, notices) -> super(type, notices, moment.duration(1, 'day'))

  onReply: ({data}) ->
    debugger


POLLER_TYPES =
  tutor: TutorNotices
  accounts: AccountsNagger

module.exports = (notices, type) ->
  new POLLER_TYPES[type](type, notices)
