defmodule Mix.Tasks.Phx.JsTest do
  @moduledoc """
  Run Phoenix JavaScript tests.
  """

  use Mix.Task

  def run(_args) do
    Application.ensure_all_started(:dagger)

    client = Dagger.connect!()

    {:ok, _} =
      client
      |> Dagger.Client.container()
      |> Dagger.Container.from("node:12")
      |> Dagger.Container.with_directory("/src", PhoenixCi.fetch_project(client))
      |> Dagger.Container.with_workdir("/src/assets")
      |> Dagger.Container.with_exec(~w"npm install")
      |> Dagger.Container.with_exec(~w"npm test")
      |> Dagger.Sync.sync()

    Dagger.close(client)
  end
end
