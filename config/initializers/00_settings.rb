Baas.settings director_name: YAML.load_file(Rails.root.join('config', 'bacula.yml'))[Rails.env].
  symbolize_keys[:director]

Archiving.settings vima_oauth_enabled: true
Archiving.settings institutional_authentication_enabled: true
Archiving.settings okeanos_authentication_enabled: false
