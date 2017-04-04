bacula_yml = YAML.load_file(Rails.root.join('config', 'bacula.yml'))[Rails.env].symbolize_keys
Archiving.settings director_name: bacula_yml[:director]
Archiving.settings default_pool: bacula_yml[:pool]
Archiving.settings quota_checker: bacula_yml[:quota_checker]

Archiving.settings vima_oauth_enabled: true
Archiving.settings institutional_authentication_enabled: true
Archiving.settings okeanos_authentication_enabled: false

Archiving.settings default_sender: 'admin@archiving.grnet.gr'

Archiving.settings temp_db_retention: 3.days

Archiving.settings skip_host_fetch_time_period: 1.month
Archiving.settings mail_settings: YAML::load(File.open("#{Rails.root}/config/mailer.yml"))[Rails.env].symbolize_keys

Archiving.settings client_quota: 100.megabytes

jira_src = Rails.application.secrets.jira_src
jira_field = Rails.application.secrets.jira_custom_field_name
jira_value = Rails.application.secrets.jira_custom_field_value

if jira_src && jira_field && jira_value
  Archiving.settings jira_src: jira_src
end
