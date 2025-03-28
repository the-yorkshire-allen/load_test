# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   load_test::managed_package { 'namevar': }
# Create a defined type for managed packages
define load_test::managed_package (
  Variant[Enum['present', 'installed', 'absent', 'purged', 'held', 'latest'], String] $ensure = 'installed',
  Optional[String] $version = undef,
  Optional[String] $source = undef,
  Optional[String] $provider = undef,
) {
  package { $title:
    ensure   => $ensure,
    name     => $title,
    version  => $version,
    source   => $source,
    provider => $provider,
  }
}
