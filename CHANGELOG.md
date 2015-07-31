# NForm Changelog

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
