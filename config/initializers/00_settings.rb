Archiving.settings director_name: YAML.load_file(Rails.root.join('config', 'bacula.yml'))[Rails.env].
  symbolize_keys[:director]

Archiving.settings vima_oauth_enabled: true
Archiving.settings institutional_authentication_enabled: true
Archiving.settings okeanos_authentication_enabled: false

Archiving.settings default_sender: 'admin@archiving.grnet.gr'
Archiving.settings admin_email: 'admin@archiving.grnet.gr'

Archiving.settings temp_db_retention: 3.days

Archiving.settings skip_host_fetch_time_period: 1.month
