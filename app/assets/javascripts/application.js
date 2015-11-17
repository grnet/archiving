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
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require_tree .
//= require highcharts

$(document).ready(function() {
  $(".include_files-plus-sign").click(function() {
    addIncludedFileTextArea();
  });
  $(".exclude_directions-plus-sign").click(function() {
    addExcludeDirectionsTextArea();
  });
});

function addIncludedFileTextArea() {
  var textArrea = $('.include_files:last').clone(true).val("");
  $('.include_files-plus-sign:first').parent().remove();
  textArrea.insertAfter('.include_files:last');
  $('.include_files:last input').val("");
}

function addExcludeDirectionsTextArea() {
  var textArrea = $('.exclude_directions:last').clone(true).val("");
  $('.exclude_directions-plus-sign:first').parent().remove();
  textArrea.insertAfter('.exclude_directions:last');
  $('.exclude_directions:last input').val("");
}
