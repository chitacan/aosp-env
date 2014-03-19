A Puppet module to download files with curl, supporting authentication.

# Example

	include curl
	
	curl::fetch { "download":
	  source      => "http://www.google.com/index.html",
	  destination => "/tmp/index.html",
	  timeout     => 0,
	  verbose     => false,
	}
	
	curl::authfetch { "download":
	  source      => "http://www.google.com/index.html",
	  destination => "/tmp/index.html",
	  user        => "user",
	  password    => "password",
	  timeout     => 0,
	  verbose     => false,
	}

# License

Copyright (c) 2013 Government Digital Services

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
