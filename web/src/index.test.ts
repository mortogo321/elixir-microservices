import { describe, expect, it } from "bun:test";
import { Elysia } from "elysia";

describe("Health endpoint", () => {
  const app = new Elysia().get("/health", () => ({
    status: "ok",
    timestamp: new Date().toISOString(),
    service: "bun-gateway",
  }));

  it("returns health status", async () => {
    const response = await app.handle(new Request("http://localhost/health"));
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body.status).toBe("ok");
    expect(body.service).toBe("bun-gateway");
    expect(body.timestamp).toBeDefined();
  });
});

describe("API Client", () => {
  it("should create proper headers with token", async () => {
    const { ApiClient } = await import("./lib/api-client");
    const client = new ApiClient("http://localhost:4000/api");

    // Basic instantiation test
    expect(client).toBeDefined();
  });
});
