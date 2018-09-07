const FBAssets = artifacts.require("FBAssets.sol")

module.exports = function(deployer) {
    deployer.deploy(FBAssets);
};
