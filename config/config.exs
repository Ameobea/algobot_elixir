use Mix.Config

# This is the main config file for the bot.  Stuff that can change between different
# production environments and other user-settable data for the bot that doesn't change
# should be stored here.  

# For things such as algorithm parameters and more variable settings, a persistant
# database should be used.  


config(:bot2, rootdir: "/home/ubuntu/bot2/")

# You can configure for your application as:
#
#     config :bot2, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:bot2, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# This imports the config settings from the non-commited config file.
import_config("secret_config.exs")