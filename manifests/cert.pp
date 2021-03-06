# Type: certmgmt::keypair
# ===========================
#
# The defined type `certmgmt::keypair` enrolls a certificate from the given
# parameters. You may include a certificate chain within the certificate file.
# A private key can be enrolled, too, either within the file or as a seperate file.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Examples
# --------
#
# @example
#    class { 'certmgmt':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Oliver Bertuch <oliver@bertuch.eu>
#
# Copyright
# ---------
#
# Copyright 2016 Oliver Bertuch
#
define certmgmt::cert (
  NotUndef[Certmgmt::X509PEM] $x509,
  Optional[Enum['present','absent']] $ensure = 'present',
  Optional[Certmgmt::KeyPem] $key = undef,
  Optional[Variant[
      Certmgmt::X509PEM,
      Hash[String[1],Certmgmt::X509PEM,1]
    ]] $chain = undef,
  Optional[Variant[
      Boolean,
      Enum['key+cert','cert+chain']
    ]] $combined = false,
  Optional[String[1]] $file = "${certmgmt::certpath}/${title}.pem",
  Optional[String[1]] $chainfile = "${certmgmt::certpath}/${title}.chain.pem",
  Optional[String[1]] $keyfile = "${certmgmt::keypath}/${title}.key.pem",
  Optional[String[1]] $owner = 'root',
  Optional[String[1]] $group = 'root',
  Optional[Pattern[/\A0[0-7]{3}\Z/]] $mode = '0600',
) {

  ### PARAMETER VALIDATION + NORMALISATION
  if $ensure == 'present' {
    $_ensure = 'file'
  } else {
    $_ensure = $ensure
  }
  validate_absolute_path($file)
  validate_absolute_path($chainfile)
  validate_absolute_path($keyfile)

  ### VALIDATE CERTIFICATES
  if $x509 and $ensure == 'present' {
    certmgmt::validate_x509($x509)
  }
  # chain might be multiple certs!
  if $chain and $ensure == 'present' {
    certmgmt::validate_x509($x509, $chain)
  }
  if $key and $ensure == 'present' {
    certmgmt::validate_keypair($name, $x509, $key)
  }

  ### OUTPUT
  # if a combined file should be generated, put the private key first
  if $combined == true or $combined == 'key+cert' {
    $_onefile = "${key}${x509}"
    $diff = false
  } else {
    $_onefile = $x509
    $diff = true
  }

  # if the user sends us a multiple certs as a chain in a hash structure,
  # join the stuff by using link breaks
  if $chain.is_a(Hash)  {
    $_chain = join(values($chain))
  } else {
    $_chain = $chain
  }
  # if there is a chain present, append it to the cert
  if $chain and $combined == true {
    $_cert = "${_onefile}${_chain}"
  } elsif $chain and $combined == 'cert+chain' {
    $_cert = "${x509}${_chain}"
  } else {
    $_cert = $_onefile
  }

  file { $file:
    ensure    => $_ensure,
    content   => $_cert,
    mode      => $mode,
    owner     => $owner,
    group     => $group,
    show_diff => $diff,
  }

  # if the user did not want a single (combined) file, write the private key
  if $combined == false or $combined == 'cert+chain' or $ensure == 'absent' {
    file { $keyfile:
      ensure    => $_ensure,
      content   => $key,
      mode      => '0600',
      owner     => $owner,
      group     => $group,
      show_diff => false,
    }
  } elsif $ensure == 'absent' {
    file { $keyfile:
      ensure    => $_ensure,
      show_diff => false,
    }
  }

  # if the chainfile should be separate, do so...
  if $combined == false or $combined == 'key+cert' {
    file { $chainfile:
      ensure  => $_ensure,
      content => $_chain,
      mode    => '0600',
      owner   => $owner,
      group   => $group,
    }
  } elsif $ensure == 'absent' {
    file { $chainfile:
      ensure => $_ensure,
    }
  }
}
