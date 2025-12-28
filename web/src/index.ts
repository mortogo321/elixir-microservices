import { cors } from "@elysiajs/cors";
import { swagger } from "@elysiajs/swagger";
import { Elysia } from "elysia";
import { apiRoutes } from "./routes/api";
import { authUiRoutes } from "./routes/auth-ui";
import { healthRoutes } from "./routes/health";

const app = new Elysia()
  .use(
    cors({
      origin: ["http://localhost:4000", "http://localhost:3000"],
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      allowedHeaders: ["Content-Type", "Authorization"],
    }),
  )
  .use(
    swagger({
      documentation: {
        info: {
          title: "Elixir Bun Microservice API",
          version: "1.0.0",
          description:
            "API Gateway for Elixir Phoenix backend with real-time support",
        },
        tags: [
          { name: "health", description: "Health check endpoints" },
          { name: "auth", description: "Authentication endpoints" },
          { name: "users", description: "User management endpoints" },
          { name: "messages", description: "Message endpoints" },
        ],
      },
      path: "/swagger",
    }),
  )
  .get("/", ({ redirect }) => redirect("/auth/login"))
  .use(healthRoutes)
  .use(apiRoutes)
  .use(authUiRoutes)
  .listen(3000);

console.log(
  `🦊 Bun server is running at ${app.server?.hostname}:${app.server?.port}`,
);
console.log("📚 Swagger docs available at http://localhost:3000/swagger");

export type App = typeof app;
