# xjs 

xjs is collection of small tools which make learning about and writing compilers easy. It also has the goal of being the simplest way of writing the latest Javascript (ES6+).

xjs is composed of two parts:

1. an Elixir library which uses the ast produced by the Elixir compiler to generate a json syntax tree understood by Javascript tooling (and compilers)
2. a Javascript library (and webpack loader) which uses Babel to generate ES5 (read: old but cross-platform JS) 

Importantly, the two parts can be used in isolation. You may use the same techniques (from step 1) to generate Go or LaTeX or Python or a number of other languages. Elixir syntax is flexible, the tooling is excellent, and it is perfect for writing compilers, being a functional language. Or, you could generate your own Javascript syntax tree in json format (jst) and load it into webpack and compile it to Javascript.

The code has an emphasis on being concise and readable (under 250 lines of code).

## status 

xjs currently supports a good portion of es6

## tldr

xjs -> jst -> es6 -> es5 


```elixir
xjs
  let print = fn x ->
    console.log x
    return x
  end

  print "hey!"
     
  # pipe
  "hey!" |> print
end
```

## intro

Compilers. You hear the word and you might think of some dark magic that only a few souls are privileged or cursed enough to understand. Truth is, it's not like that at all. A compiler, very simply, is a program that takes a set of inputs and converts them to a set of outputs. In other words, a function. 

What's more, the compilation process can be broken down into any number of small steps (sounds like functions again). xjs takes advantage of this and is broken down into small understandable pieces. The part of the codebase which does "real work" is under 250 soc (not counting libraries). Understand it, and you will have a pretty good understanding of how compilers work.

Honestly, this is a bit of a hack. But not all hacks are bad. 

## installation

This has been tested on [Void Linux](http://voidlinux.eu). If you are looking for a modern, clean, simple, BSD-like distro, it's the way to go. xjs should work fine on a number of other OSes. 

1. Make sure Node and npm are installed properly. Also make sure Elixir and mix are installed properly. Use your preferred search engine.

2. Start a new Elixir project.

  ```
  mix new test
  cd test
  ```

3. Add xjs to your list of dependencies and ensure xjs is started before your application in `mix.exs`.

  ```elixir
  def deps do
    [{:xjs, "~> 0.0.5"}]
  end
  ```
  ...

  ```elixir 
  def application do
    [applications: [:xjs]]
  end
  ```

  This is enough to use the xjs macro or the `mix xjs` task. If you want to use the webpack portion of xjs, continue on.


4. Start a new Node project.

  ```
  npm init
  ```

5. Install necessary dependencies.

  ```
  npm install babel-loader babel-core babel-preset-es2015 jst-loader xjs-loader webpack --save-dev
  ```

You should be good to go.

6. If you'd like to continue with the examples below, you may want to grab a couple of files.

  ```
  wget https://raw.githubusercontent.com/aaron-lebo/xjs/master/examples/webpack.config.js
  wget https://raw.githubusercontent.com/aaron-lebo/xjs/master/examples/webpack.config.js
  ```

## the process

### 1. xjs

xjs is an Elixir macro and a mix task. It works very simply: it takes an Elixir ast (as produced by the Elixir compiler) and produces a jst, or a Javascript Syntax Tree. See [lib/xjs.ex](lib/xjs.ex): 

```elixir
def compile({:if, meta, [test, [do: consequent]]}) do
  compile {:if, meta, [test, [do: consequent, else: nil]]}
end

def compile({:if, _, [test, [do: consequent, else: alternate]]}) do
  %{
    type: :IfStatement,
    test: compile(test),
    consequent: block!(consequent),
    alternate: block!(alternate)
  }
end
```

Currently, an .xjs file is an Elixir module with a defined run function. See [examples/index.xjs](examples/index.xjs): 

```elixir
def run do
  xjs
    let print = fn x ->
      console.log x
      return x
    end

    print "hey!"
     
    # pipe
    "hey!" |> print
  end
end
```

We can convert it to jst with the following command:

```
mix xjs index.xjs | json > index.jst
```

### 2. jst

jst is [Mozilla's Parser API](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey/Parser_API) as json. [jst-loader](https://github.com/aaron-lebo/jst-loader) is a Webpack loader which compiles jst to es6 using [escodegen](https://github.com/estools/escodegen).

See [examples/index.jst](examples/index.jst): 

```json
{
  "type": "Program",
  "body": [
    {
      "type": "VariableDeclaration",
      "kind": "let",
      "declarations": [
        {
          "type": "VariableDeclarator",
          "init": {
            "type": "FunctionExpression",
            "params": [
              {
                "type": "Identifier",
                "name": "x"
              }
            ],
            "body": {
              "type": "BlockStatement",
              "body": [
                {
                  "type": "ExpressionStatement",
                  "expression": {
                    "type": "CallExpression",
                    "callee": {
                      "type": "MemberExpression",
                      "property": {
                        "type": "Identifier",
                        "name": "log"
                      },
                      "object": {
                        "type": "Identifier",
                        "name": "console"
                      },
                      "computed": false
                    },
                    "arguments": [
                      {
                        "type": "Identifier",
                        "name": "x"
                      }
                    ]
                  }
                },
                {
                  "type": "ExpressionStatement",
                  "expression": {
                    "type": "CallExpression",
                    "callee": {
                      "type": "Identifier",
                      "name": "return"
                    },
                    "arguments": [
                      {
                        "type": "Identifier",
                        "name": "x"
                      }
                    ]
                  }
                }
              ]
            }
          },
          "id": {
            "type": "Identifier",
            "name": "print"
          }
        }
      ]
    },
    {
      "type": "ExpressionStatement",
      "expression": {
        "type": "CallExpression",
        "callee": {
          "type": "Identifier",
          "name": "print"
        },
        "arguments": [
          {
            "value": "hey!",
            "type": "Literal"
          }
        ]
      }
    },
    {
      "type": "ExpressionStatement",
      "expression": {
        "type": "CallExpression",
        "callee": {
          "type": "Identifier",
          "name": "print"
        },
        "arguments": [
          {
            "value": "hey!",
            "type": "Literal"
          }
        ]
      }
    }
  ]
}
```

We can generate and bundle up Javascript via:

```
webpack index.jst
```

Alternatively, we can skip the intermediate step and generate and bundle up js via:

```
webpack index.xjs
```

This requires [xjs-loader](https://github.com/aaron-lebo/xjs-loader) and `xjs-loader` requires `mix xjs` to be available.

### 3. es6

*or es2015 or es2016 or esME or whatever the hell it is is these days*

You could chose to only compile down to es6. See [examples/es6.js](examples/es6.js).

```javascript
let print = function (x) {
    console.log(x);
    return(x);
};
print('hey!');
print('hey!');
 ```

Most of the time, however, you will want to use the `babel-loader` which does most of the hard work to compile down to es5. See [examples/es5.js](examples/es5.js).

### 4. es5

```javascript
var print = function print(x) {
    console.log(x);
    return x;
};
print('hey!');
print('hey!');
```

Well, uh, guess that's about it.

You can now [configure Webpack](https://webpack.github.io/docs/configuration.html) to do useful things like watching for file changes or hot-code reloading jst or xjs. That's pretty cool, right?
