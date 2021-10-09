require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonicPrivateKey = process.env["MNEMONIC_PRIVATEKEY"];
const mnemonicPrivateKeyTesnet = process.env["MNEMONIC_PRIVATEKEY_TESNET"];
const infura = process.env["INFURA_PROJECT_ID"]

module.exports = {
   networks: {
    local: {
      provider: () => new HDWalletProvider(mnemonicPrivateKey, "http://localhost:7545"),
      port: 7545,            // Standard BSC port (default: none)
      network_id: "5777",       // Any network (default: none)
    },
    testnet: {
      provider: () => new HDWalletProvider(mnemonicPrivateKeyTesnet, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bsc: {
      provider: () => new HDWalletProvider(mnemonicPrivateKeyTesnet, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    ropsten: {
       provider: function() {
           return new HDWalletProvider(mnemonicPrivateKeyTesnet, `https://ropsten.infura.io/v3/${infura}`, 0, 10)
       },
       network_id: 3,
        gasLimit: 8000000,
        gasPrice: 2100000,
    }
   },
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },
  plugins: ["solidity-coverage"],
  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.6.12", // A version or constraint - Ex. "^0.5.0"
    }
  }
}
