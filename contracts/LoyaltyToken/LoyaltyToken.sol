pragma solidity ^0.4.18;


import "../zeppelin-utils/token/StandardToken.sol";


/**
 * @title LoyaltyToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract LoyaltyToken is StandardToken {

  string public constant name = "LoyaltyToken";
  string public constant symbol = "LTK";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function LoyaltyToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}