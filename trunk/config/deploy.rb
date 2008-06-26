set :application, "wiwijobs"
set :repository,  "https://wiwijobs.googlecode.com/svn/trunk"
set :scm_username, "sebastian.tuke"

set :deploy_to, "/root/#{application}"

role :app, "128.176.158.70"
role :web, "128.176.158.70"
role :db,  "128.176.158.70", :primary => true

ssh_options[:username] = 'root'

set :use_sudo, false

desc "Webserver auf der WI-VM neu starten"
task :restart_web_server, :roles => :web do
  run "/etc/init.d/mongrel_cluster restart"
  run "/etc/init.d/httpd restart"
end

after "deploy:restart", :restart_web_server