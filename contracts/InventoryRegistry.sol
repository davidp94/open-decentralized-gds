pragma solidity ^0.4.4;



contract InventoryRegistry {
    
    mapping(address => bool) public isAuthorized; // address of Inventory smart contracts
    
    address public admin; // smart contract address of the consensus to add/remove inventory
    
    
    function InventoryRegistry() public {
        admin = msg.sender;
    }
    
    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
    
    
    function addInventory(address _inventoryAddress) public onlyAdmin returns (bool) {
        //TODO: check if the smart contract exists and is of type Inventory
        if(isAuthorized[_inventoryAddress]) {
            return false;
        }
        isAuthorized[_inventoryAddress] = true;
        return true;
    }
    
    function removeInventory(address _inventoryAddress) public onlyAdmin returns (bool) {
        if(!isAuthorized[_inventoryAddress]) {
            return false;
        }
        isAuthorized[_inventoryAddress] = false;
        return true;
    }
    
    
}
