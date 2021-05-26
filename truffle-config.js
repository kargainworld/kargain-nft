const HDWalletProvider = require('@truffle/hdwallet-provider');
//const mnemonic_privatekey = process.env["MNEMONIC_PRIVATEKEY"];
const kargain_test_privatekey = "pilot potato spend dream mass genius tool advance spike artist patch swarm";
module.exports = {
   networks: {
    local: {
      provider: () => new HDWalletProvider(kargain_test_privatekey, "http://localhost"),
      port: 7545,            // Standard BSC port (default: none)
      network_id: "5777",       // Any network (default: none)

    },
    testnet: {
      provider: () => new HDWalletProvider(kargain_test_privatekey, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bsc: {
      provider: () => new HDWalletProvider(kargain_test_privatekey, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
   },
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.6.12", // A version or constraint - Ex. "^0.5.0"
    }
  }
}
