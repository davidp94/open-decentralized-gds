pragma solidity ^0.4.4;

import "./RevenueManagementSystem.sol";
import "./FlightSeat.sol";
import "../StableToken/StableToken.sol";
import "../LoyaltyToken/LoyaltyToken.sol";


//davidphan.eth
contract FlightInventory {
    
    address public emitter;
    
    address public revenueManagementSystem;
    RevenueManagementSystem public revenueManagementSystemInstance = RevenueManagementSystem(0x0);
    
    string public identifier;
    uint public checkInPeriod; // seconds before scheduled departure - check in opens
    uint public scheduledDepartureTimestamp;
    uint public scheduledArrivalTimestamp;
    
    address public reporter;
    uint public actualDepartureTimestamp;
    uint public actualArrivalTimestamp;
    
    //payment in token
    StableToken public StableTokenInstance = StableToken(0x0);

    //loyalty
    LoyaltyToken public loyaltyTokenInstance = LoyaltyToken(0x0);
    uint public bookingLoyaltyToken; // miles
    
    
    event NewSeat(address _emitter, uint _seatNumber, address _seatContractAddress);
    event RemoveSeat(address _emitter, uint _seatNumber, address _seatContractAddress);
    
    address[] public seatsContracts;
    mapping(address => bool) seatsExists;
    uint remainingSeats = 0;

    
    modifier onlyEmitter {
        require(msg.sender == emitter);
        _;
    }
    
    modifier onlyReporter {
        require(msg.sender == reporter);
        _;
    }
    
    modifier seatNotExists(address _s) {
        require(!seatsExists[_s]);
        _;
    }
    
    modifier seatExists(uint _seatIndex, address _s) {
        require(seatsContracts[_seatIndex] == _s);
        require(seatsExists[_s]);
        _;
    }
    
    modifier seatIndexExists(uint _seatIndex) {
        require(seatsContracts[_seatIndex] != 0x0);
        _;
    }
    
    function FlightInventory(address _revenueManagementSystemAddress, string _identifier, uint _scheduledDepartureTimestamp, uint _scheduledArrivalTimestamp, uint _checkInPeriod, address _trustedReporter, uint _miles, address _StableTokenAddress, address _loyaltyTokenAddress) public {
        emitter = msg.sender;
        
        identifier = _identifier;
        checkInPeriod = _checkInPeriod;
        scheduledDepartureTimestamp = _scheduledDepartureTimestamp;
        scheduledArrivalTimestamp = _scheduledArrivalTimestamp;
        reporter = _trustedReporter;
        
        bookingLoyaltyToken = _miles;
        
        revenueManagementSystemInstance = RevenueManagementSystem(_revenueManagementSystemAddress);

        StableTokenInstance = StableToken(_StableTokenAddress);
        loyaltyTokenInstance = LoyaltyToken(_loyaltyTokenAddress);
    }
    
    function addSeatContract(address _seatContractAddress) public onlyEmitter seatNotExists(_seatContractAddress) {
        FlightSeat seatInstance = FlightSeat(_seatContractAddress);
        require(seatInstance.isBookable());
        require(seatInstance.getFlightInventory() == address(this));
        
        uint index = seatsContracts.push(_seatContractAddress);
        NewSeat(msg.sender, index, _seatContractAddress);
        remainingSeats++;
    }
    
    function removeSeatContract(uint _seatIndex, address _seatContractAddress) public onlyEmitter seatExists(_seatIndex, _seatContractAddress) {
        FlightSeat seatInstance = FlightSeat(_seatContractAddress);
        require(seatInstance.isBookable()); // not booked
        
        seatsContracts[_seatIndex] = 0x0;
        seatsExists[_seatContractAddress] = false;
        RemoveSeat(msg.sender, _seatIndex, _seatContractAddress);
        remainingSeats--;
    }
    
    function getCheckInBegin() public constant returns (uint) {
        return scheduledDepartureTimestamp - checkInPeriod;
    }
    
    function getPrice() public constant returns (uint) {
        return revenueManagementSystemInstance.getPrice(remainingSeats);
    }

    function book(uint _seatIndex) public seatIndexExists(_seatIndex) {
        require(StableTokenInstance.transferFrom(msg.sender, emitter, this.getPrice()));
        FlightSeat seatInstance = FlightSeat(seatsContracts[_seatIndex]);
        require(seatInstance.isBookable()); // not booked
        
        require(seatInstance.book(msg.sender));
        require(loyaltyTokenInstance.transferFrom(address(this), msg.sender, bookingLoyaltyToken));
    }
    
    
    function setActualDepartureTime(uint _ts) public onlyReporter {
        actualDepartureTimestamp = _ts;
    }
    
    function setActualArrivalTime(uint _ts) public onlyReporter {
        actualArrivalTimestamp = _ts;
    }
    
    function getDelayDeparture() public constant returns (uint) {
        if(actualDepartureTimestamp > 0 && actualDepartureTimestamp > scheduledDepartureTimestamp) {
            return actualDepartureTimestamp - scheduledDepartureTimestamp;
        }
        else {
            return 0;
        }
    }
    
    function getDelayArrival() public constant returns (uint) {
        if(actualArrivalTimestamp > 0 && actualArrivalTimestamp > scheduledArrivalTimestamp) {
            return actualArrivalTimestamp - scheduledArrivalTimestamp;
        }
        else {
            return 0;
        }
    }
    
    function getTotalDelay() public constant returns (uint) {
        return getDelayDeparture() + getDelayArrival();
    }
    
    function isEnded() public constant returns (bool) {
        return actualArrivalTimestamp>0 && actualDepartureTimestamp > 0;
    }
    
}