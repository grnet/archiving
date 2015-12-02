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
  $(".schedule_run_form_plus").click(function() {
    addScheduleRun();
  });
  $(".schedule_run_form_remove").click(function() {
    removeScheduleRun();
  });
});

function addScheduleRun() {
  var scheduleRun = $('.schedule_run_form:last').clone();
  scheduleRun.insertAfter('.schedule_run_form:last');
  $('.schedule_run_form:last input').val('');
  if ($('.schedule_run_form').size() > 1) {
    $(".schedule_run_form_remove").show();
  };
}

function removeScheduleRun() {
  if ($('.schedule_run_form').size() > 1) {
    $('.schedule_run_form:last').remove();
    if ($('.schedule_run_form').size() == 1) {
      $(".schedule_run_form_remove").hide();
    };
  }
  else {
    alert('nothing to remove');
  };
}
