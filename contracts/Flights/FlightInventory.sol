pragma solidity ^0.4.4;

import "./RevenueManagementSystem.sol";
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
    
    
    event NewSeat(address _emitter, uint _seatNumber);
    event RemoveSeat(address _emitter, uint _seatNumber);
    
    struct FlightSeat {
        uint createdAt;
        uint removedAt;
        address booker;
        bytes32 hashCheckIn;
        bool transferable;
        uint seatNumber;

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
    
    function addSeatContract(uint _seatNumber, bool _transferable) public onlyEmitter {        
        uint index = seatsContracts.push(FlightSeat({
            createdAt: now,
            removedAt: 0,
            booker: address(0x0),
            hashCheckIn: bytes32(0x0),
            transferable: _transferable,
            seatNumber: _seatNumber,

            stableTokenEscrow: 0,
            loyaltyTokenEscrow: 0
        }));
        NewSeat(msg.sender, index);
        remainingSeats++;
    }
    
    function removeSeatContract(uint _seatIndex) public onlyEmitter seatExists(_seatIndex) {
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
            require(StableTokenInstance.transferFrom(address(this), msg.sender, stableTokenCount));
        } else if (_delayArrival > 3600) {
            // refund 50%
            uint toEmitterCount = stableTokenCount - stableTokenCount/2;
            require(StableTokenInstance.transferFrom(address(this), msg.sender, stableTokenCount/2));
            require(StableTokenInstance.transferFrom(address(this), emitter, toEmitterCount));
        } else {
            // 100% all to the emitter
            require(StableTokenInstance.transferFrom(address(this), emitter, stableTokenCount));
        }
        // Send some loyalty tokens from the smart contract to the booker
        uint loyaltyTokensCount = seatsContracts[_seatIndex].loyaltyTokenEscrow;
        seatsContracts[_seatIndex].loyaltyTokenEscrow = 0;
        require(loyaltyTokenInstance.transferFrom(address(this), msg.sender, loyaltyTokensCount));
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