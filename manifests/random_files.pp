# @summary Creates multiple managed_file resources with random data
#
# This class demonstrates how to create multiple managed_file resources
# with randomized data. It's useful for load testing Puppet catalogs.
#
# @param count
#   The number of file resources to create
# @param base_path
#   The base directory where files/directories will be created
# @param file_ratio
#   Ratio of files to directories (0.7 means 70% files, 30% directories)
# @param max_content_length
#   Maximum length of generated file content
# @param create_subdirs
#   Whether to create subdirectories in the base path
# @param max_depth
#   Maximum depth of subdirectories if create_subdirs is true
#
# @example Creating 100 random file resources
#   class { 'load_test::random_files':
#     count     => 100,
#     base_path => '/tmp/puppet_test',
#   }
#
class load_test::random_files (
  Integer[1] $count                = 30,
  Optional[String] $base_path      = undef,
  Float[0.0, 1.0] $file_ratio      = 0.7,
  Integer[10, 10000] $max_content_length = 1000,
  Boolean $create_subdirs          = true,
  Integer[1, 10] $max_depth        = 3,
) {
  # Ensure the base directory exists
  file { $base_path:
    ensure => directory,
    # before => Load_test::Managed_file[$base_path],
  }

  # Define possible paths and content
  $paths = ['bin', 'boot', 'etc', 'lib', 'lib64', 'media', 'opt', 'root', 'sbin',
  'sys',  'usr', 'dev', 'home', 'mnt', 'proc', 'run', 'srv', 'tmp', 'var']

  # Define possible owners and groups
  $owners = ['root', 'nobody', 'daemon', 'www-data', 'apache']
  $groups = ['root', 'wheel', 'adm', 'staff', 'www-data']

  # Define possible file modes
  $file_modes = ['0644', '0640', '0600', '0444', '0400']
  $dir_modes = ['0755', '0750', '0700', '0555', '0500']

  # Generate random resources
  range(1, $count).each |$i| {
    # Pick a random name for filename and path
    $path = $paths[fqdn_rand(size($paths), "${i}_seed1")]
    $full_path = $create_subdirs ? {
      true  => "${base_path}/${path}/${path}-${i}",
      false => "${base_path}/${path}-${i}",
    }

    # Decide if this should be a file or directory
    $is_file = fqdn_rand(100, "${i}_type") < ($file_ratio * 100)
    $ensure = $is_file ? {
      true  => 'file',
      false => 'directory',
    }

    # Use filename as content for files
    $content = $is_file ? {
      true  => $full_path,
      false => undef,
    }

    # Select random owner and group
    $owner = $owners[fqdn_rand(size($owners), "${i}_owner")]
    $group = $groups[fqdn_rand(size($groups), "${i}_group")]

    # Select random mode
    $mode = $is_file ? {
      true  => $file_modes[fqdn_rand(size($file_modes), "${i}_mode")],
      false => $dir_modes[fqdn_rand(size($dir_modes), "${i}_mode")],
    }

    $recurse_real = $ensure ? {
      'directory' => fqdn_rand(2, "${i}_recurse") == 0,
      default     => false,
    }

    # Create a random managed_file resource
    load_test::managed_file { "random_file_${i}":
      ensure  => $ensure,
      path    => $full_path,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => $content,
      recurse => $recurse_real,
      force   => fqdn_rand(2, "${i}_force") == 0,
    }
  }
}
