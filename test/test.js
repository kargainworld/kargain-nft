const Kargain = artifacts.require("Kargainv01");

contract("Kargainv01", (accounts) => {
  let [admin, seller, buyer] = accounts;

  let tokenId = Date.now();

  let instance;
  beforeEach("should setup the contract instance", async () => {
    instance = await Kargain.deployed();
  });

  it("Should initialize the contract correctly.", async () => {
    const result = await instance.initialize(admin, 4);
    const platformAddress = await instance.platformAddress();
    const platformCommissionPercent =
      await instance.platformCommissionPercent();

    assert.equal(result.receipt.status, true);
    assert.equal(platformAddress, admin);
    assert.equal(platformCommissionPercent, 4);
  });

  it("Should admin set platfom address ", async () => {
    const result = await instance.setPlatformAddress(accounts[9], {
      from: admin,
    });
    const platformAddress2 = await instance.platformAddress();

    assert.equal(result.receipt.status, true);
    assert.equal(platformAddress2, accounts[9]);
  });

  it("should be able to set platform comission percent", async () => {
    const result = await instance.setPlatformCommissionPercent(3, {
      from: admin,
    });
    const platformCommissionPercent =
      await instance.platformCommissionPercent();

    assert.equal(result.receipt.status, true);
    assert.equal(platformCommissionPercent, 3);
  });

  it("should be able to set offer expiration time", async () => {
    const result = await instance.setOfferExpirationTime(2, {
      from: admin,
    });

    const offerExpirationTime = await instance.offerExpirationTime();

    assert.equal(result.receipt.status, true);
    assert.equal(offerExpirationTime, 2);
  });

  it("should be able to create a new token", async () => {
    const result = await instance.mint(
      tokenId,
      web3.utils.toWei("4", "ether"),
      { from: seller }
    );
    const newOwner = await instance.ownerOf(tokenId);
    const tokenPrice = await instance.tokenPrice(tokenId);

    assert.equal(result.receipt.status, true);
    assert.equal(newOwner, seller);
    assert.equal(tokenPrice, web3.utils.toWei("4", "ether"));
  });

  it("should be able to create a new offer", async () => {
    const result = await instance.createOffer(tokenId, {
      from: buyer,
      value: web3.utils.toWei("4", "ether"),
    });

    const offerAdress = await instance.offerAddress(tokenId);
    assert.equal(result.receipt.status, true);
    assert.equal(offerAdress, buyer);
  });

  it("should be able to accept an offer", async () => {
    const result = await instance.acceptOffer(tokenId, {
      from: seller,
    });
    const newOwner = await instance.ownerOf(tokenId);

    assert.equal(result.receipt.status, true);
    assert.equal(newOwner, buyer);
  });

  it("should be able to cancel an offer", async () => {
    await instance.mint(123, web3.utils.toWei("4", "ether"), {
      from: seller,
    });

    await instance.createOffer(123, {
      from: buyer,
      value: web3.utils.toWei("4", "ether"),
    });

    const result = await instance.cancelOffer(123, {
      from: buyer,
    });

    assert.equal(result.receipt.status, true);
  });

  it("should be able to reject an offer", async () => {
    await instance.mint(124, web3.utils.toWei("4", "ether"), {
      from: seller,
    });

    await instance.createOffer(124, {
      from: buyer,
      value: web3.utils.toWei("4", "ether"),
    });

    const result = await instance.rejectOffer(124, {
      from: seller,
    });

    assert.equal(result.receipt.status, true);
  });

  it("should be able to burn the token", async () => {
    const result = await instance.burn(tokenId, {
      from: buyer,
    });
    assert.equal(result.receipt.status, true);
  });

  it('retrieve returns a value previously initialized', async () => {
    const result = await instance.version();
    assert.equal(result, "Kargain v02");
  });
});
