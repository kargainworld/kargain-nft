const { expect } = require('chai');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
const Box = artifacts.require('Box');
 
contract('Box (proxy)', function () {
  beforeEach(async function () {
    this.box = await deployProxy(Box, [42], {initializer: 'store'});
  });
 
  // Test case
  it('retrieve returns a value previously initialized', async function () {
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.box.retrieve()).toString()).to.equal('42');
  });
});