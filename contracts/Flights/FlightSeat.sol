pragma solidity ^0.4.4;

import "./FlightInventory.sol";

//davidphan.eth
contract FlightSeat {
    
    address public emitter;
    
    address public flightInventory;
    
    FlightInventory public flightInventoryInstance = FlightInventory(0x0);
    
    uint public seatNumber;
    bool public transferable;

    address public booker;
    
    bytes32 public hashCheckIn;
    
    event Booked(address _booker);
    event BookingTransfered(address _newBooker);

    mapping(address => bool) public seats;
    
    
    modifier onlyEmitter {
        require(msg.sender == emitter);
        _;
    }
    
    modifier onlyFlightInventory {
        require(msg.sender == flightInventory);
        _;
    }
    
    modifier notBooked {
        require(booker == 0x0);
        _;
    }
    
    modifier isTransferable {
        require(now < flightInventoryInstance.getCheckInBegin() && transferable);
        _;
    }
    
    modifier checkInTime {
        require(now > flightInventoryInstance.getCheckInBegin());
        _;
    }
    
    modifier onlyBooker {
        require(msg.sender == booker);
        _;
    }
    
    function FlightSeat(address _flightInventory, uint _seatNumber, bool _transferable) public {
        emitter = msg.sender;
        
        flightInventoryInstance = FlightInventory(_flightInventory);
        seatNumber = _seatNumber;
        transferable = _transferable;
    }
    
    function book(address _booker) public onlyFlightInventory notBooked returns(bool) {
        booker = _booker;
        Booked(_booker);
        return true;
    }
    
    function getBooker() public constant returns (address) {
        return booker;
    }
    
    function isBookable() public constant returns (bool) {
        return booker == 0x0;
    }
    
    function checkIn(bytes32 _dataHash) public onlyBooker {
        hashCheckIn = _dataHash;
    }
    
    function transfer(address _newowner) public onlyBooker isTransferable {
        booker = _newowner;
        BookingTransfered(_newowner);
    }
    
    function getFlightInventory() public constant returns (address) {
        return flightInventory;
    }
    
}
