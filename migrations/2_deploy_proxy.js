const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const Kargainv01 = artifacts.require('Kargainv01');

module.exports = async function (deployer) {
  const instance = await deployProxy(Kargainv01, { deployer, initializer: false});
  console.log('Proxy Deployed', instance.address);
  const output = await instance.version();
  console.log('Version', output );
}