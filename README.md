# Mina::Nginx::Puma

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/mina/puma`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
    gem 'mina-nginx-puma'
end
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mina-nginx-puma

## Usage
### Prerequisite

- Puma v5.0 + (used by systemd)
- Mina v1.0 +

1. add code to `deploy.rb`

```ruby
require 'mina/puma'
```

```ruby
set :systemctl_path, 'sudo systemctl'
set :system_config_path, '/etc/systemd/system'
set :system_bundler_path, '/usr/local/rvm/bin/rvm all do bundle' #rvm
# set :system_bundler_path, -> { "/#{fetch(:user)}/.rbenv/bin/rbenv exec bundle" } #rbenv
set :puma_user, -> { fetch(:user).to_s }
set :puma_socket_listen_stream, -> { "#{fetch(:deploy_to)}/shared/tmp/sockets/puma.sock" }
set :puma_config_path, -> { "#{fetch(:deploy_to)}/shared/config/puma.rb" }
set :system_service_name, -> { "#{fetch(:application_name)}.service" }
set :system_socket_name, -> { "#{fetch(:application_name)}.socket" }
set :puma_state_path, -> { "#{fetch(:current_path)}/tmp/sockets/puma.state" }
set :nginx_path, '/etc/nginx'
set :cert_path, '/etc/nginx/cert.pem'
set :cert_key_path, '/etc/nginx/cert.key'
set :use_ssl, false
```

2. how to work
- check mina -T view all list
- mina puma:install
- mina puma:setup
- after mina deploy
- mina puma:restart

- after mina deploy
```ruby
task :deploy do
    deploy do
        invoke :'git:clone'
        invoke :'deploy:link_shared_paths'
        invoke :'bundle:install'
        invoke :'rails:db_migrate'
        invoke :'rails:assets_precompile'
        invoke :'deploy:cleanup'
        on :launch do
            invoke :'puma:restart' # add this line
        end
    end

end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mina-nginx-puma. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/mina-nginx-puma/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mina::Nginx::Puma project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mina-nginx-puma/blob/master/CODE_OF_CONDUCT.md).
