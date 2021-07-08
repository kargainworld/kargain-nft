const Kargain = artifacts.require("Kargain");

module.exports = async (deployer, network, accounts) => {
  deployer.deploy(Kargain);
  const instance = await Kargain.deployed();
  await instance.initialize(accounts[0], 10)
};