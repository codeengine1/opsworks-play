service "play" do
  supports :status => true, :restart => true, :stop => true, :start => true
  action :nothing
end
