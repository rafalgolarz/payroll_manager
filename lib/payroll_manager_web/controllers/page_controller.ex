defmodule PayrollManagerWeb.PageController do
  @moduledoc false
  use PayrollManagerWeb, :controller

  def ping(conn, _params) do
    render(conn, :ping)
  end
end
