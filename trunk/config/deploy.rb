set :application, "wiwijobs"
set :repository,  "https://wiwijobs.googlecode.com/svn/trunk"
set :deploy_to, "/root/#{application}"

ssh_options[:username] = 'root'
set :password, "!DfghMnB456*"
set :use_sudo, false

set :scm, "subversion"
set :scm_username, "sebastian.tuke"


role :app, "128.176.158.70"
role :web, "128.176.158.70"
role :db,  "128.176.158.70", :primary => true


desc "Webserver auf der WI-VM neu starten"
task :restart_web_server, :roles => :web do
  run "/etc/init.d/mongrel_cluster restart"
  run "/etc/init.d/httpd restart"
end

after "deploy:restart", :restart_web_server