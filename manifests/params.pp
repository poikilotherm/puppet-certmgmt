# Class: certmgmt::params
# ===========================
#
# Full description of class certmgmt here.
#
# Authors
# -------
#
#   Oliver Bertuch <oliver@bertuch.eu> 
#
# Copyright
# ---------
#
# Copyright 2016 Oliver Bertuch 
#
class certmgmt::params {
  case 
  $certpath = '/etc/pki/tls/certs'
  $keypath  = '/etc/pki/tls/private'


}
