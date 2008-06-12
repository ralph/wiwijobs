set :application, "wiwijobs"
set :repository,  "http://rvdh.net/svn/repos/ofis2/trunk"

set :deploy_to, "/root/#{application}"

role :app, "128.176.158.70"
role :web, "128.176.158.70"
role :db,  "128.176.158.70", :primary => true

ssh_options[:username] = 'root'
set :scm_username, "ralph"

desc "Webserver auf der WI-VM neu starten"
task :restart_web_server, :roles => :web do
  run "/etc/init.d/mongrel_cluster restart"
  run "/etc/init.d/httpd restart"
end

after "deploy:restart", :restart_web_server