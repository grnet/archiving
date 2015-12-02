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
      removeIncludedFileTextArea();
    });
  };
  if ($('.exclude_directions-remove-sign').size() > 0) {
    $(".exclude_directions-remove-sign").click(function() {
      removeExcludeDirectionsTextArea();
    });
  };
});

function addIncludedFileTextArea() {
  var textArrea = $('.include_files:last').clone(true).val("");
  $('.include_files-plus-sign:last').parent().hide();
  textArrea.insertAfter('.include_files:last');
  $('.include_files:last input').val("");
  $('.include_files-remove-sign:last').show();
}

function addExcludeDirectionsTextArea() {
  var textArrea = $('.exclude_directions:last').clone(true).val("");
  $('.exclude_directions-plus-sign:last').parent().hide();
  textArrea.insertAfter('.exclude_directions:last');
  $('.exclude_directions:last input').val("");
  $('.exclude_directions-remove-sign:last').show();
}

function removeIncludedFileTextArea() {
  $('.include_files:last').remove();
  $('.include_files-plus-sign:last').parent().show();
  if ($('.include_files').size() > 1) {
    $('.include_files-remove-sign:last').parent().show();
  };
}

function removeExcludeDirectionsTextArea() {
  $('.exclude_directions:last').remove();
  $('.exclude_directions-plus-sign:last').parent().show();
  if ($('.exclude_directions').size() > 1) {
    $('.exclude_directions-remove-sign:last').parent().show();
  };
}
