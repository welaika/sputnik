![](https://github.com/spawnfest/sputnik/blob/master/static/sputnik_logo.png)

# Sputnik
by weLaika

Sputnik is a website crawler written in Elixir.

It crawls a website following all internal links and makes a report of all pages' status codes.

With query flags you can pass one ore more css selector to produce pages report about that.

## Build

Sputnik can be built with:

```
mix escript.build
```

## Usage

Sputnik takes the url to crawl and optional query to perform on the crawled pages:

```
sputnik [--query <Q> --query <Q1> ...] <url>
```

## Examples

running

```
./sputnik "http://spawnfest.github.io" --query "div" --query "a" --query "h1,h2,h3,h4,h5,h6"
```

produces the following output

```
#################### Pages ####################
Pages found: 19
status_code 200: 12
status_code 301: 7


#################### Queries ####################
## query `a` ##
327 result(s)
Min 18 result(s) per page
Max 57 result(s) per page
## query `div` ##
347 result(s)
Min 13 result(s) per page
Max 53 result(s) per page
## query `h1,h2,h3,h4,h5,h6` ##
95 result(s)
Min 0 result(s) per page
Max 31 result(s) per page

```

## Requirements

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sputnik](https://hexdocs.pm/sputnik).
