Gem::Specification.new do |s|
  s.name        = 'nform'
  s.version     = '1.1.1'
  s.date        = '2016-02-12'
  s.summary     = 'A form / view / service object library.'
  s.description = 'A toolbelt for for generating flexible, composable form and view objects.'
  s.authors     = ["Andrew Burleson"]
  s.email       = 'burlesona@gmail.com'
  s.files       = Dir["{lib}/**/*.rb"]
  s.homepage    = 'http://github.com/burlesona/nform'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.1'
  s.add_runtime_dependency 'activesupport', '~>4.0'
end
