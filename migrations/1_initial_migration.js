const KargainV01 = artifacts.require('KargainV01');
const { deployProxy } = require('@openzeppelin/truffle-upgrades')

module.exports = async function (deployer, network, accounts) {
    const [kargainAdmin] = accounts
    const initialPlatformCommissionPercent = 3 // %
    const deployedKargain = await deployProxy(KargainV01, [kargainAdmin, initialPlatformCommissionPercent], { deployer })
    
    console.log('Kargain Contract: ' + deployedKargain.address)

    const version = await deployedKargain.version()
    console.log('Kargain version: ' + version)
    const commission = await deployedKargain.platformCommissionPercent()
    console.log('Kargain commission: ' + commission)
};