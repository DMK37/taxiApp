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
    ganache: {
      url: "http://192.168.18.115:8545",
      accounts: [
        `0x2ace5848714a1da84e858a534552f4d58495c625b40d2f75f5c8373ee0b70652`,
        `0x3dfab05bece011b26f4c6c25fb8a7dae946c945e5b2fd19f227e5f4e0a61e5f8`
      ],
    }
  },

  etherscan: {
    apiKey: "KVMPE9VUUMI5CZ285PR9KIKYSDC3JZX45M",
  },
};
