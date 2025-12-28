defmodule Shared.JSON do
  @moduledoc """
  Standardized JSON encoding/decoding with common options.
  """

  @doc """
  Encode to JSON with standardized options.
  """
  def encode(data, opts \\ []) do
    Jason.encode(data, opts)
  end

  @doc """
  Encode to JSON, raises on error.
  """
  def encode!(data, opts \\ []) do
    Jason.encode!(data, opts)
  end

  @doc """
  Decode JSON with atom keys (use with caution - only for trusted input).
  """
  def decode(json, opts \\ []) do
    Jason.decode(json, opts)
  end

  @doc """
  Decode JSON, raises on error.
  """
  def decode!(json, opts \\ []) do
    Jason.decode!(json, opts)
  end

  @doc """
  Encode to pretty-printed JSON (for debugging/logging).
  """
  def pretty(data) do
    Jason.encode!(data, pretty: true)
  end
end
