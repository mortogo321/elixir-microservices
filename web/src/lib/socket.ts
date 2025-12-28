interface SocketOptions {
  url: string;
  token?: string;
}

interface Channel {
  topic: string;
  callbacks: Map<string, ((payload: unknown) => void)[]>;
}

export class PhoenixSocket {
  private ws: WebSocket | null = null;
  private url: string;
  private token?: string;
  private channels: Map<string, Channel> = new Map();
  private messageRef = 0;
  private pendingCallbacks: Map<string, (response: unknown) => void> =
    new Map();

  constructor(options: SocketOptions) {
    this.url = options.url;
    this.token = options.token;
  }

  connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      const wsUrl = this.token ? `${this.url}?token=${this.token}` : this.url;

      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = () => {
        console.log("Phoenix socket connected");
        resolve();
      };

      this.ws.onerror = (error) => {
        console.error("Phoenix socket error:", error);
        reject(error);
      };

      this.ws.onclose = () => {
        console.log("Phoenix socket closed");
      };

      this.ws.onmessage = (event) => {
        this.handleMessage(JSON.parse(event.data));
      };
    });
  }

  disconnect(): void {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  join(topic: string): Promise<unknown> {
    return new Promise((resolve, reject) => {
      const ref = this.makeRef();

      this.pendingCallbacks.set(ref, (response) => {
        const channel: Channel = {
          topic,
          callbacks: new Map(),
        };
        this.channels.set(topic, channel);
        resolve(response);
      });

      this.push(topic, "phx_join", {}, ref);

      setTimeout(() => {
        if (this.pendingCallbacks.has(ref)) {
          this.pendingCallbacks.delete(ref);
          reject(new Error("Join timeout"));
        }
      }, 10000);
    });
  }

  leave(topic: string): void {
    const ref = this.makeRef();
    this.push(topic, "phx_leave", {}, ref);
    this.channels.delete(topic);
  }

  on(topic: string, event: string, callback: (payload: unknown) => void): void {
    const channel = this.channels.get(topic);
    if (channel) {
      if (!channel.callbacks.has(event)) {
        channel.callbacks.set(event, []);
      }
      channel.callbacks.get(event)?.push(callback);
    }
  }

  push(topic: string, event: string, payload: unknown, ref?: string): string {
    const messageRef = ref || this.makeRef();

    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(
        JSON.stringify({
          topic,
          event,
          payload,
          ref: messageRef,
        }),
      );
    }

    return messageRef;
  }

  private handleMessage(message: {
    topic: string;
    event: string;
    payload: unknown;
    ref: string;
  }): void {
    const { topic, event, payload, ref } = message;

    // Handle reply to pending callbacks
    if (event === "phx_reply" && this.pendingCallbacks.has(ref)) {
      const callback = this.pendingCallbacks.get(ref);
      this.pendingCallbacks.delete(ref);
      if (callback) callback(payload);
      return;
    }

    // Handle channel events
    const channel = this.channels.get(topic);
    if (channel) {
      const callbacks = channel.callbacks.get(event);
      if (callbacks) {
        for (const callback of callbacks) {
          callback(payload);
        }
      }
    }
  }

  private makeRef(): string {
    this.messageRef++;
    return this.messageRef.toString();
  }
}

export function createSocket(url: string, token?: string): PhoenixSocket {
  return new PhoenixSocket({ url, token });
}
