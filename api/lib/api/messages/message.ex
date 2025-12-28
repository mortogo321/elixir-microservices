defmodule Api.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Api.Accounts.User

  schema "messages" do
    field :content, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id])
    |> validate_required([:content, :user_id])
    |> validate_length(:content, min: 1, max: 1000)
    |> foreign_key_constraint(:user_id)
  end
end
