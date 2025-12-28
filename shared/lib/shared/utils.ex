defmodule Shared.Utils do
  @moduledoc """
  Common utility functions.
  """

  @doc """
  Generate a random string of given length.

  ## Examples

      iex> Shared.Utils.random_string(16) |> String.length()
      16
  """
  def random_string(length) when length > 0 do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  @doc """
  Atomize string keys in a map (shallow).

  ## Examples

      iex> Shared.Utils.atomize_keys(%{"foo" => 1, "bar" => 2})
      %{foo: 1, bar: 2}
  """
  def atomize_keys(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {String.to_existing_atom(k), v}
      {k, v} when is_atom(k) -> {k, v}
    end)
  end

  @doc """
  Safe atomize keys - creates atoms only for known keys.

  ## Examples

      iex> Shared.Utils.safe_atomize_keys(%{"foo" => 1}, [:foo, :bar])
      %{foo: 1}
  """
  def safe_atomize_keys(map, allowed_atoms) when is_map(map) and is_list(allowed_atoms) do
    allowed_strings = Enum.map(allowed_atoms, &to_string/1)

    map
    |> Enum.filter(fn {k, _} -> to_string(k) in allowed_strings end)
    |> Map.new(fn {k, v} ->
      atom_key = if is_binary(k), do: String.to_existing_atom(k), else: k
      {atom_key, v}
    end)
  end

  @doc """
  Truncate a string to max length with ellipsis.

  ## Examples

      iex> Shared.Utils.truncate("Hello World", 8)
      "Hello..."
  """
  def truncate(str, max_length) when is_binary(str) and max_length > 3 do
    if String.length(str) <= max_length do
      str
    else
      String.slice(str, 0, max_length - 3) <> "..."
    end
  end

  def truncate(str, _max_length) when is_binary(str), do: str
  def truncate(nil, _max_length), do: nil

  @doc """
  Slugify a string for URLs.

  ## Examples

      iex> Shared.Utils.slugify("Hello World!")
      "hello-world"
  """
  def slugify(str) when is_binary(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/, "")
    |> String.replace(~r/[\s_]+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end

  def slugify(nil), do: nil
end
