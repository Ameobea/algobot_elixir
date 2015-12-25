use Mix.Config

config(:bot2, rootdir: "/home/ubuntu/bot2/")

# Determines whether or not the two extra database queries to retreive
# the tick before a specified range of ticks to produce a more accurate average.
config(:bot2, accurate_averages: true)

# This imports the config settings from the non-commited config file.
import_config("secret_config.exs")
