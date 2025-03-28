# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include load_test::managed_user
define load_test::managed_user (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[String] $comment = undef,
  Optional[String] $home = undef,
  Optional[Integer] $uid = undef,
  Optional[String] $gid = undef,
  Array[String] $groups = [],
  Boolean $managehome = true,
  String $shell = '/bin/bash',
  Boolean $system = false,
  Optional[Integer] $password_max_age = undef,
  Boolean $purge_ssh_keys = false,
) {
  user { $title:
    ensure           => $ensure,
    comment          => $comment,
    home             => $home,
    uid              => $uid,
    gid              => $gid,
    groups           => $groups,
    managehome       => $managehome,
    shell            => $shell,
    system           => $system,
    password_max_age => $password_max_age,
    purge_ssh_keys   => $purge_ssh_keys,
  }
}
