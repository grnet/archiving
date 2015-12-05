$(document).ready(function() {
  $("#job_template_schedule_id").change(function() {
    showSchedule();
  });
  $("#job_template_fileset_id").change(function() {
    showFileset();
  });
});

function showSchedule() {
  var scheduleId = $("#job_template_schedule_id").val();
  $.ajax({
    url: "/hosts/" + hostId + "/schedules/" + scheduleId,
    data: jobIdParam
  });
}

function showFileset() {
  var filesetId = $("#job_template_fileset_id").val();
  $.ajax({
    url: "/hosts/" + hostId + "/filesets/" + filesetId
  });
}
