# xjs 

xjs is an Elixir library along with a few small tools which allow you to write es6* (Javascript) in Elixir. It is intended to be an useful tool as well as an easy way to learn about compilers.

## tldr

xjs -> jst -> es6 -> es5 


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

## intro

Compilers. You hear the word and you might think of some dark magic that only a few souls are privileged or cursed enough to understand. Truth is, it's not like that at all. A compiler, very simply, is a program that takes a set of inputs and converts them to a set of outputs. In other words, a function. 

What's more, the compilation process can be broken down into any number of small steps (sounds like functions again). xjs takes advantage of this and is broken down into small understandable pieces. The part of the codebase which does "real work" is under 250 soc (not counting libraries). Understand it, and you will have a pretty good understanding of how compilers work.

Honestly, this is a bit of a hack. But not all hacks are bad. 

## the process

### 1. xjs

xjs is an Elixir macro and a mix task which allow you to write es6* (Javascript) in Elixir. It works very simply: it takes an Elixir ast (as produced by the Elixir compiler) and produdes a jst, or a Javascript Syntax Tree. This gives us the full range of Elixir syntax with a minimum of code, as Elixir is particularly well-suited to writing compiles with it's pattern matching. See [lib/xjs.xjs](../lib/xjs.xjs): 

```
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

## Installation

  1. Add xjs to your list of dependencies in `mix.exs`:

        def deps do
          [{:xjs, "~> 0.0.5"}]
        end

  2. Ensure xjs is started before your application:

        def application do
          [applications: [:xjs]]
        end

