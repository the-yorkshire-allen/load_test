# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include load_test
#
# @param file_count
#   The number of file resources to create
# @param service_count
#   The number of service resources to create
# @param package_count
#   The number of package resources to create
# @param user_count
#   The number of user resources to create
# @param group_count
#   The number of group resources to create
#
# file resources specifics
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
# service / package resources specifics
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
# user resources specifics
# @param create_homes
#   Ratio of users that should have home directories (0.8 means 80% have homes)
# @param system_user_ratio
#   Ratio of system to regular users (0.3 means 30% system users)
# @param user_ensure_ratio
#   Ratio of present to absent users (0.9 means 90% present, 10% absent)
# @param password_max_age
#   Maximum password age to use for password aging
# @param create_ssh_keys
#   Ratio of users that should have SSH keys (0.6 means 60% have SSH keys)
# @param uid_gid_min
#   Minimum UID/GID to use for users and groups
# @param uid_gid_max
#   Maximum UID/GID to use for users and groups
class load_test (
  Integer[1] $file_count                 = 30,
  Integer[1] $service_count              = 20,
  Integer[1] $package_count              = 50,
  Integer[1] $user_count                 = 20,
  Integer[1] $group_count                = 20,
  # file specific
  Optional[String] $base_path            = undef, # OS specific, see module hiera
  Float[0.0, 1.0] $file_ratio            = 0.7,
  Integer[10, 10000] $max_content_length = 1000,
  Boolean $create_subdirs                = true,
  Integer[1, 10] $max_depth              = 3,
  # service / package specific
  Float[0.0, 1.0] $service_ensure_ratio  = 0.8,
  Float[0.0, 1.0] $package_ensure_ratio  = 0.9,
  Float[0.0, 1.0] $service_enable_ratio  = 0.7,
  Boolean $multi_provider                = true,
  Boolean $delay_random                  = true,
  # user specific
  Float[0.0, 1.0] $create_homes          = 0.8,
  Float[0.0, 1.0] $system_user_ratio     = 0.3,
  Float[0.0, 1.0] $user_ensure_ratio     = 0.9,
  Integer[1] $password_max_age           = 90,
  Float[0.0, 1.0] $create_ssh_keys       = 0.6,
  Integer[1] $uid_gid_min                = 1000,
  Integer[1] $uid_gid_max                = 60000,
) {
  class { 'load_test::random_files':
    count              => $file_count,
    base_path          => $base_path,
    file_ratio         => $file_ratio,
    max_content_length => $max_content_length,
    create_subdirs     => $create_subdirs,
    max_depth          => $max_depth,
  }

  class { 'load_test::random_services_packages':
    service_count        => $service_count,
    package_count        => $package_count,
    service_ensure_ratio => $service_ensure_ratio,
    package_ensure_ratio => $package_ensure_ratio,
    service_enable_ratio => $service_enable_ratio,
    multi_provider       => $multi_provider,
    delay_random         => $delay_random,
  }

  class { 'load_test::random_users':
    user_count        => $user_count,
    group_count       => $group_count,
    create_homes      => $create_homes,
    system_user_ratio => $system_user_ratio,
    user_ensure_ratio => $user_ensure_ratio,
    password_max_age  => $password_max_age,
    create_ssh_keys   => $create_ssh_keys,
    uid_gid_min       => $uid_gid_min,
    uid_gid_max       => $uid_gid_max,
  }
}
