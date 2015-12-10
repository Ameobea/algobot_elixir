defmodule BOT2.Supervisor do
  @moduledoc """
  This is something that will launch the various worker processe for the modules
  of the bot.  Right now, I have no idea what the fuck is going on so I'm just
  keeping some basic stuff from a tutorial thing.
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      
    ]
  end
end