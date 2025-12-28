defmodule Auth.GRPC.Endpoint do
  @moduledoc """
  gRPC endpoint configuration.
  """

  use GRPC.Endpoint

  intercept GRPC.Server.Interceptors.Logger

  run Auth.GRPC.Server
end
