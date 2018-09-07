pragma solidity ^0.4.4;

import '../zeppelin-utils/ownership/Ownable.sol';
import '../Flights/FlightInventory.sol';
import '../StableToken/StableToken.sol';


contract InsuranceV1 is Ownable {

    mapping(address => uint) public balances;
    address public insuree;
    uint public price;
    uint public rewardIfMinimumDelay;
    uint public minimumDelay;

    FlightInventory flightInventoryInstance = FlightInventory(0x0);

    StableToken stableTokenInstance = StableToken(0x0);

    function InsuranceV1(address _flightToInsure, address _insuree, uint _price, uint _rewardIfMinimumDelay, uint _minimumDelay, address _stableTokenAddress) public {
        flightInventoryInstance = FlightInventory(_flightToInsure);
        stableTokenInstance = StableToken(_stableTokenAddress);
        rewardIfMinimumDelay = _rewardIfMinimumDelay;
        price = _price;
        minimumDelay = _minimumDelay;
    }

    function depositInsurer() public onlyOwner {
        require(stableTokenInstance.transferFrom(owner, this, rewardIfMinimumDelay));
        balances[owner] += rewardIfMinimumDelay;
    }

    function depositInsuree() public {
        // insuree can deposit before check-in time
        require(now < flightInventoryInstance.getCheckInBegin());

        require(msg.sender == insuree);
        require(stableTokenInstance.transferFrom(msg.sender, this, price));
        balances[owner] += price;
    }

    function claim() public {
        // claim your money only after end of the flight
        require(flightInventoryInstance.isEnded());
        require(msg.sender == owner || msg.sender == insuree);
        if(flightInventoryInstance.getDelayArrival() > minimumDelay) {
            balances[owner] -= rewardIfMinimumDelay;
            balances[insuree] += rewardIfMinimumDelay;
        }
    }

    function withdrawFunds() public {
        // withdraw only after end of the flight
        require(flightInventoryInstance.isEnded());
        
        require(balances[msg.sender] > 0);
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        require(stableTokenInstance.transferFrom(this, msg.sender, amount));
    }

    
}