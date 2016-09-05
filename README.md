# BOT2

## **Important Note**
This is version 2 of my algorithmic trading platform, this one being written in Elixir.  It is **not** in a working condition and was a sort of prototype for future revisions of the algobot platform.

Future revisions of the platform are listed below:

1. [algobot1](https://github.com/Ameobea/algobot)
2. algobot-elixir (this repository)
3. [bot3](https://github.com/Ameobea/algobot3)
4. [bot4/Rustbot](https://github.com/Ameobea/bot4)

----

## Bot Architecture

The bot is, as before, focused around multiple modules which receive tick data, process it, and pass the various calculations around to each other in order to determine the best times to trade.

Ticks originate from either a live source or from archive via backtests, are parsed and sent off to various workers that the bot supports, which in turn pass their calculations off to other workers and store them in a database.

See the [previous repository](https://github.com/ameobea/algobot) for additional documentation while this one is populated.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add bot2 to your list of dependencies in `mix.exs`:

        def deps do
          [{:bot2, "~> 0.0.1"}]
        end

  2. Ensure bot2 is started before your application:

        def application do
          [applications: [:bot2]]
        end
