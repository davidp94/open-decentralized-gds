var RevenueManagementSystemV1 = artifacts.require("./RevenueManagementSystemV1.sol");

var { expectThrow } = require('./helpers/expectThrow');

contract('RevenueManagementSystemV1', async (accounts) => {

    owner = accounts[0]
    someone = accounts[1]

    beforeEach(async () => {
        this.rms = await RevenueManagementSystemV1.new([3,4,5], {from: owner});
        console.log('------------------------------------');
        console.log(`Contract deployed at ${this.rms.address}`);
        console.log('------------------------------------');
    });

    it(`analyst should be the deployer`, async () => {
        assert.equal(await this.rms.analyst.call(), owner);
    });


    it("should be getting price", async() => {
        price = await this.rms.getPrice.call(1);
        assert.equal(price, 4);
    });

    it("should let analyst update the price", async() => {
        price = await this.rms.getPrice.call(1);
        assert.equal(price, 4);
        await this.rms.updatePricingArray.sendTransaction([54], {from: owner});
        price = await this.rms.getPrice.call(1);
        assert.equal(price, 54);
    });

    it("should not let random update the price", async() => {
        price = await this.rms.getPrice.call(1);
        assert.equal(price, 4);
        await expectThrow(this.rms.updatePricingArray.sendTransaction([54], {from: accounts[3]}));
        price = await this.rms.getPrice.call(1);
        assert.equal(price, 4);
    });
});