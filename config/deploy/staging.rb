set :rails_env, :production

server 'baas-edet4.grnet.gr', user: 'archiving', roles: %w(web app db)

set :ssh_options, forward_agent: false
