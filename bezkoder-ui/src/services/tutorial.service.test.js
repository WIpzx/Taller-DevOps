// Tests unitarios del servicio de datos (capa HTTP).
// Se mockea http-common para verificar las rutas/verbos sin red.

jest.mock("../http-common", () => ({
  __esModule: true,
  default: {
    get: jest.fn(() => Promise.resolve({ data: [] })),
    post: jest.fn(() => Promise.resolve({ data: {} })),
    put: jest.fn(() => Promise.resolve({ data: {} })),
    delete: jest.fn(() => Promise.resolve({ data: {} }))
  }
}));

import http from "../http-common";
import TutorialDataService from "./tutorial.service";

describe("TutorialDataService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("getAll hace GET /tutorials", () => {
    TutorialDataService.getAll();
    expect(http.get).toHaveBeenCalledWith("/tutorials");
  });

  it("get(id) hace GET /tutorials/:id", () => {
    TutorialDataService.get(5);
    expect(http.get).toHaveBeenCalledWith("/tutorials/5");
  });

  it("create(data) hace POST /tutorials con el cuerpo", () => {
    const data = { title: "t", description: "d" };
    TutorialDataService.create(data);
    expect(http.post).toHaveBeenCalledWith("/tutorials", data);
  });

  it("update(id, data) hace PUT /tutorials/:id con el cuerpo", () => {
    const data = { title: "u" };
    TutorialDataService.update(3, data);
    expect(http.put).toHaveBeenCalledWith("/tutorials/3", data);
  });

  it("delete(id) hace DELETE /tutorials/:id", () => {
    TutorialDataService.delete(9);
    expect(http.delete).toHaveBeenCalledWith("/tutorials/9");
  });

  it("deleteAll() hace DELETE /tutorials", () => {
    TutorialDataService.deleteAll();
    expect(http.delete).toHaveBeenCalledWith("/tutorials");
  });

  it("findByTitle(title) hace GET con query title", () => {
    TutorialDataService.findByTitle("node");
    expect(http.get).toHaveBeenCalledWith("/tutorials?title=node");
  });
});
