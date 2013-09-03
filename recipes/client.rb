#
# Cookbook Name:: rundeck
# Recipe:: client
#
# Author:: mc (<marcin.cabaj@datasift.com>)
#
# Copyright 2013, MediaSift Ltd
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

group node['rundeck']['ssh']['user'] do
  gid node['rundeck']['ssh']['user_gid']
  action :create
end

user node['rundeck']['ssh']['user'] do
  action :create
  uid node['rundeck']['ssh']['user_uid']
  gid node['rundeck']['ssh']['user_gid']
  supports :manage_home => true
end

directory "/home/#{node['rundeck']['ssh']['user']}/.ssh" do
  action :create
  owner node['rundeck']['ssh']['user']
  group node['rundeck']['ssh']['user']
  mode 0700
end

file "/home/#{node['rundeck']['ssh']['user']}/.ssh/authorized_keys" do
  action :create
  owner node['rundeck']['ssh']['user']
  group node['rundeck']['ssh']['user']
  content node['rundeck']['ssh']['user_pub_key']
  mode 0600
end

