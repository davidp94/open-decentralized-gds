pragma solidity ^0.4.4;

import "./RevenueManagementSystemV1.sol";
import "../StableToken/StableToken.sol";
import "../LoyaltyToken/LoyaltyToken.sol";


//davidphan.eth
contract FlightInventory {
    
    address public emitter;
    
    address public revenueManagementSystem;
    RevenueManagementSystemV1 public revenueManagementSystemInstance = RevenueManagementSystemV1(0x0);
    
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
    
    
    event NewSeat(address _emitter, uint _seatIndex);
    event RemoveSeat(address _emitter, uint _seatIndex);
    
    struct FlightSeat {
        uint createdAt;
        uint removedAt;
        address booker;
        bytes32 hashCheckIn;
        bool transferable;
        string seatIdentifier;

        // StableToken Escrow
        uint stableTokenEscrow;
        uint loyaltyTokenEscrow;
    }

    FlightSeat[] public seatsContracts;
    uint remainingSeats = 0;

    
    modifier onlyEmitter {
        require(msg.sender == emitter);
        _;
    }
    
    modifier onlyReporter {
        require(msg.sender == reporter);
        _;
    }
    
    modifier seatNotExists(uint _seatIndex) {
        require(seatsContracts[_seatIndex].createdAt == 0 || seatsContracts[_seatIndex].removedAt > 0);
        _;
    }
    
    modifier seatExists(uint _seatIndex) {
        require(seatsContracts[_seatIndex].createdAt > 0);
        require(seatsContracts[_seatIndex].removedAt > 0);
        _;
    }
    
    modifier seatIndexExists(uint _seatIndex) {
        require(seatsContracts[_seatIndex].createdAt > 0);
        _;
    }
    
    function FlightInventory
    (
        address _revenueManagementSystemAddress,
        string _identifier,
        uint _scheduledDepartureTimestamp,
        uint _scheduledArrivalTimestamp,
        uint _checkInPeriod,
        address _trustedReporter,
        uint _miles,
        address _stableTokenAddress,
        address _loyaltyTokenAddress
    ) 
    public 
    {
        emitter = msg.sender;
        
        identifier = _identifier;
        checkInPeriod = _checkInPeriod;
        scheduledDepartureTimestamp = _scheduledDepartureTimestamp;
        scheduledArrivalTimestamp = _scheduledArrivalTimestamp;
        reporter = _trustedReporter;
        
        bookingLoyaltyToken = _miles;
        
        revenueManagementSystemInstance = RevenueManagementSystemV1(_revenueManagementSystemAddress);

        StableTokenInstance = StableToken(_stableTokenAddress);
        loyaltyTokenInstance = LoyaltyToken(_loyaltyTokenAddress);
    }
    
    function addSeat(string _seatIdentifier, bool _transferable) public onlyEmitter {        
        uint length = seatsContracts.push(FlightSeat({
            createdAt: now,
            removedAt: 0,
            booker: address(0x0),
            hashCheckIn: bytes32(0x0),
            transferable: _transferable,
            seatIdentifier: _seatIdentifier,

            stableTokenEscrow: 0,
            loyaltyTokenEscrow: 0
        }));
        NewSeat(msg.sender, length - 1);
        remainingSeats++;
    }
    
    function removeSeat(uint _seatIndex) public onlyEmitter seatExists(_seatIndex) {
        seatsContracts[_seatIndex].removedAt = now;
        RemoveSeat(msg.sender, _seatIndex);
        remainingSeats--;
    }
    
    function getCheckInBegin() public constant returns (uint) {
        return scheduledDepartureTimestamp - checkInPeriod;
    }
    
    function getPrice() public constant returns (uint) {
        return revenueManagementSystemInstance.getPrice(remainingSeats);
    }

    function book(uint _seatIndex) public seatIndexExists(_seatIndex) {
        require(seatsContracts[_seatIndex].removedAt == 0);
        require(seatsContracts[_seatIndex].booker == address(0x0));

        uint price = this.getPrice();
        // transfer the tokens to the smart contract that will hold token in escrow until end of flight
        require(StableTokenInstance.transferFrom(msg.sender, address(this), price));
        
        // Book it
        seatsContracts[_seatIndex].booker = msg.sender;
        seatsContracts[_seatIndex].stableTokenEscrow = price;

        // TODO: bookingLoyaltyToken in an external smart contract that would do custom rewards based on identity
        seatsContracts[_seatIndex].loyaltyTokenEscrow = bookingLoyaltyToken;
        remainingSeats--;
    }

    function checkIn(uint _seatIndex, bytes32 _dataHash) public seatIndexExists(_seatIndex) {
        require(msg.sender == seatsContracts[_seatIndex].booker);
        seatsContracts[_seatIndex].hashCheckIn = _dataHash;
    }

    function transfer(uint _seatIndex, address _newowner) public seatIndexExists(_seatIndex) {
        require(msg.sender == seatsContracts[_seatIndex].booker);
        require(seatsContracts[_seatIndex].transferable);
        seatsContracts[_seatIndex].booker = _newowner;
    }

    function releaseBookingEscrow(uint _seatIndex) public seatIndexExists(_seatIndex) {
        // example : 
        // if delay > 1 hour, customer refund of 50%
        // if delay > 2 hours, customer refund of 100%
        require(this.isEnded());
        require(msg.sender == seatsContracts[_seatIndex].booker);
        uint _delayArrival = this.getDelayArrival();

        uint stableTokenCount = seatsContracts[_seatIndex].stableTokenEscrow;
        seatsContracts[_seatIndex].stableTokenEscrow = 0;
        if (_delayArrival > 7200) {
            // refund 100%
            require(StableTokenInstance.transfer(msg.sender, stableTokenCount));
        } else if (_delayArrival > 3600) {
            // refund 50%
            uint toEmitterCount = stableTokenCount - stableTokenCount/2;
            require(StableTokenInstance.transfer(msg.sender, stableTokenCount/2));
            require(StableTokenInstance.transfer(emitter, toEmitterCount));
        } else {
            // 100% all to the emitter
            require(StableTokenInstance.transfer(emitter, stableTokenCount));
        }
        // // Send some loyalty tokens from the smart contract to the booker
        uint loyaltyTokensCount = seatsContracts[_seatIndex].loyaltyTokenEscrow;
        seatsContracts[_seatIndex].loyaltyTokenEscrow = 0;
        require(loyaltyTokenInstance.transfer(msg.sender, loyaltyTokensCount));
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

    function transferLoyaltyTokens(address _to, uint256 _value) public onlyEmitter {
        require(loyaltyTokenInstance.transfer(_to, _value));
    }

    function transferStableTokens(address _to, uint256 _value) public onlyEmitter {
        require(StableTokenInstance.transfer(_to, _value));
    }
    
}