# @summary Creates multiple managed user resources with random data
#
# This class demonstrates how to create multiple user resources
# with randomized data. It's useful for load testing Puppet catalogs.
#
# @param user_count
#   The number of user resources to create
# @param group_count
#   The number of group resources to create
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
#
# @example Creating random users and groups
#   class { 'load_test::random_users':
#     user_count  => 50,
#     group_count => 20,
#   }
#
class load_test::random_users (
  Integer[0] $user_count           = 50,
  Integer[0] $group_count          = 20,
  Float[0.0, 1.0] $create_homes    = 0.8,
  Float[0.0, 1.0] $system_user_ratio = 0.3,
  Float[0.0, 1.0] $user_ensure_ratio = 0.9,
  Integer[0] $password_max_age     = 90,
  Float[0.0, 1.0] $create_ssh_keys = 0.6,
  Integer[0] $uid_gid_min          = 1000,
  Integer[0] $uid_gid_max          = 60000,
) {
  # Define common first names for realistic usernames
  $first_names = [
    'james', 'john', 'robert', 'michael', 'william', 'david', 'richard', 'joseph',
    'thomas', 'charles', 'christopher', 'daniel', 'matthew', 'anthony', 'mark',
    'donald', 'steven', 'paul', 'andrew', 'joshua', 'kenneth', 'kevin', 'brian',
    'mary', 'patricia', 'jennifer', 'linda', 'elizabeth', 'barbara', 'susan',
    'jessica', 'sarah', 'karen', 'lisa', 'nancy', 'betty', 'margaret', 'sandra',
    'ashley', 'emily', 'donna', 'michelle', 'laura', 'sarah', 'kimberly', 'emma',
  ]

  # Define common last names for realistic usernames
  $last_names = [
    'smith', 'johnson', 'williams', 'brown', 'jones', 'miller', 'davis', 'garcia',
    'rodriguez', 'wilson', 'martinez', 'anderson', 'taylor', 'thomas', 'hernandez',
    'moore', 'martin', 'jackson', 'thompson', 'white', 'lopez', 'lee', 'gonzalez',
    'harris', 'clark', 'lewis', 'robinson', 'walker', 'perez', 'hall', 'young',
    'allen', 'sanchez', 'wright', 'king', 'scott', 'green', 'baker', 'adams',
    'nelson', 'hill', 'ramirez', 'campbell', 'mitchell', 'roberts', 'carter',
  ]

  # Define common departments for grouping
  $departments = [
    'engineering', 'sales', 'marketing', 'finance', 'hr', 'support',
    'operations', 'development', 'qa', 'design', 'research', 'product',
    'management', 'security', 'legal', 'administration', 'infrastructure',
  ]

  # Define shells
  $shells = [
    '/bin/bash', '/bin/sh', '/bin/zsh', '/bin/ksh', '/bin/dash',
    '/usr/bin/fish', '/sbin/nologin', '/bin/false',
  ]

  # Generate random groups first
  range(1, $group_count).each |$i| {
    # Choose a random department
    $dept_idx = fqdn_rand(size($departments), "${i}_group_dept")
    $department = $departments[$dept_idx]

    # Decide if system group
    $is_system = fqdn_rand(100, "${i}_group_system") < ($system_user_ratio * 100)

    # Generate GID
    $gid = $is_system ? {
      true  => fqdn_rand(999, "${i}_group_gid") + 100,
      false => fqdn_rand($uid_gid_max - $uid_gid_min, "${i}_group_gid") + $uid_gid_min,
    }

    # Random ensure (present or absent)
    $is_present = fqdn_rand(100, "${i}_group_present") < ($user_ensure_ratio * 100)
    $ensure = $is_present ? {
      true  => 'present',
      false => 'absent',
    }

    # Create group resource
    group { "test_group_${department}_${i}":
      ensure => $ensure,
      name   => $department,
      gid    => $gid,
      system => $is_system,
    }
  }

  # Generate random user resources
  range(1, $user_count).each |$i| {
    # Generate a realistic username
    $first_idx = fqdn_rand(size($first_names), "${i}_first")
    $last_idx = fqdn_rand(size($last_names), "${i}_last")
    $first_name = $first_names[$first_idx]
    $last_name = $last_names[$last_idx]

    # Decide on the username pattern (50% first initial + last name, 50% full first name + last initial)
    $username_pattern = fqdn_rand(2, "${i}_pattern")
    $username = $username_pattern ? {
      0       => "${first_name[0,1]}${last_name}",
      default => "${first_name}${last_name[0,1]}",
    }

    # Random ensure (present or absent)
    $is_present = fqdn_rand(100, "${i}_present") < ($user_ensure_ratio * 100)
    $ensure = $is_present ? {
      true  => 'present',
      false => 'absent',
    }

    # Random system user
    $is_system = fqdn_rand(100, "${i}_system") < ($system_user_ratio * 100)

    # Generate UID
    $uid = $is_system ? {
      true  => fqdn_rand(999, "${i}_uid") + 100,
      false => fqdn_rand($uid_gid_max - $uid_gid_min, "${i}_uid") + $uid_gid_min,
    }

    # Random home directory
    $has_home = fqdn_rand(100, "${i}_has_home") < ($create_homes * 100)
    $home = $has_home ? {
      true  => "/home/${username}",
      false => undef,
    }

    # Random manage_home
    $manage_home = $has_home

    # Random shell
    $shell_idx = $is_system ? {
      true  => fqdn_rand(2, "${i}_shell") + 6, # last two shells are nologin and false
      false => fqdn_rand(6, "${i}_shell"),     # regular shells
    }
    $shell = $shells[$shell_idx]

    # Random comment/GECOS field
    $comment = "${first_name.capitalize} ${last_name.capitalize}"

    # Random password max age
    $password_age = fqdn_rand($password_max_age, "${i}_pwd_age") + 30 # between 30 and max+30 days

    # Random primary group
    $dept_idx = fqdn_rand(size($departments), "${i}_dept")
    $primary_group = $departments[$dept_idx]

    # Random membership in other groups (0-3 additional groups)
    $num_groups = fqdn_rand(4, "${i}_num_groups")
    $group_idxs = range(0, $num_groups).map |$g| {
      fqdn_rand(size($departments), "${i}_group_${g}")
    }
    $group_list = $group_idxs.map |$g| { $departments[$g] }
    $groups = $group_list.unique  # Remove duplicates

    # SSH key generation
    $has_ssh_key = fqdn_rand(100, "${i}_has_ssh") < ($create_ssh_keys * 100)

    # Create user resource
    user { "test_user_${username}_${i}":
      ensure           => $ensure,
      name             => $username,
      uid              => $uid,
      gid              => $primary_group,
      groups           => $groups,
      comment          => $comment,
      home             => $home,
      managehome       => $manage_home,
      shell            => $shell,
      system           => $is_system,
      password_max_age => $password_age,
      purge_ssh_keys   => $has_ssh_key,
    }

    # Create SSH key if needed
    if $has_ssh_key and $has_home and $is_present {
      $key_type = fqdn_rand(4, "${i}_key_type") ? {
        0       => 'ssh-rsa',
        1       => 'rsa',
        2       => 'ecdsa',
        default => 'ed25519',
      }

      # Generate random SSH key content (this is not a real key, just a placeholder)
      $key_content = fqdn_rand_string(372, "${i}_key_content", 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/')

      ssh_authorized_key { "${username}_${i}_key":
        ensure  => present,
        user    => $username,
        type    => $key_type,
        key     => $key_content,
        require => User["test_user_${username}_${i}"],
      }
    }
  }
}
