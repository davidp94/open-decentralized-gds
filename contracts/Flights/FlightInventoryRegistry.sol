pragma solidity ^0.4.4;

import '../zeppelin-utils/ownership/Ownable.sol';

// davidphan.eth
// this contract allow to have a DB of flights
contract FlightInventoryRegistry is Ownable {

    string public registryName;

    function FlightInventoryRegistry(string _name) public {
        registryName = _name;
    }

    address[] public flightInventoryArray;

    function addFlightInventory(address _address) public onlyOwner {
        flightInventoryArray.push(_address);
    }

}