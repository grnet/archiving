$(document).ready(function() {
  if ($('.include_files-plus-sign').size() > 0) {
    $(".include_files-plus-sign").click(function() {
      addIncludedFileTextArea();
    });
  };
  if ($('.exclude_directions-plus-sign').size() > 0) {
    $(".exclude_directions-plus-sign").click(function() {
      addExcludeDirectionsTextArea();
    });
  };
  if ($('.include_files-remove-sign').size() > 0) {
    $(".include_files-remove-sign").click(function() {
      removeIncludedFileTextArea($(this));
    });
  };
  if ($('.exclude_directions-remove-sign').size() > 0) {
    $(".exclude_directions-remove-sign").click(function() {
      removeExcludeDirectionsTextArea($(this));
    });
  };
});

function addIncludedFileTextArea() {
  var textArrea = $('.templates .include_files:last').clone(true).val("");
  textArrea.insertBefore('.here-included');
  if ($('.include_files').size() > 1) {
    $('.include_files-remove-sign').show();
  };
}

function addExcludeDirectionsTextArea() {
  var textArrea = $('.templates .exclude_directions:last').clone(true).val("");
  textArrea.insertAfter('.here-excluded');
  $('.exclude_directions:last input').val("");
}

function removeIncludedFileTextArea(element) {
  element.closest('div.include_files').remove();
  if ($('.include_files').size() <= 1) {
    $('.include_files-remove-sign').hide();
  };
}

function removeExcludeDirectionsTextArea(element) {
  element.closest('div.exclude_directions').remove()
}
