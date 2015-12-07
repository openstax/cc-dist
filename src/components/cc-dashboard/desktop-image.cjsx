# coffeelint: disable=max_line_length
_ = require 'underscore'
React = require 'react'

{CourseStore} = require '../../flux/course'

DesktopImage = React.createClass

  propTypes:
    courseId: React.PropTypes.string

  render: ->
    course = CourseStore.get(@props.courseId)
    appearance = CourseStore.getAppearanceCode(@props.courseId)
    <svg className={"desktop #{appearance}"}
        width="100%" height="100%" viewBox="0 0 430 337" version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        style={fillRule:'evenodd', clipRule:'evenodd', strokeLinejoin: 'round', strokeMiterLimit: '1.41421'}>
      <path d="M430,302.705c0,9.546 -7.979,17.021 -17.43,17.43l0,9.296c0,4.266 -2.707,7.553 -6.973,7.553l-38.927,0c-4.266,0 -7.554,-3.287 -7.554,-7.553l0,-54.033c0,-4.265 0.384,-5.811 4.648,-5.811l44.736,0c4.266,0 4.066,1.546 4.066,5.811l0,9.297c9.455,0.406 17.434,8.463 17.434,18.01ZM412.57,291.084l0,22.659c6.011,-0.404 11.621,-4.928 11.621,-11.038c0,-6.111 -5.61,-11.217 -11.621,-11.621Z" style={fill:'#77af42' } />
      <path d="M365.63,275.762c0.963,0 1.744,0.781 1.744,1.743l0,54.032c0,0.963 -0.781,1.744 -1.744,1.744c-0.961,0 -1.741,-0.781 -1.741,-1.744l0,-54.032c0,-0.962 0.78,-1.743 1.741,-1.743Z" style={fill:'#8ec15a'}/>
      <path d="M392.992,253.168c3.451,5.524 -7.355,10.51 -7.355,10.51c0,0 5.658,-4.237 3.152,-10.51c-2.506,-6.273 3.018,-8.369 5.256,-8.935c0.303,-0.075 -4.899,2.778 -1.053,8.935ZM376.703,264.729c0,0 7.021,-4.771 4.203,-12.088c-2.818,-7.315 2.738,-9.853 5.255,-10.509c0.343,-0.09 -4.853,3.853 -0.524,11.035c3.881,6.446 -8.934,11.562 -8.934,11.562Z" style={fill:'#fff'} />
      <path d="M218.288,319.175c-22.113,-9.634 -18.777,-70.415 -18.777,-70.415l-25.819,0c0,0 2.645,60.781 -18.777,70.415l63.373,0Z" style={fill:'#9a9a9b'} />
      <path d="M100.929,318.646l171.344,0c2.592,0 4.693,2.103 4.693,4.693c0,2.593 -2.103,4.695 -4.693,4.695l-171.344,0c-2.592,0 -4.695,-2.104 -4.695,-4.695c0,-2.591 2.102,-4.693 4.695,-4.693Z" style={fill:'#9a9a9b'} />
      <rect x="173.691" y="248.76" width="25.819" height="11.736" style={fill:'#828282'} />
      <path d="M30.249,0l312.042,0c17.232,0 30.911,13.245 30.911,30.472l0,187.774c0,17.226 -13.28,30.514 -30.515,30.514l-312.174,0c-17.233,0 -30.513,-13.288 -30.513,-30.514l0,-187.774c0,-17.227 13.015,-30.472 30.249,-30.472Z" style={fill:'#9a9a9b'} />
      <path d="M14.083,40.082l0,25.127l267.028,0l40.149,-25.127l-307.177,0Z"
        className='banner' />
      <text className='course-name' x="55.571px" y="59px">
          {course.name}
      </text>
      <path d="M14.083,220.594c0,6.48 5.253,11.736 11.736,11.736l321.563,0c6.481,0 11.736,-5.256 11.736,-11.736l0,-155.385l-345.035,0l0,155.385Z" style={fill:'#fff' } />
      <path d="M347.382,16.389l-321.563,0c-6.483,0 -11.736,5.254 -11.736,11.736l0,11.957l345.036,0l0,-11.957c0,-6.482 -5.255,-11.736 -11.737,-11.736Z" style={fill:'#fff'} />
      <rect x="49.358" y="26.948" width="55.837" height="4" style={fill:'#e5e5e5'} />
      <rect x="58.82" y="79.32" width="55.837" height="4" style={fill:'#e5e5e5'} />
      <g>
        <path d="M40.848,26.259c-0.013,0.276 -0.247,0.49 -0.524,0.476l-11.68,-0.554c-0.276,-0.014 -0.488,-0.249 -0.475,-0.524l0.049,-1.038c0.012,-0.276 0.248,-0.489 0.523,-0.477l11.68,0.555c0.276,0.013 0.489,0.248 0.477,0.524l-0.05,1.038Z" style={fill:'#77af42'} />
        <path d="M37.01,30.054c0,0.167 -0.135,0.301 -0.3,0.301l-9.5,0c-0.165,0 -0.3,-0.134 -0.3,-0.301l0,-1.485c0,-0.166 0.135,-0.299 0.3,-0.299l9.5,0c0.166,0 0.3,0.134 0.3,0.299l0,1.485Z" style={fill:'#5f6163'} />
        <path d="M39.931,31.661c0.005,0.165 -0.12,0.304 -0.281,0.309l-10.717,0.335c-0.16,0.004 -0.294,-0.127 -0.299,-0.292l-0.028,-0.882c-0.005,-0.166 0.121,-0.304 0.282,-0.31l10.717,-0.334c0.16,-0.005 0.294,0.126 0.3,0.291l0.026,0.883Z" style={fill:'#f4d019'} />
        <path d="M38.491,33.454c0,0.166 -0.126,0.301 -0.282,0.301l-10.23,0c-0.156,0 -0.282,-0.135 -0.282,-0.301l0,-0.59c0,-0.166 0.126,-0.3 0.282,-0.3l10.23,0c0.156,0 0.282,0.134 0.282,0.3l0,0.59Z" style={fill:'#222f66'} />
        <path d="M38.755,27.553c0,0.122 -0.182,0.222 -0.406,0.222l-12.405,0c-0.223,0 -0.405,-0.1 -0.405,-0.222l0,-0.48c0,-0.122 0.182,-0.221 0.405,-0.221l12.406,0c0.224,0 0.406,0.099 0.406,0.221l-0.001,0.48Z" style={fill:'#f47641'} />
      </g>
      <path d="M213.116,103.129l7.405,0l8.75,-5.476l-170.451,0l0,15.299l146.007,0l8.289,-5.187l0,-4.636Z" style={fill:'#f1f1f1'} />
      <rect x="67.12" y="103.303" width="65.923" height="4" style={fill:'#e5e5e5'} />
      <path d="M159.285,138.335l0,-4.868l12.763,0l8.334,-5.216l-121.562,0l0,15.299l97.117,0l8.333,-5.215l-4.985,0Z" style={fill:'#f1f1f1'} />
      <rect x="67.12" y="133.9" width="77.094" height="4" style={fill:'#e5e5e5'}/>
      <rect x="159.285" y="103.129" width="38.312" height="4.868" style={fill:'#0dc0dc'} />
      <path d="M314.382,158.849l-182.89,0l-9.027,5.65l14.022,0l0,4l-20.413,0l-9.028,5.648l207.336,0l0,-15.298Z" style={fill:'#f5f5f5'} />
      <rect x="159.285" y="164.064" width="27.316" height="4.868" style={fill:'#77cfe0'} />
      <path d="M314.382,204.746l0,-15.299l-231.781,0l-9.027,5.65l59.469,0l0,4l-65.86,0l-8.363,5.234l0,0.415l255.562,0Z" style={fill:'#f5f5f5'} />
      <rect x="159.285" y="194.662" width="30.14" height="4.869" style={fill:'#77cfe0'} />
      <path d="M354.842,19.065l-7.291,4.563l1.139,0l0,1.535l-3.59,0l-3.683,2.304l7.271,0l0,1.536l-9.726,0l-17.702,11.079l37.858,0l0,-11.957c0.001,-3.648 -1.664,-6.908 -4.276,-9.06ZM348.689,32.842l-11.52,0l0,-1.536l11.52,0l0,1.536Z" style={fill:'#fff'} />
      <path className='banner-light' d="M281.111,65.209l78.008,0l0,-25.127l-37.859,0l-40.149,25.127Z" />
      <path d="M337.17,23.628l0,1.535l7.93,0l2.451,-1.535l-10.381,0Z" style={fill:'#9a9a9b'} />
      <path d="M348.689,23.628l-1.138,0l-2.451,1.535l3.589,0l0,-1.535Z" style={fill:'#b2b3b3'} />
      <path d="M337.17,27.467l0,1.536l1.793,0l2.454,-1.536l-4.247,0Z" style={fill:'#9a9a9b'} />
      <path d="M348.689,27.467l-7.272,0l-2.454,1.536l9.726,0l0,-1.536Z" style={fill:'#b2b3b3'} />
      <rect x="337.17" y="31.307" width="11.52" height="1.536" style={fill:'#b2b3b3'} />
      <path d="M314.382,97.653l-85.111,0l-8.75,5.476l22.735,0l0,4.869l-30.14,0l0,-0.233l-8.289,5.187l109.555,0l0,-15.299Z" style={fill:'#f5f5f5'} />
      <path d="M314.382,128.251l-134,0l-8.334,5.216l22.136,0l0,4.868l-29.914,0l-8.333,5.215l158.445,0l0,-15.299Z" style={fill:'#f5f5f5'} />
      <path d="M67.12,168.499l0,-2l0,-2l55.345,0l9.027,-5.65l-72.672,0l0,15.298l48.226,0l9.028,-5.648l-48.954,0Z" style={fill:'#f1f1f1'}/>
      <path d="M67.12,199.097l0,-2l0,-2l6.454,0l9.027,-5.65l-23.781,0l0,14.884l8.363,-5.234l-0.063,0Z" style={fill:'#f1f1f1'} />
      <path d="M67.12,195.097l0,4l0.063,0l6.391,-4l-6.454,0Z" style={fill:'#e5e5e5'}/>
      <path d="M73.574,195.097l-6.391,4l65.86,0l0,-4l-59.469,0Z" style={fill:'#eaeaea'}/>
      <path d="M67.12,164.499l0,4l48.954,0l6.391,-4l-55.345,0Z" style={fill:'#e5e5e5'} />
      <path d="M122.465,164.499l-6.391,4l20.413,0l0,-4l-14.022,0Z" style={fill:'#eaeaea'} />
      <path d="M159.285,138.335l4.985,0l7.778,-4.868l-12.763,0l0,4.868Z" style={fill:'#0dc0dc'} />
      <path d="M194.184,138.335l0,-4.868l-22.136,0l-7.778,4.868l29.914,0Z" style={fill:'#77cfe0'} />
      <path d="M213.116,107.765l7.405,-4.636l-7.405,0l0,4.636Z" style={fill:'#77af42'}/>
      <path d="M213.116,107.998l30.14,0l0,-4.869l-22.735,0l-7.405,4.636l0,0.233Z" style={fill:'#aecf8d'} />
      <rect x="213.116" y="133.467" width="38.312" height="4.868" style={fill:'#aecf8d'} />
      <rect x="213.116" y="164.064" width="27.315" height="4.868" style={fill:'#aecf8d'} />
      <rect x="213.116" y="194.662" width="25.14" height="4.869" style={fill:'#aecf8d'} />
      <rect x="266.579" y="103.129" width="36.632" height="4.868" style={fill:'#aecf8d'} />
      <rect x="266.579" y="133.467" width="31.46" height="4.868" style={fill:'#aecf8d'} />
      <rect x="266.579" y="164.064" width="25.14" height="4.868" style={fill:'#aecf8d'} />
      <rect x="266.579" y="194.662" width="19.155" height="4.869" style={fill:'#aecf8d'} />
    </svg>


module.exports = DesktopImage
