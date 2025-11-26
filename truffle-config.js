// truffle-config.js
require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  contracts_directory: "./contracts",
  contracts_build_directory: "./deployment/build",

  networks: {
    // Local Ganache
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },

    // Sepolia (optional, for later)
    sepolia: {
      provider: () =>
        new HDWalletProvider(
          process.env.PRIVATE_KEY,
          `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`
        ),
      network_id: 11155111,
      gas: 6000000,
    },
  },

  compilers: {
    solc: {
      version: "0.8.17",
    },
  },
};
