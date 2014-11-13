# config valid only for Capistrano 3.2.1
lock '3.2.1'

set :application, '<%= capprojectname %>'
set :repo_url, 'git@git.snpdev.ru:saltpepper/<%= capprojectname %>-frontend.git'
set :scm, :rsync

set :commit_id, ENV['CI_COMMIT_ID'] || ENV['CI_BUILD_SHA']

if fetch(:commit_id).nil?
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
else
  set :branch, fetch(:commit_id)
end

set :deploy_to, "/var/www/#{fetch(:application)}/cs"

set :rsync_src_path, 'dist'

set :grunt_tasks, 'build:dist'

namespace :grunt do
  task :build do
    run_locally do
      within fetch(:rsync_stage) do
        execute :npm, 'install'
        execute :bower, 'install'
        execute :grunt, fetch(:grunt_tasks)
      end
    end
  end
end

after 'rsync:stage', 'grunt:build'
