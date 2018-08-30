var MembershipToken = artifacts.require("./MembershipToken.sol");
var IsMemberTest = artifacts.require("./IsMemberTest.sol");

contract('IsMemberTest', async (accounts) => {

    owner = accounts[0]
    someone = accounts[1]

    beforeEach(async () => {
        this.membershipTokenInstance = await MembershipToken.new({from: owner});
        console.log('------------------------------------');
        console.log(`Contract deployed at ${this.membershipTokenInstance.address}`);
        console.log('------------------------------------');
        this.isMemberTest = await IsMemberTest.new(this.membershipTokenInstance.address, {from:owner});
    });

    it(`deployer should have 0 token`, async () => {
        assert.equal(await this.membershipTokenInstance.balanceOf.call(owner), 0);
    });


    it("should return true for member owning token, and false for non owner of token", async() => {
        receipt = await this.membershipTokenInstance.mint.sendTransaction(someone, 100, {from: owner});
        assert.equal(await this.membershipTokenInstance.balanceOf.call(someone), 100);
        assert.equal(await this.isMemberTest.isMember.call(someone), true);
        assert.equal(await this.isMemberTest.isMember.call(accounts[2]), false);
    });
});