# @summary Creates multiple managed service and package resources with random data
#
# This class demonstrates how to create multiple service and package resources
# with randomized data. It's useful for load testing Puppet catalogs.
#
# @param service_count
#   The number of service resources to create
# @param package_count
#   The number of package resources to create
# @param service_ensure_ratio
#   Ratio of running to stopped services (0.8 means 80% running, 20% stopped)
# @param package_ensure_ratio
#   Ratio of installed to absent packages (0.9 means 90% installed, 10% absent)
# @param service_enable_ratio
#   Ratio of enabled to disabled services (0.7 means 70% enabled, 30% disabled)
# @param multi_provider
#   Whether to use multiple service providers or stick to one
# @param delay_random
#   Whether to add random notify/require relationships between resources
#
# @example Creating random services and packages
#   class { 'load_test::random_services_packages':
#     service_count => 50,
#     package_count => 100,
#   }
#
class load_test::random_services_packages (
  Integer[0] $service_count        = 50,
  Integer[0] $package_count        = 200,
  Float[0.0, 1.0] $service_ensure_ratio = 0.8,
  Float[0.0, 1.0] $package_ensure_ratio = 0.9,
  Float[0.0, 1.0] $service_enable_ratio = 0.7,
  Boolean $multi_provider          = true,
  Boolean $delay_random            = true,
) {
  # Define common service names for realistic simulation
  $service_names = [
    'httpd', 'nginx', 'apache2', 'mysql', 'mariadb', 'postgresql',
    'mongodb', 'redis', 'memcached', 'elasticsearch', 'kibana', 'logstash',
    'prometheus', 'grafana', 'influxdb', 'telegraf', 'consul', 'nomad',
    'vault', 'docker', 'containerd', 'kubelet', 'crio', 'sshd', 'ntpd',
    'chronyd', 'rsyslog', 'systemd-journald', 'crond', 'atd', 'udev',
    'networkd', 'firewalld', 'iptables', 'fail2ban', 'auditd', 'named',
    'bind', 'dhcpd', 'squid', 'haproxy', 'varnish', 'postfix', 'dovecot',
    'vsftpd', 'nfs', 'samba', 'cups', 'jenkins', 'gitlab', 'zookeeper',
    'kafka', 'rabbitmq', 'puppet', 'puppetserver', 'puppetdb', 'salt-master',
    'salt-minion', 'chef-client', 'chef-server', 'ansible', 'nagios',
    'zabbix', 'icinga', 'splunk', 'tomcat', 'jetty', 'wildfly', 'jboss',
  ]

  # Define common package names for realistic simulation
  $package_names = [
    'httpd', 'nginx', 'apache2', 'mysql-server', 'mariadb-server', 'postgresql',
    'mongodb', 'redis', 'memcached', 'elasticsearch', 'kibana', 'logstash',
    'prometheus', 'grafana', 'influxdb', 'telegraf', 'consul', 'nomad',
    'vault', 'docker-ce', 'containerd.io', 'kubernetes-cni', 'cri-o', 'openssh-server',
    'ntp', 'chrony', 'rsyslog', 'cronie', 'at', 'udev', 'systemd', 'firewalld',
    'iptables', 'fail2ban', 'audit', 'bind', 'dhcp-server', 'squid', 'haproxy',
    'varnish', 'postfix', 'dovecot', 'vsftpd', 'nfs-utils', 'samba', 'cups',
    'jenkins', 'gitlab-ce', 'zookeeper', 'kafka', 'rabbitmq-server', 'puppet-agent',
    'puppetserver', 'puppetdb', 'salt-master', 'salt-minion', 'chef', 'ansible',
    'nagios', 'zabbix-server', 'icinga2', 'splunk', 'tomcat9', 'jetty', 'wildfly',
    'vim', 'emacs', 'nano', 'git', 'subversion', 'mercurial', 'curl', 'wget',
    'unzip', 'tar', 'gzip', 'bzip2', 'zip', 'gcc', 'g++', 'make', 'autoconf',
    'automake', 'cmake', 'python3', 'python3-pip', 'python3-dev', 'python3-venv',
    'nodejs', 'npm', 'ruby', 'ruby-dev', 'php', 'php-fpm', 'php-mysql', 'php-pgsql',
    'openjdk-11-jdk', 'openjdk-8-jdk', 'perl', 'tcl', 'lua', 'go', 'rust',
  ]

  # Define service providers
  $service_providers = ['systemd', 'init', 'upstart', 'redhat', 'debian']

  # Generate random service resources
  range(1, $service_count).each |$i| {
    # Choose a random service name
    $service_idx = fqdn_rand(size($service_names), "${i}_svc_name")
    $service_name = $service_names[$service_idx]

    # Random ensure (running or stopped)
    $is_running = fqdn_rand(100, "${i}_svc_running") < ($service_ensure_ratio * 100)
    $ensure = $is_running ? {
      true  => 'running',
      false => 'stopped',
    }

    # Random enable (true or false)
    $is_enabled = fqdn_rand(100, "${i}_svc_enabled") < ($service_enable_ratio * 100)

    # Random provider if multi_provider is true
    $provider = $multi_provider ? {
      true  => $service_providers[fqdn_rand(size($service_providers), "${i}_svc_provider")],
      false => undef,
    }

    # Random boolean for hasstatus and hasrestart
    $hasstatus = fqdn_rand(10, "${i}_svc_hasstatus") > 1  # 80% true
    $hasrestart = fqdn_rand(10, "${i}_svc_hasrestart") > 1  # 80% true

    # Create service resource
    service { "test_service_${service_name}_${i}":
      ensure     => $ensure,
      name       => $service_name,
      enable     => $is_enabled,
      provider   => $provider,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
    }
  }

  # Generate random package resources
  range(1, $package_count).each |$i| {
    # Choose a random package name
    $package_idx = fqdn_rand(size($package_names), "${i}_pkg_name")
    $package_name = $package_names[$package_idx]

    # Random ensure (present/installed or absent)
    $is_installed = fqdn_rand(100, "${i}_pkg_installed") < ($package_ensure_ratio * 100)
    $ensure = $is_installed ? {
      true  => fqdn_rand(10, "${i}_pkg_ensure") < 8 ? {
        true  => 'installed',
        false => 'latest',
      },
      false => 'absent',
    }

    # Random version (for some packages)
    $has_version = fqdn_rand(10, "${i}_pkg_hasversion") < 3  # 30% have specific version
    $version = $has_version ? {
      true  => "${fqdn_rand(5, "${i}_pkg_major")}.${fqdn_rand(10, "${i}_pkg_minor")}.${fqdn_rand(20, "${i}_pkg_patch")}",
      false => undef,
    }

    # Create package resource
    package { "test_package_${package_name}_${i}":
      ensure  => $ensure,
      name    => $package_name,
      # Only include version if it's defined and ensure is not 'absent'
      version => $ensure ? {
        'absent' => undef,
        default  => $version,
      },
    }

    # If delay_random is true, create some dependencies between packages and services
    if $delay_random and $i <= $service_count and $is_installed {
      # 30% chance to create a relationship
      if fqdn_rand(10, "${i}_relation") < 3 {
        # Find the corresponding service index
        $related_svc = fqdn_rand($service_count, "${i}_related_svc") + 1
        $svc_idx = fqdn_rand(size($service_names), "${related_svc}_svc_name")
        $svc_name = $service_names[$svc_idx]

        # Create a notify relationship (package changes notify service)
        Package["test_package_${package_name}_${i}"] ~> Service["test_service_${svc_name}_${related_svc}"]
      }
    }
  }
}
