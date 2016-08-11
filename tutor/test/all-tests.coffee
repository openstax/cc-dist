# For some reason, this navbar component test will have warnings about setting
# state when component is unmounted if it's after some of the other specs.
# The tests still run and progress just fine despite the warnings, but for now,
# I'm leaving this test here.
# TODO figure out why.
#
# Components
require './components/course-listing.spec'
require './components/cc-dashboard/index.spec'
require './components/cc-dashboard/dashboard.spec'
require './components/navbar/index.spec'
require './components/navbar/account-link.spec'
require './components/navbar/user-actions-menu.spec'
require './components/navbar/center-controls.spec'
require './components/navbar/server-error-monitoring.spec'
require './components/task-plan/reading-plan.spec'
require './components/task-plan/builder/index.spec'
require './components/task-plan/homework-plan.spec'
require './components/task-plan/homework/exercise-controls.spec'
require './components/task-plan/footer.spec'
require './components/task.spec'
require './components/task-homework.spec'
require './components/task-homework-past-due.spec'
require './components/task-content.spec'
require './components/practice.spec'
require './components/course-calendar/plan.spec'
require './components/course-calendar.spec'
require './components/performance-forecast/index.spec'
require './components/performance-forecast/chapter.spec'
require './components/performance-forecast/section.spec'
require './components/performance-forecast/practice-button.spec'
require './components/performance-forecast/progress-bar.spec'
require './components/performance-forecast/weaker-panel.spec'
require './components/performance-forecast/weaker-sections.spec'
require './components/course-periods-nav.spec'
require './components/student-dashboard.spec'
require './components/student-dashboard/progress-guide.spec'
require './components/reference-book.spec'
require './components/reference-book/slide-out-menu-toggle.spec'
require './components/course-settings/roster.spec'
require './components/icon.spec'
require './components/tutor-input.spec'
require './components/tutor-dialog.spec'
require './components/unsaved-state.spec'
require './components/buttons/browse-the-book.spec'
require './components/book-content-mixin.spec'
require './components/scores/reading-cell.spec'
require './components/scores/homework-cell.spec'
require './components/name.spec'
require './components/scroll-to-link-mixin.spec'
require './components/media-preview.spec'
require './components/tutor-popover.spec'
require './components/course-grouping-label.spec'

# Flux your muscle
require './crud-store.spec'
require './task-store.spec'
require './task-step-store.spec'
require './loadable.spec'
require './teacher-task-plan-store.spec'
require './performance-forecast-store.spec'
require './step-panel-policy.spec'
require './time.spec'
require './current-user-store.spec'
require './course-listing-store.spec'
require './flux/plan-publish.spec'
require './flux/media.spec'
require './flux/exercise.spec'
require './flux/tasking.spec'

# Helpers
require './task-helpers.spec'
require './dom-helpers.spec'
require './helpers/string.spec'
require './helpers/period.spec'
require './helpers/job.spec'
require './helpers/time.spec'
require './helpers/analytics.spec'
