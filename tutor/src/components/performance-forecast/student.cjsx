React = require 'react'
BS = require 'react-bootstrap'
Router = require 'react-router'
_ = require 'underscore'

PerformanceForecast = require '../../flux/performance-forecast'

Guide = require './guide'
ColorKey    = require './color-key'
InfoLink    = require './info-link'

module.exports = React.createClass
  displayName: 'PerformanceForecastStudentDisplay'
  contextTypes:
    router: React.PropTypes.func

  propTypes:
    courseId:  React.PropTypes.string.isRequired

  returnToDashboard: ->
    @context.router.transitionTo('viewStudentDashboard', {courseId: @props.courseId})

  renderHeading: ->
    <div className='guide-heading'>
      <div className='guide-group-title'>
        Performance Forecast <InfoLink type='student'/>
      </div>

      <div className='info'>
        <div className='guide-group-key'>
          <div className='guide-practice-message'>
            Click on the bar to practice the topic
          </div>
          <ColorKey />
        </div>

        <Router.Link to='viewStudentDashboard' className='btn btn-default back'
        params={courseId: @props.courseId}>
        Return to Dashboard
        </Router.Link>

      </div>
    </div>

  renderEmptyMessage: ->
    <div className="no-data-message">You have not worked any questions yet.</div>

  renderWeakerExplanation: ->
    <div className='explanation'>
      <p>Tutor shows your weakest topics so you can practice to improve.</p>
      <p>Try to get all of your topics to green!</p>
    </div>

  render: ->
    {courseId} = @props
    <BS.Panel className='performance-forecast student'>
      <Guide
        canPractice={true}
        courseId={courseId}
        weakerTitle="My Weaker Areas"
        weakerExplanation={@renderWeakerExplanation()}
        weakerEmptyMessage="You haven't worked enough problems for Tutor to predict your weakest topics."
        heading={@renderHeading()}
        sampleSizeThreshold={3}
        emptyMessage={@renderEmptyMessage()}
        onReturn={@returnToDashboard}
        allSections={PerformanceForecast.Student.store.getAllSections(courseId)}
        chapters={PerformanceForecast.Student.store.get(courseId).children}
      />
    </BS.Panel>
