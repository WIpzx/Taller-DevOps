// Tests unitarios reales del controlador de Tutorials.
// Se mockea la capa de modelos (Sequelize) para no depender de una BD.
// Cubren ramas de éxito y de error de los 7 endpoints.

jest.mock("../models", () => {
  const Op = { like: Symbol("like") };
  return {
    Sequelize: { Op },
    tutorials: {
      create: jest.fn(),
      findAll: jest.fn(),
      findByPk: jest.fn(),
      update: jest.fn(),
      destroy: jest.fn()
    }
  };
});

const db = require("../models");
const Tutorial = db.tutorials;
const controller = require("./tutorial.controller");

// Espera a que se resuelvan las promesas encadenadas (.then/.catch).
const flush = () => new Promise((resolve) => setImmediate(resolve));

const makeRes = () => {
  const res = {};
  res.status = jest.fn(() => res);
  res.send = jest.fn(() => res);
  return res;
};

beforeEach(() => {
  jest.clearAllMocks();
});

describe("create", () => {
  test("responde 400 si falta el título", () => {
    const req = { body: {} };
    const res = makeRes();
    controller.create(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.send).toHaveBeenCalledWith({ message: "Content can not be empty!" });
    expect(Tutorial.create).not.toHaveBeenCalled();
  });

  test("crea y devuelve el tutorial (published por defecto false)", async () => {
    Tutorial.create.mockResolvedValue({ id: 1, title: "t" });
    const req = { body: { title: "t", description: "d" } };
    const res = makeRes();
    controller.create(req, res);
    await flush();
    expect(Tutorial.create).toHaveBeenCalledWith({
      title: "t",
      description: "d",
      published: false
    });
    expect(res.send).toHaveBeenCalledWith({ id: 1, title: "t" });
  });

  test("respeta published=true cuando se envía", async () => {
    Tutorial.create.mockResolvedValue({ id: 2 });
    const req = { body: { title: "t", published: true } };
    const res = makeRes();
    controller.create(req, res);
    await flush();
    expect(Tutorial.create).toHaveBeenCalledWith(
      expect.objectContaining({ published: true })
    );
  });

  test("responde 500 si falla la creación", async () => {
    Tutorial.create.mockRejectedValue(new Error("boom"));
    const req = { body: { title: "t" } };
    const res = makeRes();
    controller.create(req, res);
    await flush();
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.send).toHaveBeenCalledWith({ message: "boom" });
  });
});

describe("findAll", () => {
  test("sin filtro de título devuelve todo", async () => {
    Tutorial.findAll.mockResolvedValue([{ id: 1 }]);
    const req = { query: {} };
    const res = makeRes();
    controller.findAll(req, res);
    await flush();
    expect(Tutorial.findAll).toHaveBeenCalledWith({ where: null });
    expect(res.send).toHaveBeenCalledWith([{ id: 1 }]);
  });

  test("con título aplica condición like", async () => {
    Tutorial.findAll.mockResolvedValue([]);
    const req = { query: { title: "node" } };
    const res = makeRes();
    controller.findAll(req, res);
    await flush();
    expect(Tutorial.findAll).toHaveBeenCalledWith({
      where: { title: { [db.Sequelize.Op.like]: "%node%" } }
    });
  });

  test("responde 500 ante error", async () => {
    Tutorial.findAll.mockRejectedValue(new Error("db down"));
    const req = { query: {} };
    const res = makeRes();
    controller.findAll(req, res);
    await flush();
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.send).toHaveBeenCalledWith({ message: "db down" });
  });
});

describe("findOne", () => {
  test("devuelve el tutorial encontrado", async () => {
    Tutorial.findByPk.mockResolvedValue({ id: 5 });
    const req = { params: { id: 5 } };
    const res = makeRes();
    controller.findOne(req, res);
    await flush();
    expect(Tutorial.findByPk).toHaveBeenCalledWith(5);
    expect(res.send).toHaveBeenCalledWith({ id: 5 });
  });

  test("responde 500 ante error", async () => {
    Tutorial.findByPk.mockRejectedValue(new Error("x"));
    const req = { params: { id: 9 } };
    const res = makeRes();
    controller.findOne(req, res);
    await flush();
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.send).toHaveBeenCalledWith({ message: "Error retrieving Tutorial with id=9" });
  });
});

