defmodule Shared.DateTime do
  @moduledoc """
  Standardized date/time formatting utilities.
  """

  @doc """
  Format a DateTime to ISO8601 string.

  ## Examples

      iex> Shared.DateTime.to_iso8601(~U[2024-01-15 10:30:00Z])
      "2024-01-15T10:30:00Z"
  """
  def to_iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  def to_iso8601(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt) <> "Z"
  def to_iso8601(nil), do: nil

  @doc """
  Format a DateTime to human-readable string.

  ## Examples

      iex> Shared.DateTime.to_human(~U[2024-01-15 10:30:00Z])
      "Jan 15, 2024 at 10:30 AM"
  """
  def to_human(%DateTime{} = dt) do
    Calendar.strftime(dt, "%b %d, %Y at %I:%M %p")
  end

  def to_human(%NaiveDateTime{} = dt) do
    Calendar.strftime(dt, "%b %d, %Y at %I:%M %p")
  end

  def to_human(nil), do: nil

  @doc """
  Format a DateTime to date only.

  ## Examples

      iex> Shared.DateTime.to_date(~U[2024-01-15 10:30:00Z])
      "2024-01-15"
  """
  def to_date(%DateTime{} = dt), do: Date.to_iso8601(DateTime.to_date(dt))
  def to_date(%NaiveDateTime{} = dt), do: Date.to_iso8601(NaiveDateTime.to_date(dt))
  def to_date(%Date{} = d), do: Date.to_iso8601(d)
  def to_date(nil), do: nil

  @doc """
  Get current UTC timestamp as ISO8601 string.
  """
  def now_iso8601, do: DateTime.utc_now() |> to_iso8601()

  @doc """
  Parse ISO8601 string to DateTime.
  """
  def from_iso8601(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _offset} -> {:ok, dt}
      {:error, _} = err -> err
    end
  end

  def from_iso8601(nil), do: {:ok, nil}

  @doc """
  Parse ISO8601 string to DateTime, raises on error.
  """
  def from_iso8601!(str) when is_binary(str) do
    case from_iso8601(str) do
      {:ok, dt} -> dt
      {:error, reason} -> raise ArgumentError, "Invalid ISO8601: #{reason}"
    end
  end
end
