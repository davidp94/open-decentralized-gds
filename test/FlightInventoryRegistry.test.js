var FlightInventoryRegistry = artifacts.require("./FlightInventoryRegistry.sol");

contract('FlightInventoryRegistry', async (accounts) => {

    owner = accounts[0]
    someone = accounts[1]

    beforeEach(async () => {
        this.fir = await FlightInventoryRegistry.new("my airline", {from: owner});
    });

    it(`add some contract addresses`, async () => {
        assert.equal(await this.fir.registryName.call(), "my airline");
        await this.fir.addFlightInventory.sendTransaction(accounts[2])
        assert.equal(await this.fir.flightInventoryArray.call(0), accounts[2]);
    });

});