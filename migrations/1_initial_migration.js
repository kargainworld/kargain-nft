const Kargainv01 = artifacts.require('Kargainv01');


module.exports = async function (deployer,network,accounts) {

    await deployer.deploy(Kargainv01);
    console.log("contract deployed");
    
    const instance = await Kargainv01.deployed();
    console.log("starting  initialization for address: "+accounts[0]);

    await instance.initialize(accounts[0],4);
    console.log("contract initialized");
    
    const output = await instance.version();
    console.log("Version: "+output )
};
