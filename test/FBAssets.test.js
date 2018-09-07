var FBAssets = artifacts.require("./FBAssets.sol");

contract('FBAssets', async (accounts) => {

    owner = accounts[0]
    someone = accounts[1]

    beforeEach(async () => {
        this.fbAssets = await FBAssets.new({from: owner});
    });

    it("should let you manage some assets", async() => {
        await this.fbAssets.addAsset.sendTransaction("kebab", {from:owner});
        await this.fbAssets.addAsset.sendTransaction("sausage", {from:owner});
        asset = await this.fbAssets.getAsset(0);
        console.log('------------------------------------');
        console.log(`asset is ${asset}`);
        console.log('------------------------------------');
        assert.equal(asset[0], "kebab")

        await this.fbAssets.sellAsset.sendTransaction(0, {from:owner});
        asset = await this.fbAssets.getAsset(0);
        assert.equal(asset[2] > 0, true)

        await this.fbAssets.throwAsset.sendTransaction(1, {from:owner});
        sausage = await this.fbAssets.getAsset(1);
        assert.equal(sausage[3] > 0, true)
    });
});