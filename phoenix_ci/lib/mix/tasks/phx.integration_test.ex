defmodule Mix.Tasks.Phx.IntegrationTest do
  @moduledoc """
  Run Phoenix integration test.
  """

  use Mix.Task

  def run(args) do
    Application.ensure_all_started(:dagger)

    {opts, [], []} = OptionParser.parse(args, strict: [elixir: :string, otp: :string])
    elixir = opts[:elixir] || "1.14.0"
    otp = opts[:otp] || "24.3.4"

    client = Dagger.connect!()

    project = PhoenixCi.fetch_project(client)

    {:ok, _} =
      project
      |> Dagger.Directory.file("integration_test/docker-compose.yml")
      |> Dagger.File.export("./docker-compose.yml")

    {:ok, _} =
      client
      |> Dagger.Client.container()
      |> setup_base(elixir, otp)
      |> Dagger.Container.with_directory("/src", project)
      |> Dagger.Container.with_exec(~w[mix local.rebar --force])
      |> Dagger.Container.with_exec(~w[mix local.hex --force])
      |> Dagger.Compose.with_compose("docker-compose.yml", client)
      |> do_integration_test()
      |> Dagger.Sync.sync()

    Dagger.close(client)
  end

  defp setup_base(%Dagger.Container{} = container, elixir, otp) do
    container
    |> Dagger.Container.from("hexpm/elixir:#{elixir}-erlang-#{otp}-alpine-3.16.0")
    |> Dagger.Container.with_exec(~w[apk add --no-progress --update git build-base])
    |> Dagger.Container.with_env_variable("ELIXIR_ASSERT_TIMEOUT", "10000")
    |> Dagger.Container.with_workdir("/src")
  end

  defp do_integration_test(%Dagger.Container{} = container) do
    container
    |> Dagger.Container.with_workdir("/src/integration_test")
    # Ensure integration_test/mix.lock contains all of the dependencies we need and none we don't
    |> Dagger.Container.with_exec(~w[cp mix.lock mix.lock.orig])
    |> Dagger.Container.with_exec(~w[mix deps.get])
    |> Dagger.Container.with_exec(~w[mix deps.unlock --check-unused])
    |> Dagger.Container.with_exec(~w[diff -u mix.lock.orig mix.lock])
    |> Dagger.Container.with_exec(~w[rm mix.lock.orig])
    # Run integration tests
    |> Dagger.Container.with_exec(~w[mix test --include database])
  end
end
