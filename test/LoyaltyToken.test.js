var LoyaltyToken = artifacts.require("./LoyaltyToken.sol");


var {expectThrow} = require('./helpers/expectThrow.js');
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

    it("should not be able to send more tokens that he owns", async () => {
        receipt = await this.loyaltyTokenInstance.transfer.sendTransaction(someone, 100, {from: owner});
        assert.equal(await this.loyaltyTokenInstance.balanceOf.call(someone), 100);
        

        // someone makes a transaction greater than his balance
        receipt = await expectThrow(this.loyaltyTokenInstance.transfer.sendTransaction(accounts[2], 101, {from: someone}));

        assert.equal(await this.loyaltyTokenInstance.balanceOf.call(someone), 100);        
    })
});