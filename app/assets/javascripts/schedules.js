$(document).ready(function() {
        if ($('.schedule_run_form_plus').size() > 0) {
                $(".schedule_run_form_plus").click(function() {
                        addScheduleRun();
                        return false;
                });
        };
        if ($('.schedule_run_form_remove').size() > 0) {
                $(".schedule_run_form_remove").click(function() {
                        removeScheduleRun();
                        return false;
                });
        };
        if ($('.schedule_run_form').size() > 1) {
                $('.schedule_run_form_remove').show();
        };
        if ($('input.timepicker').size() > 0) {
                setTimepickers();
        }
});

function setTimepickers() {
        $('input.timepicker').timepicker(
                        {
                                timeFormat: 'HH:mm',
                                interval: 1,
                                minTime: '00:00',
                                maxTime: '23:59',
                                startTime: '00:00',
                                dynamic: false,
                                dropdown: true,
                                scrollbar: true
                        });
}

function addScheduleRun() {
        var count = $('.schedule_run_form').size();
        var scheduleRun = $('.schedule_run_form:last').clone(true);

        $(scheduleRun).find('label').each(function() {
                var newLabel, oldLabel;
                oldLabel = $(this).attr('for');
                newLabel = oldLabel.replace(new RegExp(/_[0-9]+_/), "_" + count + "_");
                $(this).attr('for', newLabel);
        });

        $(scheduleRun).find('select, input').each(function() {
                var newId, oldId, newName, oldName;
                oldId = $(this).attr('id');
                newId = oldId.replace(new RegExp(/_[0-9]+_/), "_" + count + "_");
                $(this).attr('id', newId);

                oldName = $(this).attr('name');
                newName = oldName.replace(new RegExp(/[0-9]+/), "[" + count + "]");
                $(this).attr('name', newName);
        });
        $(scheduleRun).find('.timepicker').timepicker(
                        {
                                timeFormat: 'HH:mm',
                                interval: 1,
                                minTime: '00:00',
                                maxTime: '23:59',
                                defaultTime: '08:00',
                                startTime: '00:00',
                                dynamic: false,
                                dropdown: true,
                                scrollbar: true
                        });

        scheduleRun.insertAfter('.schedule_run_form:last');
        $('.schedule_run_form:last input').val('');
        if (count > 0) {
                $(".schedule_run_form_remove").show();
        };
        $('.destroyer:last').remove();
}

function removeScheduleRun() {
        var count = $('.schedule_run_form').size();
        if (count > 1) {
                var last_id = count - 1;
                $('<input>').attr({
                        type: 'hidden',
                        class: 'destroyer',
                        id: 'schedule_schedule_runs_attributes_' + last_id + '__destroy',
                        name: 'schedule[schedule_runs_attributes][' + last_id + '][_destroy]',
                        value: '1'
                }).appendTo('form');

                $('.schedule_run_form:last').remove();
                if ($('.schedule_run_form').size() == 1) {
                        $(".schedule_run_form_remove").hide();
                };
        }
        else {
                alert('nothing to remove');
        };
}
