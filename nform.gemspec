Gem::Specification.new do |s|
  s.name        = 'nform'
  s.version     = '1.0.2'
  s.date        = '2015-12-14'
  s.summary     = 'A form / service / view object library.'
  s.description = 'A library for generating composable callable services with form objects and views for handling user input and interaction.'
  s.authors     = ["Andrew Burleson"]
  s.email       = 'burlesona@gmail.com'
  s.files       = Dir["{lib}/**/*.rb"]
  s.homepage    = 'http://github.com/burlesona/nform'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.1'
  s.add_runtime_dependency 'activesupport', '~>4.0'
end
