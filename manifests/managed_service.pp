# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   load_test::managed_service { 'namevar': }
# Create a defined type for managed services
define load_test::managed_service (
  Enum['running', 'stopped'] $ensure = 'running',
  Boolean $enable = true,
  Optional[String] $provider = undef,
  Boolean $hasstatus = true,
  Boolean $hasrestart = true,
) {
  service { $title:
    ensure     => $ensure,
    enable     => $enable,
    provider   => $provider,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
  }
}
