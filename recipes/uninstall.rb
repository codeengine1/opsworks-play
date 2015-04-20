if File.exists?("/etc/init.d/play")
  include_recipe "play::service"

  service "play" do
    action :stop
  end

  # remove playframework stuff
end