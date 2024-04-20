// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string tokenName = "Moon token";
    string symbol = "DMT";
    uint totalSupply = 100000;
    address public owner;
    mapping(address=>uint256) balances ;

    constructor () {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount,"not enough token");
        balances[msg.sender]-=amount;
        balances[to]+=amount;
    }

    function balancOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
//TODO: Deploy this contract and test
//then study rmrk smart contract fot slot part