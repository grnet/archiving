set :rails_env, :production

set :repo_url, 'https://repo.grnet.gr/diffusion/ARCHIVING/archiving.git'

server '83.212.1.103', user: 'archiving', roles: %w(web app db)

set :ssh_options, {
    forward_agent: false,
    port: 29
}
