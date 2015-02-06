[![Gem Version](https://badge.fury.io/rb/modware.svg)](http://badge.fury.io/rb/modware)
[![Build Status](https://secure.travis-ci.org/SchemaPlus/modware.svg)](http://travis-ci.org/SchemaPlus/modware)
[![Coverage Status](https://img.shields.io/coveralls/SchemaPlus/modware.svg)](https://coveralls.io/r/SchemaPlus/modware)

# Modware

Modware is a library for using middleware (pipeline) patterns in Ruby projects.  It features a simple interface and supports "callback" style semantics in the middleware stack, including `before`, `after`, and `around` methods.


## Installation

As usual:

```ruby
gem 'modware'                   # in a Gemfile
spec.add_dependency 'modware'   # in a .gemspec
```

## Usage

### Creating a stack

Create a stack using:

```ruby
stack = Modware::Stack.new(env_class)
```

where `env_class` is a Class for the environment instance that will be passed to the layers of the stack.  As a shorthand for the common case, you can simply pass an array of keys, e.g.

```ruby
stack = Modware::Stack.new([:name, :options, :results])
```

and Modware will define a class that accepts those keys as keyword arguments, and has accessor methods for each (see 
[`KeyStruct`](https://rubygems.org/gems/key_struct)).


### Defining middleware

Middleware is defined as a module, that defines one or more middleware methods:

```ruby
module MyMiddleware

  # define any of these as needed...

  def before(env)
    # code to be called before the base implementation
  end

  def after(env)
    # code to be called after the base implementation
  end

  def around(env)
    # setup/wrapper code
    yield env # continues execution down the stack
    # cleanup code
  end

  def implement(env)
    # completely replaces the base implementation or any earlier middleware's implement()
  end
end
```

The module may use instance variables and define other methods as needed (e.g. to abide by [Metz' rule #2](http://robots.thoughtbot.com/sandi-metz-rules-for-developers)).

To add the middleware to a stack:

```ruby
stack.add(MyMiddleware)
```

Middleware is always added to the end of the stack.

### Executing a stack

To execute a stack do:

```ruby
stack.start(*args) { |env|
  # base implementation 
}
```

The execution sequence of the stack is as follows:

1. Create environment instance `env = env_class.new(*args)`
2. Call each middleware `before` method, in the order they were added
3. Call each middleware `around` method, in the order they were added.  This bottoms out with the last `implement` method to be added, if any, otherwise the base implementation
4. Call each middleware `after` method, in the order they were added
5. return `env`

### Helpers

* `Modware::is_middleware?(mod)` returns truthy if `mod`'s instance methods include any of the middleware methods `:before`, `:after`, `:around`, or `:implement`

## See also

The [middleware](https://github.com/mitchellh/middleware) gem works well, following a [rack](http://rack.github.io/)-like execution model.

## Contributing

Contributions welcome -- feel free to open issues or submit pull requests!  Thanks!
