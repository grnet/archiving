$(document).ready(function() {
  if ($('#select-files').size() > 0) {
    $('#file-selector').hide();
    $('#reset-button').hide();
    $('#select-files').click(function() {
       $('#file-selector').show();
       $('#reset-button').show();
    });
  }
});

$(document).ready(function() {
  if ($('#file-submitter').size() > 0) {
    $("#file-tree").on("select_node.jstree",
      function(evt, data) {
        if (data.instance.is_leaf(data.node)) {
          add_input(data.node.id, $('#file-tree').jstree(true).get_path(data.node, '/'));
        }
      });
    $("#file-tree").on("deselect_node.jstree",
      function(evt, data) {
        remove_input(data.node.id);
      });
  }
  if ($('#invitation_user_id').size() > 0) {
    $('#invitation_user_id').chosen();
  }
});

function add_input(id, name) {
  $('#file-submitter').
    append('<input type="hidden" name="files[]" multiple="multiple" value="' + id + '" id="js-file-id-' + id + '" class="js-file-input"/>');
  $('#restore_data_files').
    append('<li id="restore_data_files_' + id + '">' + name.replace('//','/') + '</li>');
  if ($('.js-file-input').size() > 0 && $('#file-submitter > input[type="submit"]').attr('disabled') == 'disabled') {
    $('#file-submitter > input[type="submit"]').attr('disabled', false);
  }
}

function remove_input(id) {
  $('#js-file-id-' + id).remove();
  $('#restore_data_files_' + id).remove();
  if ($('.js-file-input').size() == 0) {
    $('#file-submitter > input[type="submit"]').attr('disabled', true);
  }
}
