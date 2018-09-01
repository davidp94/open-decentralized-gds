var FlightInventory = artifacts.require("./FlightInventory.sol");


// Dependencies
var RevenueManagementSystemV1 = artifacts.require("./RevenueManagementSystemV1.sol");
var StableToken = artifacts.require("./StableToken.sol");
var LoyaltyToken = artifacts.require("./LoyaltyToken.sol");

// Extras
// TODO: FBAssets

// TODO: Insurance



contract('FlightInventory', async (accounts) => {

    // This is the trusted operator that will manage the price
    priceAnalyst = accounts[0]

    // This is the trusted reporter that would set the actual arrival and departure time
    reporter = accounts[1]

    // StableToken Emitter
    stEmitter = accounts[2]

    // LoyaltyToken Emitter
    ltEmitter = accounts[3]

    // FlightInventory Owner
    fiEmitter = accounts[4]


    random = accounts[99]


    beforeEach(async () => {
        // Deploy a RevenueManagementSystemV1
        // By the Price Analyst
        // with price 100
        this.rms = await RevenueManagementSystemV1.new([100], {
            from: priceAnalyst
        });
        console.log('------------------------------------');
        console.log(`Deployed RMSV1 at ${this.rms.address}`);
        console.log('------------------------------------');

        // Deploy the StableToken
        this.st = await StableToken.new({
            from: stEmitter
        });
        console.log('------------------------------------');
        console.log(`Deployed StableToken at ${this.st.address}`);
        console.log('------------------------------------');

        // Deploy the LoyaltyToken
        this.lt = await LoyaltyToken.new({
            from: ltEmitter
        });
        console.log('------------------------------------');
        console.log(`Deployed LoyaltyToken at ${this.lt.address}`);
        console.log('------------------------------------');

        // FlightInventory Deployment
        // TODO: create a wrapper so can be used by Oracle
        this.fi = await FlightInventory.new(
            this.rms.address, // RMS
            "SIA9300",
            100000,
            200000,
            5000,
            reporter,
            400,
            this.st.address,
            this.lt.address,
            {
                from: fiEmitter
            });

        console.log('------------------------------------');
        console.log(`Deployed FlightInventory at ${this.fi.address}`);
        console.log('------------------------------------');



    })


    it("should deploy <Minimal Viable Contract>", async () => {
        assert.equal(await this.fi.emitter.call(), fiEmitter)
    });

});