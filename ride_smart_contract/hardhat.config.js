require("@nomicfoundation/hardhat-toolbox");

const ALCHEMY_API_KEY = "YOUR_ALCHEMY_API_KEY";
const SEPOLIA_PRIVATE_KEY = "YOUR_SEPOLIA_PRIVATE_KEY";

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
    // sepolia: {
    //   url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
    //   accounts: [SEPOLIA_PRIVATE_KEY],
    // }
  },

  // etherscan: {
  //   apiKey: "YOUR_ETHER_SCAN_API_KEY",
  // },
};
