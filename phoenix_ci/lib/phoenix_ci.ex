defmodule PhoenixCi do
  @moduledoc """
  CI test suite for phoenixframework/phoenix project.
  """

  @doc """
  Fetch project from GitHub.
  """
  def fetch_project(%Dagger.Client{} = client) do
    client
    |> Dagger.Client.git("https://github.com/phoenixframework/phoenix.git")
    |> Dagger.GitRepository.branch("main")
    |> Dagger.GitRef.tree()
  end
end
