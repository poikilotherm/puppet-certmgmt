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
  NotUndef[String[1]] $x509,
  Optional[Enum['present','absent']] $ensure = 'present',
  Optional[String[1]] $key = undef,
  Optional[Variant[String[1],Array[String[1],1]]] $chain = undef,
  Optional[Boolean] $combined = false,
  Optional[String[1]] $file = "${certmgmt::certpath}/${title}.pem",
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
  # if the user sends us a multiple certs as a chain in an array structure,
  # join the stuff by using link breaks
  if $chain.is_a(Array[String])  {
    $_chain = join($chain, '\n')
  } else {
    $_chain = $chain
  }
  validate_absolute_path($file)
  validate_absolute_path($keyfile)

  ### VALIDATE CERTIFICATES
  if $x509 and $ensure == 'present' {
    exec { "cert: test ${title} certificate":
      command => "echo '${x509}' | openssl x509 -inform PEM -noout",
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
  #if $key and $ensure == 'present' {
    #validate_x509_rsa_key_pair($x509, $key)
  #}

  ### OUTPUT
  # if only a combined file should be generated, put the private key first
  if $combined {
    $_onefile = "${key}${x509}"
  } else {
    $_onefile = $x509
  }
  # if there is a chain present, append it to the cert
  if $chain != undef {
    $_cert = "${_onefile}${chain}"
  } else {
    $_cert = $_onefile
  }

  file { $file:
    ensure    => $_ensure,
    content   => $_cert,
    mode      => $mode,
    owner     => $owner,
    group     => $group,
    show_diff => !$combined, # if combined is true, do not show diffs to protect the private key!
  }

  # if the user did not want a single (combined) file, write the private key
  if ! $combined {
    file { $keyfile:
      ensure    => $_ensure,
      content   => $key,
      mode      => '0600',
      owner     => $owner,
      group     => $group,
      show_diff => false,
    }
  }
}
