[![Gem Version](https://badge.fury.io/rb/modware.svg)](http://badge.fury.io/rb/modware)
[![Build Status](https://github.com/SchemaPlus/modware/actions/workflows/prs.yml/badge.svg)](https://github.com/SchemaPlus/modware/actions)
[![Coverage Status](https://coveralls.io/repos/github/SchemaPlus/modware/badge.svg)](https://coveralls.io/github/SchemaPlus/modware)

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
stack = Modware::Stack.new(env: klass)
```

where `klass` is a Class for the environment instance that will be passed to the layers of the stack.  As a shorthand for the common case, you can simply pass an array of keys, e.g.

```ruby
stack = Modware::Stack.new(env: [:name, :options, :results])
```

and Modware will define a class that accepts those keys as keyword arguments, and has accessor methods for each (see 
[`KeyStruct`](https://rubygems.org/gems/key_struct)).


### Defining middleware

Define middleware by creating a module that defines one or more of these middleware methods:

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

1. Create environment instance `env = env_klass.new(*args)`
2. Call each middleware `before(env)` method, in the order they were added
3. Call each middleware `around(env)` method, in the order they were added.  This bottoms out with the last `implement(env)` method to be added, if any, otherwise the base implementation
4. Call each middleware `after(env)` method, in the order they were added
5. `stack.start` returns `env`

#### Example: wrapping an existing operation

A common idiom is to wrap a modware stack around an existing operation:

```ruby
class WrapsOperation < BaseClass

  attr_reader :stack

  def initialize(*args)
    super
    @stack = Modware::Stack.new(env: [:time, :place, :result])
  end
  
  def operation(time, place)
    stack.start(time: time, place: place) { |env|
      env.result = super env.time, env.place
    }.result
  end
end
```

Notice in the `operation` wrapper method: 

* The `env` instance gets initialized with the method arguments
* The base implmenetation of `operation` gets its arguments from the `env` instance, giving clients a chance to modify them in `:before` or `:around` methods.
* The result of the base implementation gets stored in `env`, giving clients a chance to modify it in `:around` or `:after` methods.
* When stack execution finishes, it returns `env`, from which the wrapper returns the result.

### Helpers

* `Modware.is_middleware?(mod)` returns truthy if `mod`'s instance methods include any of the middleware methods `:before`, `:after`, `:around`, or `:implement`

## See also

The [middleware](https://rubygems.org/gems/middleware) gem works well, following a [rack](http://rack.github.io/)-like execution model.

## Change Log

* 0.1.3 - Remove its-it dependency :(  #2
* 0.1.2 - More thread safety in Stack#start
* 0.1.1 - Thread safety in Stack#start
* 0.1.0 - Initial release

## Contributing

Contributions welcome -- feel free to open issues or submit pull requests.  Thanks!
