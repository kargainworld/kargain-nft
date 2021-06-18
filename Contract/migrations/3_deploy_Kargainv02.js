const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Kargainv01 = artifacts.require('Kargainv01');
const Kargainv02 = artifacts.require('Kargainv02');

module.exports = async function (deployer) {
  const Kargainv01instance = await Kargainv01.deployed();
  console.log(`Picked proxy @ ${Kargainv01instance.address} for update...`);
  
  const Kargainv02instance = await upgradeProxy(Kargainv01instance.address, Kargainv02, { deployer });
  console.log(`Proxy Upgraded ${Kargainv02instance.address}`);
  
  const output = await Kargainv01instance.version();
  console.log(`Version: ${output}`);
};