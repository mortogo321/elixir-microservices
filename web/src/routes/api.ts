import { Elysia, t } from "elysia";
import { ApiClient } from "../lib/api-client";

const apiClient = new ApiClient(
  process.env.API_URL || "http://localhost:4000/api"
);

export const apiRoutes = new Elysia({ prefix: "/api" })
  // Auth routes
  .post(
    "/auth/register",
    async ({ body }) => {
      return apiClient.post("/auth/register", { user: body });
    },
    {
      body: t.Object({
        email: t.String({ format: "email" }),
        password: t.String({ minLength: 6 }),
        name: t.Optional(t.String()),
      }),
      detail: {
        tags: ["auth"],
        summary: "Register a new user",
        description: "Create a new user account and return auth token",
      },
    }
  )
  .post(
    "/auth/login",
    async ({ body }) => {
      return apiClient.post("/auth/login", body);
    },
    {
      body: t.Object({
        email: t.String({ format: "email" }),
        password: t.String(),
      }),
      detail: {
        tags: ["auth"],
        summary: "Login",
        description: "Authenticate user and return auth token",
      },
    }
  )
  .post(
    "/auth/refresh",
    async ({ body }) => {
      return apiClient.post("/auth/refresh", body);
    },
    {
      body: t.Object({
        refresh_token: t.String(),
      }),
      detail: {
        tags: ["auth"],
        summary: "Refresh token",
        description: "Get new access token using refresh token",
      },
    }
  )
  .get(
    "/auth/validate",
    async ({ headers }) => {
      return apiClient.get("/auth/validate", headers.authorization);
    },
    {
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["auth"],
        summary: "Validate token",
        description: "Validate the current access token",
      },
    }
  )

  // User routes
  .get(
    "/users/me",
    async ({ headers }) => {
      return apiClient.get("/users/me", headers.authorization);
    },
    {
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["users"],
        summary: "Get current user",
        description: "Returns the currently authenticated user",
      },
    }
  )
  .get(
    "/users",
    async ({ headers }) => {
      return apiClient.get("/users", headers.authorization);
    },
    {
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["users"],
        summary: "List all users",
        description: "Returns a list of all users",
      },
    }
  )
  .get(
    "/users/:id",
    async ({ params, headers }) => {
      return apiClient.get(`/users/${params.id}`, headers.authorization);
    },
    {
      params: t.Object({
        id: t.String(),
      }),
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["users"],
        summary: "Get user by ID",
        description: "Returns a specific user by their ID",
      },
    }
  )

  // Message routes
  .get(
    "/messages",
    async () => {
      return apiClient.get("/messages");
    },
    {
      detail: {
        tags: ["messages"],
        summary: "List messages",
        description: "Returns a list of all messages (public)",
      },
    }
  )
  .post(
    "/messages",
    async ({ body, headers }) => {
      return apiClient.post("/messages", { message: body }, headers.authorization);
    },
    {
      body: t.Object({
        content: t.String({ minLength: 1, maxLength: 1000 }),
      }),
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["messages"],
        summary: "Create message",
        description: "Create a new message (requires authentication)",
      },
    }
  )
  .get(
    "/messages/:id",
    async ({ params, headers }) => {
      return apiClient.get(`/messages/${params.id}`, headers.authorization);
    },
    {
      params: t.Object({
        id: t.String(),
      }),
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["messages"],
        summary: "Get message by ID",
        description: "Returns a specific message by its ID",
      },
    }
  )
  .put(
    "/messages/:id",
    async ({ params, body, headers }) => {
      return apiClient.put(
        `/messages/${params.id}`,
        { message: body },
        headers.authorization
      );
    },
    {
      params: t.Object({
        id: t.String(),
      }),
      body: t.Object({
        content: t.String({ minLength: 1, maxLength: 1000 }),
      }),
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["messages"],
        summary: "Update message",
        description: "Update an existing message (owner only)",
      },
    }
  )
  .delete(
    "/messages/:id",
    async ({ params, headers }) => {
      return apiClient.delete(`/messages/${params.id}`, headers.authorization);
    },
    {
      params: t.Object({
        id: t.String(),
      }),
      headers: t.Object({
        authorization: t.String(),
      }),
      detail: {
        tags: ["messages"],
        summary: "Delete message",
        description: "Delete a message (owner only)",
      },
    }
  );
