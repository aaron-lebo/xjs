# xjs 

elixir syntax, javascript semantics

## tldr

xjs -> jst -> es6 -> es5 

## the process

### 1. xjs

xjs is an Elixir macro and a mix task which allow you to write es6* (Javascript) in Elixir. It works very simply: it takes an Elixir ast and produdes a jst, or a Javascript Syntax Tree. 

Currently, an .xjs file is an Elixir module with a defined run function. See [examples/index.xjs](../examples/index.xjs): 

```
def run() do
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
mix xjs "examples/index.xjs" | json
```

### 2. jst

jst is [Mozilla's Parser API](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey/Parser_API) as json: 

See [examples/index.jst](../examples/index.jst): 

```
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

### 3. es6

or es2015 or es2016 or esME or whatever the hell it is is these days

```
let print = function (x) {
    console.log(x);
    return(x);
};
print('hey!');
print('hey!');
 ```

### 4. es5

```
var print = function print(x) {
    console.log(x);
    return x;
};
print('hey!');
print('hey!');
```

## more

xjs is intended to be both an useful tool as well as an easy way to learn about compilers.

Compilers. You hear the word and you might think of some dark magic that only a few souls are privileged or cursed enough to understand. Truth is, it's not like that at all. A compiler, very simply, is a program that takes a set of inputs and converts them to a set of outputs. In other words, a function. 

What's more, the compilation process can be broken down into any number of small steps (sounds like functions again). xjs takes advantage of this and is broken down into small understandable pieces. The part of the codebase which does "real work" is under 250 soc (not counting libraries). Understand it, and you will have a pretty good understanding of how compilers work.

Honestly, this is a bit of a hack. But it is a hack that seems to work and is simple, so why not use it?

## Installation

  1. Add xjs to your list of dependencies in `mix.exs`:

        def deps do
          [{:xjs, "~> 0.0.5"}]
        end

  2. Ensure xjs is started before your application:

        def application do
          [applications: [:xjs]]
        end

