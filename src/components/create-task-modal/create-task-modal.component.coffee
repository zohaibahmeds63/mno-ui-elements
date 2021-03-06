angular.module('mnoUiElements').component('mnoCreateTaskModal', {
  bindings: {
    resolve: '<'
    close: '&',
    dismiss: '&'
  },
  templateUrl: 'create-task-modal.html',
  controller: (MnoDateHelper)->
    ctrl = this

    ctrl.loading = false
    ctrl.$onInit = ->
      ctrl.task = {}
      ctrl.isDraft = !_.isEmpty(ctrl.resolve.draftTask)
      ctrl.datepicker = {
        options: { format: 'dd MMMM yyyy' }
        opened: false
      }
      ctrl.recipients = _.map(ctrl.resolve.recipients, (orgaRel) -> {id: orgaRel.id, name: ctrl.resolve.recipientFormatter(orgaRel)})
      if ctrl.isDraft
        draft = ctrl.resolve.draftTask
        recip = draft.task_recipients[0]
        ctrl.selectedRecipient = {id: recip.orga_relation_id, name: ctrl.resolve.recipientFormatter(recip)}
        ctrl.task = _.pick(draft, ['id', 'title', 'message'])
        ctrl.taskDueDate = moment.utc(draft.due_date).toDate() if draft.due_date?

    ctrl.ok = (status = 'sent')->
      ctrl.loading = true
      angular.merge(ctrl.task, status: status, orga_relation_id: ctrl.selectedRecipient.id)
      ctrl.task.due_date = MnoDateHelper.parseAsUTCDate(ctrl.taskDueDate) if _.isDate(ctrl.taskDueDate)
      cb = if ctrl.isDraft then ctrl.resolve.updateDraftCb else ctrl.resolve.createTaskCb
      cb(ctrl.task).then(
        ->
          ctrl.close()
      )

    ctrl.cancel = ->
      ctrl.dismiss()

    ctrl.openDatepicker = ->
      ctrl.datepicker.opened = true

    ctrl.isCreateTaskFormDisabled = ->
      ctrl.loading || !(ctrl.createTaskForm.$valid && (r = ctrl.selectedRecipient) && r.id?)

    ctrl
})
