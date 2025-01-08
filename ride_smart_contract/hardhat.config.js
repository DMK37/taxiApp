require("@nomicfoundation/hardhat-toolbox");

const ALCHEMY_API_KEY = "NrELA9svvUdoOJpvRMN7cWIWsA93LDiz";
const SEPOLIA_PRIVATE_KEY = "4b58b500da3c29bbdb0ccc26f3fc371249c7815139328632d08b816abf827b39";

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
      loggingEnabled: true,
      gas: 10000000,
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [SEPOLIA_PRIVATE_KEY],
    },
    local: {
      url: "http://192.168.18.108:8545",
      gas: 10000000,
    },
  },

  etherscan: {
    apiKey: "KVMPE9VUUMI5CZ285PR9KIKYSDC3JZX45M",
  },
};
