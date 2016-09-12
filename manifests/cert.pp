# Type: certmgmt::cert
# ===========================
#
# The defined type `certmgmt::cert` enrolls a certificate from the given
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
  $cert,
  $ensure   = 'present',
  $key      = undef,
  $chain    = undef,
  $onefile  = false,
  $certfile = "${::certmgmt::certpath}/${title}.pem",
  $keyfile  = "${::certmgmt::keypath}/${title}.key.pem",
  $owner    = $::certmgmt::owner,
  $group    = $::certmgmt::group,
  $mode     = $::certmgmt::mode,
) {
  include ::certmgmt::params

  ### PARAMETER VALIDATION + NORMALISATION
  validate_string($cert)
  validate_re($ensure, ['absent','present'])
  if $ensure == 'present' {
    $_ensure = 'file'
  } else {
    $_ensure = $ensure
  }
  validate_string($key)

  # if the user sends us a multiple certs as a chain in an array structure,
  # join the stuff by using link breaks
  if is_array($chain) {
    $_chain = join($chain, '\n')
    validate_string($_chain)
  } else {
    validate_string($chain)
    $_chain = $chain
  }
  validate_boolean($onefile)
  validate_absolute_path($certfile)
  validate_absolute_path($keyfile)

  ### VALIDATE CERTIFICATES
  if $cert and $ensure == 'present' {
    exec { "cert: test ${title} certificate":
      command => "echo '${cert}' | openssl x509 -inform PEM -noout",
      tag     => 'cert::testtag',
    }
  }
  # chain might be multiple certs!
  if $_chain and $ensure == 'present' {
    exec { "cert: test ${title} chain":
      command => "echo '${_chain}' | openssl verify",
      tag     => 'cert::testtag',
    }
  }
  # TODO: what about DSA keys?
  if $key and $ensure == 'present' {
    exec { "cert: test ${title} key":
      command => "echo '${key}' | openssl rsa -inform PEM -noout",
      tag     => 'cert::testtag',
    }
  }

  ### OUTPUT
  # if only a combined file should be generated, put the private key first
  if $onefile {
    $_onefile = "${key}${cert}"
  } else {
    $_onefile = $cert
  }
  # if there is a chain present, append it to the cert
  if $chain != undef {
    $_cert = "${_onefile}${chain}"
  } else {
    $_cert = $_onefile
  }

  file { $certfile:
    ensure    => $_ensure,
    content   => $_cert,
    mode      => $mode,
    owner     => $owner,
    group     => $group,
    show_diff => !$onefile, # if onefile is true, do not show diffs to protect the private key!
  }

  # if the user did not want a single (combined) file, write the private key
  if ! $onefile {
    file { $keyfile:
      ensure    => $_ensure,
      content   => $key,
      mode      => '0600',
      owner     => $owner,
      group     => $group,
      show_diff => false,
    }
  }

  ### ORDERING
  anchor { "cert::${title}::start": } ->
  Exec<| tag == 'cert::testtag' |> ->
  File[$_certfile] ->
  File[$_keyfile] ->
  anchor { "cert::${title}::end": }
}
