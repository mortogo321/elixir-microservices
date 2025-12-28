defmodule Auth.User do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :id, 1, type: :int64
  field :email, 2, type: :string
  field :name, 3, type: :string
  field :created_at, 4, type: :string, json_name: "createdAt"
  field :updated_at, 5, type: :string, json_name: "updatedAt"
end

defmodule Auth.RegisterRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :email, 1, type: :string
  field :password, 2, type: :string
  field :name, 3, type: :string
end

defmodule Auth.LoginRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :email, 1, type: :string
  field :password, 2, type: :string
end

defmodule Auth.ValidateTokenRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :token, 1, type: :string
end

defmodule Auth.RefreshTokenRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :refresh_token, 1, type: :string, json_name: "refreshToken"
end

defmodule Auth.GetUserRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :user_id, 1, type: :int64, json_name: "userId"
end

defmodule Auth.GetUserByEmailRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :email, 1, type: :string
end

defmodule Auth.AuthResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :success, 1, type: :bool
  field :message, 2, type: :string
  field :user, 3, type: Auth.User
  field :access_token, 4, type: :string, json_name: "accessToken"
  field :refresh_token, 5, type: :string, json_name: "refreshToken"
  field :expires_in, 6, type: :int64, json_name: "expiresIn"
end

defmodule Auth.ValidateTokenResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :valid, 1, type: :bool
  field :message, 2, type: :string
  field :user, 3, type: Auth.User
end

defmodule Auth.UserResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :success, 1, type: :bool
  field :message, 2, type: :string
  field :user, 3, type: Auth.User
end

defmodule Auth.AuthService.Service do
  @moduledoc false
  use GRPC.Service, name: "auth.AuthService", protoc_gen_elixir_version: "0.12.0"

  rpc :Register, Auth.RegisterRequest, Auth.AuthResponse
  rpc :Login, Auth.LoginRequest, Auth.AuthResponse
  rpc :ValidateToken, Auth.ValidateTokenRequest, Auth.ValidateTokenResponse
  rpc :RefreshToken, Auth.RefreshTokenRequest, Auth.AuthResponse
  rpc :GetUser, Auth.GetUserRequest, Auth.UserResponse
  rpc :GetUserByEmail, Auth.GetUserByEmailRequest, Auth.UserResponse
end

defmodule Auth.AuthService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Auth.AuthService.Service
end
