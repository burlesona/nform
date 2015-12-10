# NForm
[![Build Status](https://travis-ci.org/burlesona/nform.svg?branch=master)](https://travis-ci.org/burlesona/nform)
[![Code Climate](https://codeclimate.com/github/burlesona/nform/badges/gpa.svg)](https://codeclimate.com/github/burlesona/nform)

NForm is a utility library to help you build form objects, services, and views. It is composed of
several classes that are quite useful independently, and when combined create a complete solution
for handling user input and interaction in ruby applications.

NForm aims to be light, simple, and direct. There's not much magic in the codebase, making it
easier for users of the library to modify, extend, and adapt it as needed.

Requires Ruby >= 2.1.x.

The docs are still somewhat a work in progress, but the code is easy to read, and the tests cover
all the behavior and illustrate how everything works.

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

*New in 0.3.x:*

Sometimes it's helpful to be able to define a coercion in an instance method, perhaps if the object
has state that affects what values can be set. For this reason an optional second parameter is passed into each
coercion proc with a reference to the instance. You can therefore define a proc coercion that calls a method like this:

```
class MyObject
  extend NForm::Attributes
  attribute :something, coerce: proc{|input,instance| instance.send(:set_something,input) }

  private
  def set_something(input)
    if @something_locked
      raise "This attribute is currently locked and cannot be set"
    else
      input
    end
  end
end
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

### NForm::Form

Using attributes, coercions, and validations, we now have everything we need for sweet Form Objects,
which work like so:

```ruby
class MyForm < NForm::Form
  attribute :tester, required: true
  attribute :stringy, coerce: :to_string
  attribute :number, coerce: :to_integer, default: 0

  def validate!
    errors[:number] = "Must not be negative" if number < 0
    super
  end
end

f = MyForm.new #=> Argument Error: Missing `tester`
f = MyForm.new tester: 'foo', stringy: 'abc', number: -100
f.valid? #=> false
f.errors #=> {number: "Must not be negative"}
f.number = 10
f.valid? #=> true
f.to_hash #=> {tester: 'foo', stringy: 'abc', number: 10}

```
TODO: Expand Docs

### NForm::Service

NForm Service is more convention than code. It defines a handy syntactic sugar whereby
you can instantiate a callable and call it in one step. It also expects you to use a form
object for input and makes that very easy for you to do.

See the tests for more examples.

TODO: Expand Docs and add rationale


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
