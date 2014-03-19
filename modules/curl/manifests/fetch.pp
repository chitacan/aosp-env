################################################################################
# Definition: curl::fetch
#
# This class will download files from the internet.  You may define a web proxy
# using $http_proxy if necessary.
#
################################################################################
define curl::fetch($source,$destination,$timeout="0",$verbose=false) {
  include curl

  if $::http_proxy {
    $environment = [ "HTTP_PROXY=$::http_proxy", "http_proxy=$::http_proxy" ]
  }
  else {
    $environment = []
  }

  $verbose_option = $verbose ? {
    true  => "--verbose",
    false => "--silent --show-error"
  }

  exec { "curl-$name":
    command     => "curl $verbose_option --output $destination $source",
    timeout     => $timeout,
    unless      => "test -s $destination",
    environment => $environment,
    path        => "/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin",
    require     => Class[curl],
  }
}
