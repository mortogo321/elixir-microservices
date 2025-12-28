defmodule Auth.Proto.User do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :id, 1, type: :int64
  field :email, 2, type: :string
  field :name, 3, type: :string
  field :created_at, 4, type: :string, json_name: "createdAt"
  field :updated_at, 5, type: :string, json_name: "updatedAt"
end

defmodule Auth.Proto.RegisterRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :email, 1, type: :string
  field :password, 2, type: :string
  field :name, 3, type: :string
end

defmodule Auth.Proto.LoginRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :email, 1, type: :string
  field :password, 2, type: :string
end

defmodule Auth.Proto.ValidateTokenRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :token, 1, type: :string
end

defmodule Auth.Proto.RefreshTokenRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :refresh_token, 1, type: :string, json_name: "refreshToken"
end

defmodule Auth.Proto.GetUserRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :user_id, 1, type: :int64, json_name: "userId"
end

defmodule Auth.Proto.GetUserByEmailRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :email, 1, type: :string
end

defmodule Auth.Proto.AuthResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :success, 1, type: :bool
  field :message, 2, type: :string
  field :user, 3, type: Auth.Proto.User
  field :access_token, 4, type: :string, json_name: "accessToken"
  field :refresh_token, 5, type: :string, json_name: "refreshToken"
  field :expires_in, 6, type: :int64, json_name: "expiresIn"
end

defmodule Auth.Proto.ValidateTokenResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :valid, 1, type: :bool
  field :message, 2, type: :string
  field :user, 3, type: Auth.Proto.User
end

defmodule Auth.Proto.UserResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :success, 1, type: :bool
  field :message, 2, type: :string
  field :user, 3, type: Auth.Proto.User
end

defmodule Auth.Proto.AuthService.Service do
  @moduledoc false

  use GRPC.Service, name: "auth.AuthService", protoc_gen_elixir_version: "0.12.0"

  rpc :Register, Auth.Proto.RegisterRequest, Auth.Proto.AuthResponse
  rpc :Login, Auth.Proto.LoginRequest, Auth.Proto.AuthResponse
  rpc :ValidateToken, Auth.Proto.ValidateTokenRequest, Auth.Proto.ValidateTokenResponse
  rpc :RefreshToken, Auth.Proto.RefreshTokenRequest, Auth.Proto.AuthResponse
  rpc :GetUser, Auth.Proto.GetUserRequest, Auth.Proto.UserResponse
  rpc :GetUserByEmail, Auth.Proto.GetUserByEmailRequest, Auth.Proto.UserResponse
end

defmodule Auth.Proto.AuthService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Auth.Proto.AuthService.Service
end
