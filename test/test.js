const Kargain = artifacts.require('Kargain'),
truffleAssert = require('truffle-assertions')

contract('Kargain', async (accounts) => {

    let instance;
    beforeEach('should setup the contract instance', async () => {
        instance = await Kargain.deployed();
    });


    it("Should initialize the contract correctly.", async ()=> {
    await instance.initialize(accounts[0],4)
    const platformAddress = await  instance.platformAddress();
    const platformCommissionPercent = await  instance.platformCommissionPercent();

    assert.equal(platformAddress,accounts[0]);
    assert.equal(platformCommissionPercent,4);
    });

    it("Should admin set platfomAddress only ", async ()=> {
        
        //await instance.setPlatformAddress(accounts[9],{from:accounts[1]});
        //const platformAddress = await  instance.platformAddress();
        //assert.equal(platformAddress,accounts[0]);

        await instance.setPlatformAddress(accounts[9],{from:accounts[0]});
        const platformAddress2 = await  instance.platformAddress();
        assert.equal(platformAddress2,accounts[9]);
    });
    
    it("Should set platformCommissionPercent", async ()=> {
        assert.equal(true,false);
    });

    it("Should mint a new KGN nft with tokenId = 126", async ()=> {
        assert.equal(true,false);
    });
    it("Shouldn't mint a new KGN nft with  tokenId = 126", async ()=> {
        assert.equal(true,false);
    });
})
