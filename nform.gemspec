Gem::Specification.new do |s|
  s.name        = 'nform'
  s.version     = '1.0.0'
  s.date        = '2015-01-10'
  s.summary     = 'A form library'
  s.description = 'A nifty form builder and such.'
  s.authors     = ["Andrew Burleson"]
  s.email       = 'burlesona@gmail.com'
  s.files       = Dir["{lib}/**/*.rb"]
  s.homepage    = 'http://github.com/burlesona/nform'
  s.license     = 'MIT'
  s.add_runtime_dependency 'activesupport', '~>4.0'
end
