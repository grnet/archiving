$(document).ready(function() {
        if ($('select#host_fqdn').size() > 0) {
                $('#host_fqdn').chosen();
        }
        if ($('select#host_email_recipients').size() > 0) {
                $('#host_email_recipients').chosen();
        }
});
