React = require 'react'
_ = require 'underscore'

classnames = require 'classnames'

keymaster = require 'keymaster'
keysHelper = require '../helpers/keys'

KEYS =
  'multiple-choice-numbers': _.range(1, 10) # 1 - 9

# a - i
KEYS['multiple-choice-alpha'] = _.map(KEYS['multiple-choice-numbers'], _.partial(keysHelper.getCharFromNumKey, _, null))

KEYS['multiple-choice'] = _.zip(KEYS['multiple-choice-numbers'], KEYS['multiple-choice-alpha'])

KEYSETS_PROPS = _.keys(KEYS)
KEYSETS_PROPS.push(null) # keySet could be null for disabling keyControling

ArbitraryHtmlAndMath = require './html'

idCounter = 0

isAnswerCorrect = (answer, correctAnswerId) ->
  isCorrect = answer.id is correctAnswerId
  isCorrect = (answer.correctness is '1.0') if answer.correctness?

  isCorrect

isAnswerChecked = (answer, chosenAnswer) ->
  isChecked = answer.id in chosenAnswer

Answer = React.createClass
  displayName: 'Answer'
  propTypes:
    answer: React.PropTypes.shape(
      id: React.PropTypes.oneOfType([
        React.PropTypes.string
        React.PropTypes.number
      ]).isRequired
      content_html: React.PropTypes.string.isRequired
      correctness: React.PropTypes.string
      selected_count: React.PropTypes.number
    ).isRequired

    iter: React.PropTypes.number.isRequired
    qid: React.PropTypes.oneOfType([
      React.PropTypes.string
      React.PropTypes.number
    ]).isRequired
    type: React.PropTypes.string.isRequired
    hasCorrectAnswer: React.PropTypes.bool.isRequired
    onChangeAnswer: React.PropTypes.func.isRequired

    disabled: React.PropTypes.bool
    chosenAnswer: React.PropTypes.array
    correctAnswerId: React.PropTypes.string
    answered_count: React.PropTypes.number
    show_all_feedback: React.PropTypes.bool
    keyControl: React.PropTypes.oneOfType([
      React.PropTypes.string
      React.PropTypes.number
      React.PropTypes.array
    ])

  getDefaultProps: ->
    disabled: false
    show_all_feedback: false

  componentWillMount: ->
    @setUpKeys() if @shouldKey()

  componentWillUnmount: ->
    {keyControl} = @props
    keysHelper.off(keyControl, 'multiple-choice') if keyControl?

  componentDidUpdate: (prevProps) ->
    {keyControl} = @props

    if @shouldKey(prevProps) and not @shouldKey()
      keysHelper.off(prevProps.keyControl, 'multiple-choice')

    if @shouldKey() and prevProps.keyControl isnt keyControl
      @setUpKeys()

  shouldKey: (props) ->
    props ?= @props
    {keyControl, disabled} = props

    keyControl? and not disabled

  setUpKeys: ->
    {answer, onChangeAnswer, keyControl} = @props

    keyInAnswer = _.partial onChangeAnswer, answer
    keysHelper.on keyControl, 'multiple-choice', keyInAnswer
    keymaster.setScope('multiple-choice')

  contextTypes:
    processHtmlAndMath: React.PropTypes.func

  render: ->
    {answer, iter, qid, type, correctAnswerId, answered_count, hasCorrectAnswer, chosenAnswer, onChangeAnswer, disabled} = @props
    qid ?= "auto-#{idCounter++}"

    isChecked = isAnswerChecked(answer, chosenAnswer)
    isCorrect = isAnswerCorrect(answer, correctAnswerId)

    classes = classnames 'answers-answer',
      'answer-checked': isChecked
      'answer-correct': isCorrect

    unless (hasCorrectAnswer or type is 'teacher-review')
      radioBox = <input
        type='radio'
        className='answer-input-box'
        checked={isChecked}
        id="#{qid}-option-#{iter}"
        name="#{qid}-options"
        onChange={_.partial(onChangeAnswer, answer)}
        disabled={disabled}
      />

    if type is 'teacher-review'
      percent = Math.round(answer.selected_count / answered_count * 100) or 0
      selectedCount = <div
        className='selected-count'
        data-count="#{answer.selected_count}"
        data-percent="#{percent}">
      </div>

    if @props.show_all_feedback and answer.feedback_html
      feedback = <Feedback key='question-mc-feedback'>{answer.feedback_html}</Feedback>

    htmlAndMathProps = _.pick(@context, 'processHtmlAndMath')

    <div>
      <div className={classes}>
        {selectedCount}
        {radioBox}
        <label
          htmlFor="#{qid}-option-#{iter}"
          className='answer-label'>
          <div className='answer-letter' />
          <ArbitraryHtmlAndMath
            {...htmlAndMathProps}
            className='answer-content'
            html={answer.content_html} />
        </label>
      </div>
      {feedback}
    </div>

