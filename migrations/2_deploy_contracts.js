const FBAssets = artifacts.require("FBAssets.sol")

module.exports = async (deployer) => {
    var fbInstance = await FBAssets.deployed();

    await fbInstance.addAsset("First asset")
};
