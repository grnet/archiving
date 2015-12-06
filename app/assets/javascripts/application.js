// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery.min
//= require jquery_ujs
//= require bootstrap.min
//= require_tree .
//= require highcharts
//= require jobs
//= require filesets

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
});

function addScheduleRun() {
        var count = $('.schedule_run_form').size();
        var scheduleRun = $('.schedule_run_form:last').clone();

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
