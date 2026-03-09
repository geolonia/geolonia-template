import { describe, expect, it } from "vitest";
import { hello } from "../src/index.js";

describe("hello", () => {
  it("returns greeting with name", () => {
    expect(hello("World")).toBe("Hello, World!");
  });

  it("returns greeting with empty string", () => {
    expect(hello("")).toBe("Hello, !");
  });
});
