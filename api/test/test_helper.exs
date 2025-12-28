ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Api.Repo, :manual)

Mox.defmock(Api.Grpc.AuthClientMock, for: Api.Grpc.AuthClientBehaviour)
