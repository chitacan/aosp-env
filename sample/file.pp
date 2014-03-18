file { 'one':
	path => '/vagrant/one',
	content => 'one',
	# before => File['two']
}
file { 'two':
	path => '/vagrant/two',
	source => '/vagrant/one',
	require => File['one']
}

# File['one'] -> File['two']
# File['one'] <- File['two']
