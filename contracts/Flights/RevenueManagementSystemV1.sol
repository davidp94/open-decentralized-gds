pragma solidity ^0.4.4;


//davidphan.eth
contract RevenueManagementSystemV1 {
    address public analyst;
    
    uint[] public prices;
    
    event Pricing(uint[] _prices);
    
    modifier onlyAnalyst {
        require(msg.sender == analyst);
        _;
    }
    
    function RevenueManagementSystemV1(uint[] _prices) public {
        require(_prices.length > 0);
        prices = _prices;
        analyst = msg.sender;
        Pricing(_prices);
    }
    
    function updatePricingArray(uint[] _prices) public onlyAnalyst {
        require(_prices.length > 0);
        prices = _prices;
        Pricing(_prices);
    }
    
    function getPrices() public constant returns(uint[]) {
        return prices;
    }
    
    function getPrice(uint _remainingSeats) public constant returns(uint) {
        // TODO : depending of the remaining seats count, picks the prices within the array
        return prices [ prices.length / 2];
    }
}