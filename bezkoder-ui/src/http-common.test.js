// Test del cliente HTTP (instancia axios).
// Se mockea axios para verificar la configuración sin red.

jest.mock("axios", () => ({
  create: jest.fn(() => ({ __mockInstance: true }))
}));

import axios from "axios";
import http from "./http-common";

describe("http-common", () => {
  it("crea una instancia de axios con headers JSON y baseURL", () => {
    expect(axios.create).toHaveBeenCalledTimes(1);
    const config = axios.create.mock.calls[0][0];
    expect(config.headers["Content-type"]).toBe("application/json");
    expect(typeof config.baseURL).toBe("string");
    expect(config.baseURL.length).toBeGreaterThan(0);
  });

  it("exporta la instancia creada", () => {
    expect(http).toEqual({ __mockInstance: true });
  });
});
