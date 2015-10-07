# == Class appdynamics::agent::config::php
#
class appdynamics::agent::config::php
(
  $agent_base,
  $agent_home,
  $group,
  $user,
  $app,
  $tier,
  $controller_host,
  $controller_port,
  $controller_ssl_enabled,
  $enable_orchestration,
  $account_name,
  $account_access_key,
  $force_agent_registration,
  $node_name,
  $agent_options,
  $application_home,
)
inherits appdynamics::params
{
  $agent_runtime_directory              =  "${agent_base}/${agent_home}/appdynamics-php-agent"

  file { 'php_agent_basehome':
    path                                =>  "${agent_base}/${agent_home}",
    ensure                              =>  directory,
    group                               =>  $group,
    owner                               =>  $user,
    mode                                =>  '0755',
  } ->

  file { "$agent_home":
    path                                =>  $agent_runtime_directory,
    ensure                              =>  directory,
    group                               =>  $group,
    owner                               =>  $user,
    mode                                =>  '0755',
    before                              =>  Service['appdynamics-php'],
    require                             =>  Class['appdynamics::agent::install'],
  } ->

  # All this seems to be unneccesary if the install script is run properly.  Test on new boxes.
  # file { 'php_xml':
  #   path                                =>  "${agent_runtime_directory}/proxy/conf/controller-info.xml",
  #   content                             =>  template('appdynamics/agent/php/controller-info_xml.erb'),
  #   group                               =>  $group,
  #   owner                               =>  $user,
  #   mode                                =>  '0644',
  # } ->

  # file { 'appdynamics_php_ini':
  #   path                                =>  "/etc/php5/conf.d/appdynamics_agent.ini",
  #   content                             =>  template('appdynamics/agent/php/appdynamics_agent.erb'),
  #   owner                               =>  $group,
  #   group                               =>  $user,
  #   mode                                =>  '0644',
  # } ->

  exec {'php_run_agent_install_script':
    path                                =>  '/bin:/usr/bin',
    command                             =>  "${agent_runtime_directory}/install.sh --ignore-permissions -a=${account_name}@${account_access_key} $controller_host $controller_port $app $tier $node_name",
    cwd                                 =>  $agent_runtime_directory,
    user                                =>  'root',
    unless                              =>  [ "test -d ${agent_runtime_directory}/multiAgentInstall",
                                              "test $(find /etc/php* -type f -name appdynamics_agent.ini -exec grep -ic $node_name {} \;) -ge 1" ],
    notify                              =>  Service['appdynamics-php'],
  }
}