# BOT2

This is the second iteration of the attempts to create a Forex trading bot, this time being created in Elixir.  

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
