# NForm Changelog

## 1.1.0
- New feature on Attributes: `hash_representation`
  Two options: :complete, or :partial. :complete is the default (for backward compatibility).
  When :partial is selected, the #to_hash method returns only the keys
  that have been touched by hash or by using setter methods.

## 1.0.2
- Bugfix: In NForm::Service, form_class should be a class instance variable not a class variable.

## 1.0.1
- Update gemspec, requires version bump :(

## 1.0.0
- Add Service and Form, together these complete the backend portion of
  NForm, packaging up all the code we use to build apps around composable,
  callable services.
- Publish to RubyGems `gem install nform`

## 0.3.1
- Add `text` option to submit buttons.

## 0.3.0
- Add scope argument to coercion procs to provide a way to get to instance methods in attribute setters

## 0.2 Series

- Add common coercions
- Refactor Attributes
- Redo coercion code in Attributes: procs can still be passed, but methods in the host object
  are not looked up (which pollutes the namespace and makes it hard to share common coercions).
  Instead coercions are defined in NForm::Coercions. Custom coercions can be added to this set
  and shared throughout an application.
- Add a new option to pass an array of symbols to perform chained coercions.


## 0.1 Series

Early development period, built out the initial feature set:

- Attributes: adds loose typing to ruby objects
- Validations: a collection of validation methods convenient for form objects
- HTML: a simple dsl for rendering DOM elements
- Builder: a more robust DSL for rendering forms from form objects
- Helpers: optional convenience methods, generally shortcuts for common NForm usage
