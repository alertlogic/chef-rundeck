#
# Cookbook Name:: rundeck
# Recipe:: chef
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2013, Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if Chef::Config[:solo]
  secretsobj = data_bag_item(node['rundeck']['secrets']['data_bag'], node['rundeck']['secrets']['data_bag_id']) rescue {
    'chef_client_key' => node['chef-rundeck']['client_key']
  }
elsif node['rundeck']['secrets']['encrypted_data_bag']
  secretsobj = Chef::EncryptedDataBagItem.load(node['rundeck']['secrets']['data_bag'], node['rundeck']['secrets']['data_bag_id'])
else
  secretsobj = data_bag_item(node['rundeck']['secrets']['data_bag'], node['rundeck']['secrets']['data_bag_id'])
end

if secretsobj['chef_client_key'].nil? || secretsobj['chef_client_key'].empty? ||
   node['chef-rundeck']['client_name'].nil? || node['chef-rundeck']['client_name'].empty?
  raise 'Could not locate a valid client/PEM key pair for chef-rundeck. Please define one!'
end

# Install the chef-rundeck gem on the Chef omnibus package. Useful workaround instead of installing RVM, a system Ruby etc
# and it offers minimal system pollution
# Currently installing a better version than the original Opscode one, pending a pull request

#|git "#{Chef::Config['file_cache_path']}/chef-rundeck-gem" do
#|  repository node['chef-rundeck']['git']['repo']
#|  reference node['chef-rundeck']['git']['branch']
#|  action :sync
#|end
#|
#|require 'rubygems/commands/build_command'
#|ruby_block 'build-chef-rundeck' do
#|  block do
#|    x = Gem::Commands::BuildCommand.new
#|    Dir.chdir("#{Chef::Config['file_cache_path']}/chef-rundeck-gem") {
#|      x.invoke "chef-rundeck.gemspec"
#|    }
#|  end
#|  action :create
#|end
#|
#|chef_gem 'chef-rundeck' do
#|  source Dir["#{Chef::Config['file_cache_path']}/chef-rundeck-gem/chef-rundeck-*.gem"][0]
#|  action :install
#|end

gem_package 'sinatra'

git "/opt/chef-rundeck" do
  repository node['chef-rundeck']['git']['repo']
  reference node['chef-rundeck']['git']['branch']
  action :sync
end


# Create the knife.rb for chef-rundeck to read
directory '/var/lib/rundeck/.chef' do
  owner 'rundeck'
  group 'rundeck'
  mode 00755
  action :create
end

template '/var/lib/rundeck/.chef/knife.rb' do
  source 'knife.rb.erb'
  owner 'rundeck'
  group 'rundeck'
  mode 00644
  variables({
    :user => node['chef-rundeck']['client_name'],
    :chef_server_url => node['chef-rundeck']['server_url']
  })
  notifies :restart, 'service[chef-rundeck]'
end

file "/var/lib/rundeck/.chef/#{node['chef-rundeck']['client_name']}.pem" do
  action :create
  owner 'rundeck'
  group 'rundeck'
  mode 00644
  content secretsobj['chef_client_key']
end

template '/etc/init.d/chef-rundeck' do
  action :create
  source 'init.d-chef-rundeck.erb'
  mode 00755
  variables({
    :command => "/opt/chef-rundeck/bin/chef-rundeck -c /var/lib/rundeck/.chef/knife.rb -a #{node['chef-rundeck']['server_url']} -o 0.0.0.0 -p #{node['chef-rundeck']['port']} -u #{node['rundeck']['ssh']['user']}"
  })
  notifies :restart, 'service[chef-rundeck]'
end

service 'chef-rundeck' do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
