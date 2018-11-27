namespace :load do
  task :defaults do
    set :anycable_pid, -> { File.join(shared_path, 'tmp', 'pids', 'anycable.pid') }
    set :anycable_daemon_file, -> { File.join(shared_path, 'anycable_daemon.rb') }
    set :anycable_log_file, -> { File.join(shared_path, 'log', 'anycable.log') }
  end
end

namespace :anycable do
  desc 'Config daemon. Generate and send anycable.rb'
  task :config do
    on roles(:app), in: :sequence, wait: 5 do
      path = File.expand_path("../daemon_template.rb.erb", __FILE__)
      if File.file?(path)
        erb = File.read(path)
        upload! StringIO.new(ERB.new(erb).result(binding)), fetch(:anycable_daemon_file)
        info 'Config file sucessfully uploaded'
      end
    end
  end

  desc 'Start daemon'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        invoke 'anycable:check'
        execute :bundle, :exec, :ruby, fetch(:anycable_daemon_file), 'start'
      end
    end
  end

  desc 'Stop daemon'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        invoke 'anycable:check'
        execute :bundle, :exec, :ruby, fetch(:anycable_daemon_file), 'stop'
      end
    end
  end

  desc 'Restart daemon'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        invoke 'anycable:check'
        execute :bundle, :exec, :ruby, fetch(:anycable_daemon_file), 'restart'
      end
    end
  end

  desc 'Check if config file exixts on server. If not - create and upload one.'
  task :check do
    on roles(:app), in: :sequence, wait: 5 do
      if test "[ -f #{fetch(:anycable_daemon_file)} ]"
        info 'Config file exists'
      else
        warn 'Config file is missing'
      end
    end
  end

  after 'deploy:finished', 'anycable:restart'
end
