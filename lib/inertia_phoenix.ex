defmodule InertiaPhoenix do
  @moduledoc File.read!("README.md")
  import Plug.Conn

  @doc "share()"
  def share(%Plug.Conn{} = conn, key, val) do
    shared_props =
      conn.private
      |> Map.get(:inertia_phoenix_shared_props, %{})
      |> Map.put(key, val)

    put_private(conn, :inertia_phoenix_shared_props, shared_props)
  end

  @doc "shortcut for assigning Ecto changesets"
  def put_errors(conn, changeset = %Ecto.Changeset{}) do
    errors = extract_changeset_errors(changeset)

    conn
    |> put_errors(errors)
  end

  def put_errors(conn, errors) do
    put_session(conn, :errors, errors)
  end

  defp extract_changeset_errors(changeset = %Ecto.Changeset{}) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts 
        |> Keyword.get(String.to_existing_atom(key), key) 
        |> to_string()
      end)
    end)
  end

  def assets_version do
    Application.get_env(:inertia_phoenix, :assets_version, "1")
    |> to_string
  end

  def inertia_layout do
    Application.get_env(:inertia_phoenix, :inertia_layout, "app.html")
    |> to_string
  end

  def path_with_params(%{request_path: request_path, query_string: ""}), do: request_path

  def path_with_params(%{request_path: request_path, query_string: query_string}) do
    request_path <> "?" <> query_string
  end

  def path_with_params(%{request_path: request_path}), do: request_path
end
