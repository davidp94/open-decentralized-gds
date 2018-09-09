var FlightInventory = artifacts.require("FlightInventory.sol");


// Dependencies
var RevenueManagementSystemV1 = artifacts.require("RevenueManagementSystemV1.sol");
var StableToken = artifacts.require("StableToken.sol");
var LoyaltyToken = artifacts.require("LoyaltyToken.sol");

// Extras
var FBAssets = artifacts.require("FBAssets.sol");

module.exports = async (deployer, network, accounts) => {

    // one that can update the price.
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

    Promise.all([
            deployer.deploy(FBAssets),
            deployer.deploy(StableToken),
            deployer.deploy(LoyaltyToken),
            deployer.deploy(RevenueManagementSystemV1, [100])
        ])
        .then(() => {
            return Promise.all([
                LoyaltyToken.deployed(),
                StableToken.deployed(),
                RevenueManagementSystemV1.deployed(),
            ]);
        })
        .then((data) => {
            this.lt = data[0];
            this.st = data[1];
            this.rms = data[2];
            return deployer.deploy(FlightInventory, this.rms.address, // RMS
                "SIA9300",
                100000,
                200000,
                5000,
                reporter,
                400,
                this.st.address,
                this.lt.address);
        })
        .then(() => {
            return FlightInventory.deployed();
        })
        .then((fi) => {
            console.log('------------------------------------');
            console.log(fi.address);
            console.log('------------------------------------');
            this.fi = fi;
        })

};