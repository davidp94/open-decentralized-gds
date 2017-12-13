pragma solidity ^0.4.4;

// davidphan.eth
contract HotelDoorLock {
    
    address public admin;
    
    uint256 public rangeBlock;
    uint256 public pricePerBlock; // in wei
    
    event NewBooking(address indexed guest, uint blockStart, uint blockEnd, uint blockCount, string pubkey);
    
    struct Booking {
        uint blockStart;
        uint blockEnd;
        uint blockCount;
        string pubKey;
        address buyer;
    }
    
    mapping(uint256 => Booking) public bookings;
    
    function HotelDoorLock(uint256 _rangeBlock, uint256 _pricePerBlock) public {
        admin = msg.sender;
        rangeBlock = _rangeBlock;
        pricePerBlock = _pricePerBlock;
    }
    
    function book(uint256 blockStart, uint256 blockEnd, string pubKey) public payable {
        require(blockStart % rangeBlock == 0);
        require(blockEnd % rangeBlock == 0);
        require(blockEnd > blockStart + rangeBlock);
        uint blockCount = blockEnd - blockStart;
        require(msg.value >= pricePerBlock * (blockCount));
        if (bookings[blockStart].buyer != 0x0) {
            revert();
        }
        bookings[blockStart] = Booking({
            blockStart: blockStart,
            blockEnd: blockEnd,
            blockCount: blockCount,
            pubKey: pubKey,
            buyer: msg.sender
        });
        for(uint i = blockStart + rangeBlock; i <= blockEnd; i=i+rangeBlock) {
            require(bookings[i].blockStart == 0);
            bookings[i].blockStart = blockStart;
        }
        NewBooking(msg.sender, blockStart, blockEnd, blockCount, pubKey);
    }
    
    function isBooked(uint256 blockStart, uint256 blockEnd) constant public returns (bool) {
        require(blockStart % rangeBlock == 0);
        require(blockEnd % rangeBlock == 0);
        require(blockEnd > blockStart + rangeBlock);
        for(uint i = blockStart; i <= blockEnd; i=i+rangeBlock) {
            if(bookings[i].blockStart != 0){
                return true;
            }
        }
        return false;
    }
    
}
