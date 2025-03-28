# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   load_test::managed_files { 'namevar': }
define load_test::managed_file (
  Enum['file', 'directory', 'absent'] $ensure = 'file',
  Optional[String] $path              = undef,
  String $owner                       = 'root',
  String $group                       = 'root',
  Optional[String] $mode              = undef,
  Optional[String] $content           = undef,
  Optional[String] $source            = undef,
  Boolean $recurse                    = false,
  Boolean $force                      = false,
) {
  # Set defaults based on whether this is a file or directory
  $_path = $path ? {
    undef   => $title,
    default => $path,
  }

  $_mode = $mode ? {
    undef   => $ensure ? {
      'directory' => '0755',
      'file'      => '0644',
      default     => undef,
    },
    default => $mode,
  }

  # Validate parameters
  if $ensure == 'file' and $content != undef and $source != undef {
    fail('You cannot specify both content and source for a file resource')
  }

  if $ensure == 'directory' and $content != undef {
    warning('Content parameter is ignored for directories')
  }

  # Create the file resource with appropriate parameters
  file { $_path:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $_mode,
    content => $ensure ? {
      'file'  => $content,
      default => undef,
    },
    source  => $ensure ? {
      'file'  => $source,
      default => undef,
    },
    recurse => $ensure ? {
      'directory' => $recurse,
      default     => undef,
    },
    force   => $ensure ? {
      'absent' => $force,
      default  => undef,
    },
  }
}
