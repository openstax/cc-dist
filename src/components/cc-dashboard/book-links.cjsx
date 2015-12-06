React = require 'react'
BS = require 'react-bootstrap'

{CCDashboardStore} = require '../../flux/cc-dashboard'

BookLinks = React.createClass
  goToPdf: ->
    course = CourseStore.get(@props.courseId)
    window.open(course.book_pdf_url, 'cc-pdf-link')

  goToWebview: ->
    course = CourseStore.get(@props.courseId)
    window.open(course.webview_url, 'cc-webview-link')

  render: ->
    <div className='book-links'>
      <BS.Button bsStyle='link' className='link' onClick={@goToPdf}>
        Book PDF
      </BS.Button>
      <BS.Button bsStyle='link' className='link' onClick={@goToWebview}>
        Webview <i className='fa fa-external-link' />
      </BS.Button>
    </div>



module.exports = BookLinks
