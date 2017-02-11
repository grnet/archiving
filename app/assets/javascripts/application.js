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
//= require jquery.timepicker.min
//= require jquery-ui.min
//= require bootstrap.min
//= require jstree
//= require chosen.jquery.min
//= require jquery.dataTables.min
//= require dataTables.bootstrap.min
//= require_tree .
//= require highcharts
//= require jobs
//= require filesets
//= require clients

$(document).ready(function() {
        if ($('table#admin_clients').size() > 0) {
                $('table#admin_clients').DataTable({
                        paging: false,
                        order: [],
                        columnDefs: [
                        {
                                targets: 'neither-search-nor-order',
                                orderable: false,
                                searchable: false
                        },
                        {
                                targets: 'no-search',
                                orderable: true,
                                searchable: false
                        }],
                });
        };
        if ($('table#admin_jobs').size() > 0) {
                $('table#admin_jobs').DataTable({
                        paging: false,
                        order: [],
                        columnDefs: [
                        {
                                targets: 'neither-search-nor-order',
                                orderable: false,
                                searchable: false
                        },
                        {
                                targets: 'no-search',
                                orderable: true,
                                searchable: false
                        }],
                });
        };
        if ($('table#rejected_hosts').size() > 0) {
                $('table#rejected_hosts').DataTable({
                        paging: false,
                        order: [],
                        columnDefs: [],
                });
        };
        if ($('table#logs').size() > 0) {
                $('table#logs').DataTable({
                        paging: false,
                        order: [],
                        columnDefs: [
                        {
                                targets: 'neither-search-nor-order',
                                orderable: false,
                                searchable: false
                        },
                        {
                                targets: 'no-order',
                                orderable: false,
                                searchable: true
                        },
                        {
                                targets: 'no-search',
                                orderable: true,
                                searchable: false
                        }],
                });
        };
        if ($('.datepicker').size() > 0) {
                $('.datepicker').datepicker({
                        dateFormat: "dd-mm-yy"
                });
        };
});
