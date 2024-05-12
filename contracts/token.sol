// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract CatToken is ERC20 {
//   address public owner ;
//   event ConstructorSet (address _owner, uint256 _token);

//    constructor (uint256 initSupply) ERC20("CatToken","CTT") {
//     owner = msg.sender ;
//     _mint(owner,initSupply);
//     emit ConstructorSet(owner,initSupply);
//    }

//    function getBalance(address _account)  view public returns (uint256) {
//     return CatToken.getBalance(_account);
//    }
// }
contract HelloWorld {
    string public message;

    function  setMessage(string memory _message) public {
        message = _message;
    }

    // function getMessage() view public returns (calldata string) {
    //     return message;
    // }
}