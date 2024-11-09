require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    hardhat: {
      chainId: 1337,
      accounts: {
        mnemonic:
          "auction just pulp assault cattle jungle gift absurd junior notice scatter orbit",
      },
    },
  },
};
