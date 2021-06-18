const Kargainv01 = artifacts.require("Kargainv01");

module.exports = async function (deployer,network,accounts) {
  await deployer.deploy(Kargainv01);
  console.log(`Kargainv01 Contract deployed on ${network} network`);
  
  const instance = await Kargainv01.deployed();
  console.log(`Setting ${accounts[0]} as admin address`);

  await instance.initialize(accounts[0],4);
  console.log("Kargainv01 initialized");
  
  const output = await instance.version();
  console.log(`Version: ${output}`);
};
