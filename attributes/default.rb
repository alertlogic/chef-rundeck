#-----------------------------------------------------------------------------
# Cookbook Name:: rundeck
# Attribute:: default
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright (C) 2013 Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-----------------------------------------------------------------------------

# --- Rundeck packages ---

default['rundeck']['deb_version']       = '2.0.3-1-GA'
default['rundeck']['deb_url']           = "http://download.rundeck.org/deb/rundeck-#{node['rundeck']['deb_version']}.deb"
default['rundeck']['deb_checksum']      = '314b68c3ad25a29986efb76861cba1993023614d3981d5043f34cdbfe4bf267b'

default['rundeck']['rpm_version']       = '2.0.3-1.14.GA'
default['rundeck']['rpm_url']           = "http://download.rundeck.org/rpm/rundeck-#{node['rundeck']['rpm_version']}.noarch.rpm"
default['rundeck']['rpm_cfg_url']       = "http://download.rundeck.org/rpm/rundeck-config-#{node['rundeck']['rpm_version']}.noarch.rpm"
default['rundeck']['rpm_checksum']      = '9fd6c9a9043b5cfbc1013048514d5b294c85eebade322f8ab690cd7c43c6d508'
default['rundeck']['rpm_cfg_checksum']  = 'b96240e658f94bc90a444abe4c55e9562df96e6008ba90969cfeca88e51eb96c'


# --- Framework config ---

default['rundeck']['node_name']     = node.name
default['rundeck']['hostname']      = node['fqdn']
default['rundeck']['port']          = 4440
default['rundeck']['log4j_port']    = 4435
default['rundeck']['public_rss']    = false
default['rundeck']['logging_level'] = 'INFO'
default['rundeck']['jaas']          = "internal"
default['rundeck']['required_role'] = "user"
default['rundeck']['projects_dir']  = "/var/rundeck/projects"


# --- Optional databag for secrets ---
# Chef-solo runs may not want to use databags.
# If used, should contain keys:
#    'admin_password'
#    'ssh_user_priv_key'
#    'chef_client_key'

default['rundeck']['secrets']['encrypted_data_bag'] = true
default['rundeck']['secrets']['data_bag']           = 'credentials'
default['rundeck']['secrets']['data_bag_id']        = 'rundeck'


# --- Administrator credentials ---

default['rundeck']['admin']['username'] = 'admin'
default['rundeck']['admin']['password'] = 'admin'   # used unless databag used (admin_password)


# --- Rundeck additional 'admin' users ---

default['rundeck']['admins'] = %w{ }


# --- SSH to nodes ---

default['rundeck']['ssh']['user']          = 'rundeck'
default['rundeck']['ssh']['user_uid']      = 9998
default['rundeck']['ssh']['user_gid']      = 9998
default['rundeck']['ssh']['user_pub_key']  = ''
default['rundeck']['ssh']['user_priv_key'] = ''    # used unless databag used (ssh_user_priv_key)

default['rundeck']['ssh']['timeout'] = 300000
default['rundeck']['ssh']['port']    = 22


# --- Email notifications ---

default['rundeck']['mail'] = {
                               'hostname' => 'localhost',
                               'port'     => 25,
                               'username' => nil,
                               'password' => nil,
                               'from'     => 'ops@example.com',
                               'tls'      => false
                             }
default['rundeck']['mail']['recipients_data_bag'] = 'users'
default['rundeck']['mail']['recipients_query']    = 'notify:true'
default['rundeck']['mail']['recipients_field']    = "['email']"


# --- Java tuning ---

default['rundeck']['java']['enable_jmx']        = false
default['rundeck']['java']['allocated_memory']  = "#{(node['memory']['total'].to_i * 0.25 ).floor / 1024}m"
default['rundeck']['java']['thread_stack_size'] = '256k'


# --- Frontend HTTP proxy ---

default['rundeck']['proxy']['hostname'] = 'rundeck'
default['rundeck']['proxy']['default']  = false


# --- LDAP ---

default['rundeck']['ldap']['providerurl']         = "ldap://ldap.example.com:389"
default['rundeck']['ldap']['binddn']              = nil   # or eg. "cn=admin,ou=Users,dc=example,dc=com"
default['rundeck']['ldap']['bindpasswd']          = nil   # or eg. "ADMIN_PASSWORD"
default['rundeck']['ldap']['userbasedn']          = "dc=example,dc=com"
default['rundeck']['ldap']['userobjectclass']     = "inetOrgPerson"
default['rundeck']['ldap']['useridattribute']     = "cn"
default['rundeck']['ldap']['rolebasedn']          = "dc=example,dc=com"
default['rundeck']['ldap']['roleobjectclass']     = "groupOfUniqueNames"
default['rundeck']['ldap']['rolememberattribute'] = "uniqueMember"
default['rundeck']['ldap']['rolenameattribute']   = "cn"


# --- Chef integration ---

default['chef-rundeck']['port']        = 9980
default['chef-rundeck']['client_name'] = ''
default['chef-rundeck']['client_key']  = ''            # used unless databag used (chef_client_key)
default['chef-rundeck']['server_url']  = Chef::Config['chef_server_url']

default['chef-rundeck']['git']['repo']   = 'https://github.com/oswaldlabs/chef-rundeck.git'
default['chef-rundeck']['git']['branch'] = '360bf822148aa5bc05e76e068b4933d6e34450d2'

default['chef-rundeck']['init.d']['name']       = 'chef-rundeck'
default['chef-rundeck']['init.d']['user']       = 'rundeck'
default['chef-rundeck']['init.d']['runlevels']  = '345'
default['chef-rundeck']['init.d']['startorder'] = '89'
default['chef-rundeck']['init.d']['stoporder']  = '11'
default['chef-rundeck']['init.d']['logfile']    = '/var/log/rundeck/chef-rundeck.log'
