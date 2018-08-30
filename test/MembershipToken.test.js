var MembershipToken = artifacts.require("./MembershipToken.sol");

contract('MembershipToken', async (accounts) => {

    owner = accounts[0]
    someone = accounts[1]

    beforeEach(async () => {
        this.membershipTokenInstance = await MembershipToken.new({from: owner});
        console.log('------------------------------------');
        console.log(`Contract deployed at ${this.membershipTokenInstance.address}`);
        console.log('------------------------------------');
    });

    it(`deployer should have 0 token`, async () => {
        assert.equal(await this.membershipTokenInstance.balanceOf.call(owner), 0);
    });


    it("should be able to mint tokens", async() => {
        receipt = await this.membershipTokenInstance.mint.sendTransaction(someone, 100, {from: owner});
        assert.equal(await this.membershipTokenInstance.balanceOf.call(someone), 100);
    });
});