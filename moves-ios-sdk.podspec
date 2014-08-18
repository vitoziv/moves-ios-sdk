Pod::Spec.new do |s|
  s.name     = 'moves-ios-sdk'
  s.version  = '0.2.3'
  s.platform = :ios,'6.1'
  s.license  = 'https://github.com/vitoziv/moves-ios-sdk/blob/master/LICENSE'
  s.summary  = 'Moves app iOS SDK '
  s.homepage = 'https://github.com/vitoziv/moves-ios-sdk'
  s.author   = { 
    'Vito Zhang' => 'vvitozhang@gmail.com'
  }
  s.requires_arc = true
  s.source   = { 
    :git => 'https://github.com/vitoziv/moves-ios-sdk.git',
    :tag => '0.2.3'
  }
  s.source_files = 'moves-ios-sdk/*.{h,m}',
    'moves-ios-sdk/models/**/*.{h,m}',
    'moves-ios-sdk/internal/**/*.{h,m}'

end
