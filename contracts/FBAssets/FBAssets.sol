pragma solidity ^0.4.4;

import '../zeppelin-utils/ownership/Ownable.sol';

contract FBAssets is Ownable {

    struct FBAsset {
        string sku;
        uint createdAt;
        uint soldAt;
        uint thrownAt; 
    }

    FBAsset[] public fbAssets;
    address public flightInventory;
    
    function FBAssets() public {
    }

    function setFlightInventory(address _fiAddress) public onlyOwner {
        flightInventory = _fiAddress;
    }
    
    function addAsset(string sku) public onlyOwner {
        fbAssets.push(FBAsset({
            sku: sku,
            createdAt: now,
            soldAt: 0,
            thrownAt: 0
        }));
    }

    function sellAsset(uint _index) public onlyOwner {
        require(fbAssets[_index].createdAt > 0);
        require(fbAssets[_index].soldAt == 0);
        require(fbAssets[_index].thrownAt == 0);
        fbAssets[_index].soldAt = now;
    }

    function throwAsset(uint _index) public onlyOwner {
        require(fbAssets[_index].createdAt > 0);
        require(fbAssets[_index].soldAt == 0);
        require(fbAssets[_index].thrownAt == 0);
        fbAssets[_index].thrownAt = now;
    }

    function getAsset(uint _index) public constant returns (string sku, uint createdAt, uint soldAt, uint thrownAt) {
        require(fbAssets[_index].createdAt > 0);
        sku = fbAssets[_index].sku;
        createdAt = fbAssets[_index].createdAt;
        soldAt = fbAssets[_index].soldAt;
        thrownAt = fbAssets[_index].thrownAt;
    }

    function getAssetCount() public constant returns (uint count) {
        return fbAssets.length;
    } 

}