#
# Cookbook:: b2s-django
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#


include_recipe 'mani-python'
include_recipe "mani-python::pip"
#node['python']['distribute_install_py_version'] = "0.6.25"


#execute 'python36 link' do 
#  command <<-EOL
#   unlink /bin/python
#   ln -sf /bin/python36 /bin/python
#   exit
#  EOL
#end

mani_python_pip "virtualenv" do
  action :install
end

mani_python_virtualenv "/opt/django-app" do
  interpreter "python3.6"
  owner "cloud_user"
  group "cloud_user"
  action :create
end

mani_python_pip "django" do
  virtualenv node['b2s-django']['install_path']
  version "2.1.3"
end

mani_python_pip "requests" do
  virtualenv node['b2s-django']['install_path']
end

package_url = "#{node['b2s-django']['nexus_search_url']}/#{node['b2s-django']['package']['repo_id']}/#{node['b2s-django']['package']['group_id']}/#{node['b2s-django']['package']['artifact_id']}/#{node['b2s-django']['package']['version']}/#{node['b2s-django']['package']['artifact_id']}-#{node['b2s-django']['package']['version']}.#{node['b2s-django']['package']['packaging']}"


package_file = "#{Chef::Config['file_cache_path']}/dashboard-#{node['b2s-django']['package']['version']}.#{node['b2s-django']['package']['packaging']}"

file "#{Chef::Config['file_cache_path']}/#{package_file}" do
  action :delete
end

remote_file package_file do
  source package_url
  mode '0644'
  backup false
  user 'cloud_user'
  group 'cloud_user'
  notifies :run, 'execute[unpack downloaded package]', :immediately
end
 
execute 'unpack downloaded package' do
  action :nothing
  cwd node['b2s-django']['install_path']
  command "tar xf #{package_file}"
end
