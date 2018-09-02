var FlightInventory = artifacts.require("./FlightInventory.sol");


// Dependencies
var RevenueManagementSystemV1 = artifacts.require("./RevenueManagementSystemV1.sol");
var StableToken = artifacts.require("./StableToken.sol");
var LoyaltyToken = artifacts.require("./LoyaltyToken.sol");

// Extras
// TODO: FBAssets

// TODO: Insurance

// Helpers
var expectEvent = require('./helpers/expectEvent.js');



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

    deployRow = async () => {
        await expectEvent.inTransaction(
            this.fi.addSeat("1A", false, {from: fiEmitter}),
            'NewSeat'
        );

        await expectEvent.inTransaction(
            this.fi.addSeat("1B", false, {from: fiEmitter}),
            'NewSeat'
        );

        await expectEvent.inTransaction(
            this.fi.addSeat("1C", false, {from: fiEmitter}),
            'NewSeat'
        );

        await expectEvent.inTransaction(
            this.fi.addSeat("1D", false, {from: fiEmitter}),
            'NewSeat'
        );

        await expectEvent.inTransaction(
            this.fi.addSeat("1E", false, {from: fiEmitter}),
            'NewSeat'
        );

        await expectEvent.inTransaction(
            this.fi.addSeat("1F", false, {from: fiEmitter}),
            'NewSeat'
        );
    }

    it("should deploy <Minimal Viable Contract> and add a row of seats", async () => {
        assert.equal(await this.fi.emitter.call(), fiEmitter)

        await deployRow();

        assert.equal((await this.fi.seatsContracts(0))[5], "1A")  
        assert.equal((await this.fi.seatsContracts(1))[5], "1B")  
        assert.equal((await this.fi.seatsContracts(2))[5], "1C")  
        assert.equal((await this.fi.seatsContracts(3))[5], "1D")  
        assert.equal((await this.fi.seatsContracts(4))[5], "1E")  
        assert.equal((await this.fi.seatsContracts(5))[5], "1F")  
 
        
    });

    it("should deploy <Minimal Viable Contract> and add a row of seats, then let a consumer checks the price and book one seat.", async () => {
        assert.equal(await this.fi.emitter.call(), fiEmitter)

        await deployRow(); 

        consumerAddress = accounts[42];
        // consumer got some tokens from some DEX
        this.st.transfer(consumerAddress, 10000, {from: stEmitter});
        assert.equal(await this.st.balanceOf(consumerAddress), 10000)

        
        assert.equal((await this.fi.seatsContracts(0))[5], "1A")  
        assert.equal((await this.fi.seatsContracts(0))[2], "0x0000000000000000000000000000000000000000")   // .booker
        

        priceForConsumer = await this.fi.getPrice()

        // consumer allow contract to withdraw priceForConsumer
        this.st.approve(this.fi.address, priceForConsumer, {from: consumerAddress});
        // assert.equal((await this.st.allowance(consumerAddress, this.fi))[0], 100);   // TODO: debug 

        // Booking
        console.log(`${consumerAddress} calls book(0)`);
        await this.fi.book.sendTransaction(0, {from: consumerAddress});

        assert.equal((await this.fi.seatsContracts(0))[2], consumerAddress)   // .booker        
    });

});