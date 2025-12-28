import { Elysia } from "elysia";

export const healthRoutes = new Elysia({ prefix: "/health" }).get(
  "/",
  () => ({
    status: "ok",
    timestamp: new Date().toISOString(),
    service: "bun-gateway",
  }),
  {
    detail: {
      tags: ["health"],
      summary: "Health check",
      description: "Returns the health status of the Bun gateway service",
    },
  },
);
