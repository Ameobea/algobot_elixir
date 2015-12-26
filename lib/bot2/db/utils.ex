defmodule DB.Utils do
  def db_connect do
    {:ok, conn} = Redix.start_link(
      host: Application.get_env(:bot2, :redis_hostname),
      password: Application.get_env(:bot2, :redis_password),
      port: Application.get_env(:bot2, :redis_port)
    )
    conn
  end

  def wipe_database(conn) do
    Redix.command(conn, ["FLUSHALL"])
  end
end
