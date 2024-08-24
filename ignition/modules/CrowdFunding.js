const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");


module.exports = buildModule("LockModule", (m) => {

  const CrowdFunding = m.contract("CrowdFunding");

  return { CrowdFunding };
});
