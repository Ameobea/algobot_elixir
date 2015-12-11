defmodule BOT2 do
  @moduledoc """
  This is the parent module for the bot.  It handles 
  the launching and supervision of all the other
  modules that perform the various tasks of the bot.

  It handles the supervising of all bot processes as well as
  provisioning computing power where necessary.  
  """

  use Application

  def start(_type, _args) do
    
  end

end
