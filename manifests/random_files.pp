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
  Integer[1] $count                = 300,
  String $base_path                = '/tmp/puppet_test',
  Float[0.0, 1.0] $file_ratio      = 0.7,
  Integer[10, 10000] $max_content_length = 1000,
  Boolean $create_subdirs          = true,
  Integer[1, 10] $max_depth        = 3,
) {
  # Ensure the base directory exists
  file { $base_path:
    ensure => directory,
    before => Load_test::Managed_file[$base_path],
  }

  # Generate random alphanumeric strings for names and content
  $alphanumeric = ['a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
  '0','1','2','3','4','5','6','7','8','9']

  # Define possible owners and groups
  $owners = ['root', 'nobody', 'daemon', 'www-data', 'apache']
  $groups = ['root', 'wheel', 'adm', 'staff', 'www-data']

  # Define possible file modes
  $file_modes = ['0644', '0640', '0600', '0444', '0400']
  $dir_modes = ['0755', '0750', '0700', '0555', '0500']

  # Generate random resources
  range(1, $count).each |$i| {
    # Generate a random name
    $name_length = fqdn_rand(10, "${i}_name") + 5  # 5-15 characters
    $name_chars = range(1, $name_length).map |$n| {
      $alphanumeric[fqdn_rand(size($alphanumeric), "${i}_name_${n}")]
    }
    $name = join($name_chars, '')

    # Decide if this should be a file or directory
    $is_file = fqdn_rand(100, "${i}_type") < ($file_ratio * 100)
    $ensure = $is_file ? {
      true  => 'file',
      false => 'directory',
    }

    # Generate a random path
    if $create_subdirs {
      $depth = fqdn_rand($max_depth, "${i}_depth") + 1
      $path_parts = range(1, $depth).map |$d| {
        $part_length = fqdn_rand(8, "${i}_path_${d}") + 3
        $part_chars = range(1, $part_length).map |$p| {
          $alphanumeric[fqdn_rand(size($alphanumeric), "${i}_path_${d}_${p}")]
        }
        join($part_chars, '')
      }
      $rel_path = join($path_parts, '/')
      $full_path = "${base_path}/${rel_path}"
    } else {
      $full_path = "${base_path}/${name}"
    }

    # Generate random content for files
    if $is_file {
      $content_length = fqdn_rand($max_content_length, "${i}_content") + 10
      $content_chars = range(1, $content_length).map |$c| {
        $alphanumeric[fqdn_rand(size($alphanumeric), "${i}_content_${c}")]
      }
      $content = join($content_chars, '')
    } else {
      $content = undef
    }

    # Select random owner and group
    $owner = $owners[fqdn_rand(size($owners), "${i}_owner")]
    $group = $groups[fqdn_rand(size($groups), "${i}_group")]

    # Select random mode
    $mode = $is_file ? {
      true  => $file_modes[fqdn_rand(size($file_modes), "${i}_mode")],
      false => $dir_modes[fqdn_rand(size($dir_modes), "${i}_mode")],
    }

    # Create a random managed_file resource
    load_test::managed_file { "random_file_${i}":
      ensure  => $ensure,
      path    => $full_path,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => $content,
      recurse => $ensure ? {
        'directory' => fqdn_rand(2, "${i}_recurse") == 0,
        default     => false,
      },
      force   => fqdn_rand(2, "${i}_force") == 0,
    }

    # If we're creating subdirectories, make sure parent directories exist
    if $create_subdirs {
      $parent_dirs = reduce(split($rel_path, '/')) |$memo, $dir| {
        $memo + ["${memo[-1]}/${dir}"]
      }

      $parent_dirs.each |$parent_dir| {
        # Ensure parent directories exist
        ensure_resource('file', "${base_path}${parent_dir}", {
            ensure => directory,
            before => Load_test::Managed_file["random_file_${i}"],
        })
      }
    }
  }
}