Feedback = React.createClass
  displayName: 'Feedback'
  propTypes:
    children: React.PropTypes.string.isRequired
    position: React.PropTypes.oneOf(['top', 'bottom', 'left', 'right'])
  getDefaultProps: ->
    position: 'bottom'
  contextTypes:
    processHtmlAndMath: React.PropTypes.func
  render: ->
    wrapperClasses = classnames 'question-feedback', @props.position
    htmlAndMathProps = _.pick(@context, 'processHtmlAndMath')

    <div className={wrapperClasses}>
      <div className='arrow'/>
      <ArbitraryHtmlAndMath
        {...htmlAndMathProps}
        className='question-feedback-content has-html'
        html={@props.children}
        block={true}/>
    </div>

module.exports = React.createClass
  displayName: 'Question'
  propTypes:
    model: React.PropTypes.object.isRequired
    type: React.PropTypes.string.isRequired
    answer_id: React.PropTypes.string
    correct_answer_id: React.PropTypes.string
    content_uid: React.PropTypes.string
    feedback_html: React.PropTypes.string
    answered_count: React.PropTypes.number
    show_all_feedback: React.PropTypes.bool
    onChange: React.PropTypes.func
    onChangeAttempt: React.PropTypes.func
    keySet: React.PropTypes.oneOf(KEYSETS_PROPS)

  getInitialState: ->
    answer: null

  getDefaultProps: ->
    type: 'student'
    show_all_feedback: false
    keySet: 'multiple-choice'

  childContextTypes:
    processHtmlAndMath: React.PropTypes.func

  getChildContext: ->
    processHtmlAndMath: @props.processHtmlAndMath

  onChangeAnswer: (answer, changeEvent) ->
    if @props.onChange?
      @setState({answer_id:answer.id})
      @props.onChange(answer)
    else
      changeEvent.preventDefault()
      @props.onChangeAttempt?(answer)

  render: ->
    {type, answered_count, choicesEnabled, correct_answer_id, keySet} = @props
    chosenAnswer = [@props.answer_id, @state.answer_id]
    checkedAnswerIndex = null

    html = @props.model.stem_html
    qid = @props.model.id or "auto-#{idCounter++}"
    hasCorrectAnswer = !! correct_answer_id

    if @props.feedback_html
      feedback = <Feedback key='question-mc-feedback'>{@props.feedback_html}</Feedback>

    questionAnswerProps =
      qid: @props.model.id,
      correctAnswerId: correct_answer_id
      hasCorrectAnswer: hasCorrectAnswer
      chosenAnswer: chosenAnswer
      onChangeAnswer: @onChangeAnswer
      type: type
      answered_count: answered_count
      disabled: not choicesEnabled
      show_all_feedback: @props.show_all_feedback

    answers = _.chain(@props.model.answers)
      .sortBy (answer) ->
        parseInt(answer.id)
      .map (answer, i) ->
        additionalProps = {answer, iter: i, key: "#{questionAnswerProps.qid}-option-#{i}", keyControl: KEYS[keySet]?[i]}
        answerProps = _.extend({}, additionalProps, questionAnswerProps)
        checkedAnswerIndex = i if isAnswerChecked(answer, chosenAnswer)

        <Answer {...answerProps}/>
      .value()

    answers.splice(checkedAnswerIndex + 1, 0, feedback) if feedback? and checkedAnswerIndex?
    htmlAndMathProps = _.pick(@props, 'processHtmlAndMath')

    classes = classnames 'openstax-question',
      'has-correct-answer': hasCorrectAnswer

    <div className={classes}>
      <ArbitraryHtmlAndMath
        {...htmlAndMathProps}
        className='question-stem'
        block={true}
        html={html} />
      {@props.children}
      <div className='answers-table'>
        {answers}
      </div>
      <div className="exercise-uid">{@props.exercise_uid}</div>
    </div>
