// Test unitario de la fábrica del modelo Tutorial.
// Verifica que define() se invoque con los campos esperados.

const buildTutorialModel = require("./tutorial.model");

test("define el modelo 'tutorial' con title, description y published", () => {
  const fakeModel = { name: "tutorial" };
  const define = jest.fn(() => fakeModel);
  const sequelize = { define };
  const Sequelize = { STRING: "STRING", BOOLEAN: "BOOLEAN" };

  const result = buildTutorialModel(sequelize, Sequelize);

  expect(define).toHaveBeenCalledWith("tutorial", {
    title: { type: "STRING" },
    description: { type: "STRING" },
    published: { type: "BOOLEAN" }
  });
  expect(result).toBe(fakeModel);
});
