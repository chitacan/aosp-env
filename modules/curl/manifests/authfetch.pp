################################################################################
# Definition: curl::authfetch
#
# This class will download files from the internet.  You may define a web proxy
# using $http_proxy if necessary. Username must be provided. And the user's
# password must be stored in the password variable within the .curlrc file.
#
################################################################################
define curl::authfetch($source,$destination,$user,$password="",$timeout="0",$verbose=false) {
  include curl
  if $http_proxy {
    $environment = [ "HTTP_PROXY=$http_proxy", "http_proxy=$http_proxy" ]
  }
  else {
    $environment = []
  }

  $verbose_option = $verbose ? {
    true  => "--verbose",
    false => "--silent --show-error"
  }

  file { "/tmp/curlrc-$name":
    owner   => root,
    mode    => "0600",
    content => "user = $user:$password",
  } ->
  exec { "curl-$name":
    command     => "curl $verbose_option --config /tmp/curlrc-$name --output $destination $source",
    timeout     => $timeout,
    unless      => "test -s $destination",
    environment => $environment,
    path        => "/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin",
    require     => Class[curl],
  }
}

