var LoyaltyToken = artifacts.require("./LoyaltyToken.sol");

contract('LoyaltyToken', async (accounts) => {

    owner = accounts[0]
    someone = accounts[1]

    decimals = 18
    INITIAL_SUPPLY = 10000 * (10 ** decimals)
    beforeEach(async () => {
        this.loyaltyTokenInstance = await LoyaltyToken.new({from: owner});
        console.log('------------------------------------');
        console.log(`Contract deployed at ${this.loyaltyTokenInstance.address}`);
        console.log('------------------------------------');
    });

    it(`deployer should have ${INITIAL_SUPPLY} tokens`, async () => {
        assert.equal(await this.loyaltyTokenInstance.balanceOf.call(owner), INITIAL_SUPPLY);
    });


    it("should be able to send tokens", async() => {
        receipt = await this.loyaltyTokenInstance.transfer.sendTransaction(someone, 100, {from: owner});
        assert.equal(await this.loyaltyTokenInstance.balanceOf.call(someone), 100);
    });
});