describe("update", () => {
  test("éxito cuando num == 1", async () => {
    Tutorial.update.mockResolvedValue([1]);
    const req = { params: { id: 1 }, body: { title: "u" } };
    const res = makeRes();
    controller.update(req, res);
    await flush();
    expect(Tutorial.update).toHaveBeenCalledWith({ title: "u" }, { where: { id: 1 } });
    expect(res.send).toHaveBeenCalledWith({ message: "Tutorial was updated successfully." });
  });

  test("mensaje de no encontrado cuando num != 1", async () => {
    Tutorial.update.mockResolvedValue([0]);
    const req = { params: { id: 7 }, body: {} };
    const res = makeRes();
    controller.update(req, res);
    await flush();
    expect(res.send).toHaveBeenCalledWith({
      message: "Cannot update Tutorial with id=7. Maybe Tutorial was not found or req.body is empty!"
    });
  });

  test("responde 500 ante error", async () => {
    Tutorial.update.mockRejectedValue(new Error("x"));
    const req = { params: { id: 3 }, body: {} };
    const res = makeRes();
    controller.update(req, res);
    await flush();
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.send).toHaveBeenCalledWith({ message: "Error updating Tutorial with id=3" });
  });
});

describe("delete", () => {
  test("éxito cuando num == 1", async () => {
    Tutorial.destroy.mockResolvedValue(1);
    const req = { params: { id: 1 } };
    const res = makeRes();
    controller.delete(req, res);
    await flush();
    expect(Tutorial.destroy).toHaveBeenCalledWith({ where: { id: 1 } });
    expect(res.send).toHaveBeenCalledWith({ message: "Tutorial was deleted successfully!" });
  });

  test("mensaje de no encontrado cuando num != 1", async () => {
    Tutorial.destroy.mockResolvedValue(0);
    const req = { params: { id: 8 } };
    const res = makeRes();
    controller.delete(req, res);
    await flush();
    expect(res.send).toHaveBeenCalledWith({
      message: "Cannot delete Tutorial with id=8. Maybe Tutorial was not found!"
    });
  });

  test("responde 500 ante error", async () => {
    Tutorial.destroy.mockRejectedValue(new Error("x"));
    const req = { params: { id: 2 } };
    const res = makeRes();
    controller.delete(req, res);
    await flush();
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.send).toHaveBeenCalledWith({ message: "Could not delete Tutorial with id=2" });
  });
});

describe("deleteAll", () => {
  test("devuelve cantidad eliminada", async () => {
    Tutorial.destroy.mockResolvedValue(3);
    const req = {};
    const res = makeRes();
    controller.deleteAll(req, res);
    await flush();
    expect(Tutorial.destroy).toHaveBeenCalledWith({ where: {}, truncate: false });
    expect(res.send).toHaveBeenCalledWith({ message: "3 Tutorials were deleted successfully!" });
  });

  test("responde 500 ante error", async () => {
    Tutorial.destroy.mockRejectedValue(new Error("nope"));
    const req = {};
    const res = makeRes();
    controller.deleteAll(req, res);
    await flush();
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.send).toHaveBeenCalledWith({ message: "nope" });
  });
});

describe("findAllPublished", () => {
  test("devuelve los publicados", async () => {
    Tutorial.findAll.mockResolvedValue([{ id: 1, published: true }]);
    const req = {};
    const res = makeRes();
    controller.findAllPublished(req, res);
    await flush();
    expect(Tutorial.findAll).toHaveBeenCalledWith({ where: { published: true } });
    expect(res.send).toHaveBeenCalledWith([{ id: 1, published: true }]);
  });

  test("responde 500 ante error", async () => {
    Tutorial.findAll.mockRejectedValue(new Error("err"));
    const req = {};
    const res = makeRes();
    controller.findAllPublished(req, res);
    await flush();
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.send).toHaveBeenCalledWith({ message: "err" });
  });
});
