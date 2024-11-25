const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Ride", (m) => {
    const ride = m.contract("Ride");
    return ride;
});