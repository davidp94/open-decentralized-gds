pragma solidity ^0.4.18;

import '../zeppelin-utils/token/StandardToken.sol';

contract IsMemberTest {
    address public tokenAddress;

    function IsMemberTest(address _tokenAddress) public {
        tokenAddress = _tokenAddress;
    }

    function isMember(address _who) public constant returns (bool) {
        return StandardToken(tokenAddress).balanceOf(_who) > 0;
    }

}