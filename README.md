# NForm
[![Build Status](https://travis-ci.org/burlesona/nform.svg?branch=master)](https://travis-ci.org/burlesona/nform)
[![Code Climate](https://codeclimate.com/github/burlesona/nform/badges/gpa.svg)](https://codeclimate.com/github/burlesona/nform)

NForm is a utility library for form objects and views. It is composed of several classes that are quite useful
independently, and when combined create a complete solution for handling user input in web applications.

NForm aims to be light, simple, and direct. There's not much magic in the codebase, making it
easier for users of the library to modify, extend, and adapt it as needed.

Requires Ruby >= 2.1.x.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nform'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nform

Finally, in your app:

```ruby
require 'nform'
```

*Note:* NForm utilizes some core extensions from ActiveSupport. It does not load the entire ActiveSupport library,
but does require ActiveSupport >= 4.0 to be present.

## Usage

### NForm::Attributes

NForm::Attributes provides a simple interface for defining object properties with behavior. Example:

```ruby
class Model
  extend NForm::Attributes
  attribute :name, coerce: :to_string, required: true
  attribute :type, coerce: :to_string, default: "gizmo"
  attribute :thing, coerce: proc{|input| input if input.is_a?(Thing) }
end

model = Model.new(name:"Foo")
model.name #=> "Foo"
model.type #=> "gizmo"
model.thing = "fail" #=> nil
model.thing = Thing.new
model.thing #=> #<Thing:...>
```

TODO: Expand docs

### NForm::Coercions

NForm::Coercions is a hash-like set of procs that take some input, and return some output,
most commonly typecasting. This set allows easy sharing of common transformations, such as:

```ruby
NForm::Coercions[:to_string] = proc{|input| input.to_s }
```

The names of each coercion can be given as symbols in an NForm::Attributes model, and can be
chained to form a procedure. For instance:

```ruby
NForm::Coercions[:to_string]   = proc{|input| input.to_s }
NForm::Coercions[:to_presence] = proc{|input| input.presence }

class Model
  extend NForm::Attributes
  attribute :maybe_empty_string, coerce: :to_string
  attribute :not_empty_string, coerce: [:to_string,:to_presence]
end

model = Model.new(maybe_empty_string: "", not_empty_string: "")
model.maybe_empty_string #=> ""
model.not_empty_string #=> nil
```

TODO: Expand docs

### NForm::Validations

NForm::Validations are a set of common validation methods that can be used in an object.

Including objects are required to implement a simple API:
1. Keys passed in to a validation must match instance method names
2. Objects must use the provided `errors` method and instance variable, or override it
   with something that has the same interface as a Hash.

When called, the methods will return true/false indicating whether the validation passed or failed,
and the errors hash will be populated with method name and error messages as keys and values.

TODO: Expand docs

### NForm::HTML

NForm::HTML is a simple DSL for assembling HTML strings. It's really just one method: `tag`, which
takes a hash of options and a block of content. The method is designed to write html tags and attributes
correctly, including void elements like `<img>` and boolean attributes like `checked`.

```ruby
tag('a',href:"https://www.github.com", class:"button"){ "Github" }
#=> "<a href=\"https://www.github.com\" class="button">Github</a>
```

TODO: Expand docs

### NForm::Builder

NForm::Builder is a DSL for rendering forms from form objects.

TODO: Expand docs

### NForm::Helpers

NForm::Helpers includes convenience methods for web application front-ends. Currently it's
just one method, `form_view`, which is a shortcut for:

```ruby
NForm::Builder.new(...).render
```

TODO: Expand docs

## Development

See changelog for version history.

NForm follows semantic versioning. During the 0.x series, minor version changes may
introduce backwards incompatible changes. These will be noted in the changelog.

## Contributing

1. Fork it and create a feature branch
2. INCLUDE TEST COVERAGE
3. Make sure all tests pass
4. Send a pull request
