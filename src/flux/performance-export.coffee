{CrudConfig, makeSimpleStore, extendConfig} = require './helpers'
{JobActions, JobStore} = require './job'
_ = require 'underscore'
moment = require 'moment'

EXPORT_REQUESTING = 'export_requesting'
EXPORT_REQUESTED = 'export_queued'
EXPORTING = 'working'
EXPORT_QUEUED = 'queued'
EXPORTED = 'completed'
EXPORT_FAILED = 'failed'
EXPORT_KILLED = 'killed'

PerformanceExportConfig = {

  _job: {}

  _loaded: (obj, id) ->
    @emit('performanceExport.loaded', id)

  _updateExportStatusFor: (id) ->
    (jobData) =>
      exportData = _.clone(jobData)
      exportData.exportFor = id

      @_asyncStatus[id] = exportData.status
      @emit("performanceExport.#{exportData.status}", exportData)
      @emitChange()

  getJobIdFromJobUrl: (jobUrl) ->
    jobUrlSegments = jobUrl.split('/api/jobs/')
    jobId = jobUrlSegments[1] if jobUrlSegments[1]?

    jobId

  saveJob: (jobId, id) ->
    @_job[id] ?= []
    @_job[id].push(jobId)

  export: (id) ->
    @_asyncStatus[id] = EXPORT_REQUESTING
    @emitChange()

  exported: (obj, id) ->
    {job} = obj
    jobId = @getJobIdFromJobUrl(job)

    # export job has been queued
    @emit('performanceExport.queued', {jobId, id})
    @_asyncStatus[id] = EXPORT_REQUESTED
    @saveJob(jobId, id)

    # checks job until final status is reached
    checkJob = ->
      JobActions.load(jobId)
    JobActions.checkUntil(jobId, checkJob)

    # whenever this job status is updated, emit the status for performance export
    updateExportStatus = @_updateExportStatusFor(id)
    JobStore.on("job.#{jobId}.*", updateExportStatus)
    JobStore.off("job.#{jobId}.final", updateExportStatus)

  _getJobs: (id) ->
    _.clone(@_job[id])

  exports:
    isExporting: (id) ->
      exportingStates = [
        EXPORT_REQUESTING
        EXPORT_REQUESTED
        EXPORT_QUEUED
        EXPORTING
      ]

      exportingStates.indexOf(@_asyncStatus[id]) > -1

    isFailed: (id) ->
      failedStates = [
        EXPORT_FAILED
        EXPORT_KILLED
      ]

      failedStates.indexOf(@_asyncStatus[id]) > -1

    isExported: (id, jobId) ->
      jobId ?= _.last(@_getJobs(id))
      job = JobStore.get(jobId)
      {status} = job if job?
      status is EXPORTED

    getLatestExport: (id) ->
      perfExports = @_get(id)

      _.chain(perfExports)
        .sortBy((perfExport) ->
          perfExport.created_at
        ).last().value()


}

extendConfig(PerformanceExportConfig, new CrudConfig())
{actions, store} = makeSimpleStore(PerformanceExportConfig)
module.exports = {PerformanceExportActions:actions, PerformanceExportStore:store}
