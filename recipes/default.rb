include_recipe "zip"
include_recipe "java8"
include_recipe "jq"
include_recipe "opwsorks-cloudwatch-logs"

service 'monit' do
  action :nothing
end

user 'play' do
  system true
end

directory "/opt/elasticbeanstalk/deploy" do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

%w{appsource configuration}.each do |dir|
  directory File.join("/opt/elasticbeanstalk/deploy", dir) do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

directory "/var/app" do
  owner 'play'
  group 'play'
  mode '0755'
  action :create
end

directory "/var/log/play" do
  owner 'play'
  group 'play'
  mode '0755'
  action :create
end

bash 'install activator' do
  cwd "/opt"
  code <<-EOH
      wget -P /opt/ http://downloads.typesafe.com/typesafe-activator/1.2.12/typesafe-activator-1.2.12-minimal.zip
      unzip /opt/typesafe-activator-1.2.12-minimal.zip
      rm -f /opt/typesafe-activator-1.2.12-minimal.zip
      chmod a+x /opt/activator-1.2.12-minimal/activator
    EOH
  not_if { ::File.exists?("/opt/activator-1.2.12-minimal/activator") }
end

bash 'add activator to the PATH' do
  cwd "/opt"
  code <<-EOH
      echo '#! /bin/sh
export PATH=$PATH:/opt/activator-1.2.12-minimal/
' > /etc/profile.d/activator.sh
chmod +x /etc/profile.d/activator.sh
source /etc/profile.d/activator.sh
unset DISPLAY
    EOH
  not_if { ::File.exists?("/etc/profile.d/activator.sh") }
end

bash 'adds app source' do
  cwd "/opt"
  code <<-EOH
      wget -O /opt/elasticbeanstalk/deploy/appsource/source_bundle https://github.com/davemaple/playframework-example-application-mode/blob/master/playtest.zip?raw=true
    EOH
  not_if { ::File.exists?("/opt/elasticbeanstalk/deploy/appsource/source_bundle") }
end

template "play" do
  path "/etc/init.d/play"
  source "play.erb"
  owner "root"
  group "root"
  mode 0755
end

template "containerconfiguration" do
  path "/opt/elasticbeanstalk/deploy/configuration/containerconfiguration"
  source "containerconfiguration.erb"
  owner "play"
  group "play"
  mode 0644
end

template "#{node[:monit][:conf_dir]}/play.monitrc" do
    cookbook 'play'
    mode '0600'
    source "monitrc.erb"
    notifies :restart, "service[monit]"
end

include_recipe "play::service"

service "play" do
  action [ :restart ]
end
