# xjs 

elixir syntax, javascript semantics

## tldr

xjs -> jst -> es6 -> es5 

## more

xjs is intended to be both a useful tool as well as an easy way to learn about compilers.

Compilers. You hear the word and you might think of some dark magic that only a few souls are privileged or cursed enough to understand. Truth is, it's not like that at all. A compiler, very simply, as a program that takes a set of inputs and converts them to a set of outputs. In other words, a function. 

What's more, the compilation process can be broken down into any number of small steps (sounds like functions again). xjs takes advantage of this and is broken down into small understandable pieces. The part of the codebase which does "real work" is under 250 soc (not counting libraries). Understand it, and you will have a pretty good understanding of how compilers work.

Honestly, this is a bit of a hack. But it is a hack that seems to work and is simple, so why not use it?

## Installation

  1. Add xjs to your list of dependencies in `mix.exs`:

        def deps do
          [{:xjs, "~> 0.0.4"}]
        end

  2. Ensure xjs is started before your application:

        def application do
          [applications: [:xjs]]
        end

