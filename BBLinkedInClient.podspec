Pod::Spec.new do |s|

	s.name 			=  	'BBLinkedInClient'
	s.version		= 	'0.0.1'
	s.summary		=	'LinkedIn API Client. oAuth 2 authentication. Wrappers on some of the endpoints :).'
	s.author		=	{ 'Martin Fernandez' => 'fmartin91@gmail.com' }
			
	s.homepage		= 	''

	s.license		=	{ type: 'MIT', file:'LICENSE' }

	s.source		= 	{  }

	s.dependency		'AFNetworking'
	s.platform		= 	:ios, '7.0'
	

	s.source_files 	= 	'Classes/*.{h,m}' 
	s.requires_arc 	= 	true

end