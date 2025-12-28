export class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private getHeaders(token?: string): HeadersInit {
    const headers: HeadersInit = {
      "Content-Type": "application/json",
    };

    if (token) {
      headers.Authorization = token;
    }

    return headers;
  }

  async get<T>(path: string, token?: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      method: "GET",
      headers: this.getHeaders(token),
    });

    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ error: "Unknown error" }));
      throw new Error(error.error || `HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async post<T>(path: string, data: unknown, token?: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      method: "POST",
      headers: this.getHeaders(token),
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ error: "Unknown error" }));
      throw new Error(error.error || `HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async put<T>(path: string, data: unknown, token?: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      method: "PUT",
      headers: this.getHeaders(token),
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ error: "Unknown error" }));
      throw new Error(error.error || `HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async delete<T>(path: string, token?: string): Promise<T | null> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      method: "DELETE",
      headers: this.getHeaders(token),
    });

    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ error: "Unknown error" }));
      throw new Error(error.error || `HTTP error! status: ${response.status}`);
    }

    if (response.status === 204) {
      return null;
    }

    return response.json();
  }
}
