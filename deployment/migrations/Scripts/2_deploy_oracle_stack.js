const CPTStore = artifacts.require("CPTStore");
const EvidenceRegistry = artifacts.require("EvidenceRegistry");
const OracleController = artifacts.require("OracleController");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(EvidenceRegistry);
  const evidenceRegistry = await EvidenceRegistry.deployed();

  const cptStore = await CPTStore.deployed();

  await deployer.deploy(OracleController, cptStore.address, evidenceRegistry.address);
};
