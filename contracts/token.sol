// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";

contract RovPrediction2024 is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token;

    // bytes32 public constant ADMIN_ROLE = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775; // keccak256("ADMIN_ROLE")


    uint256 public prizePool;
    event InitPrizePool(uint256 prizePool);
    event AddPrizePool(address userAddress, uint256 token);

    uint256 public lastDate;
    event SetLastDate(uint256 lastDate);

    struct Prediction {
        uint32 teamId;
        uint256 tokens;
        string typeReward;
        uint256 timeStamp;
    }

    mapping(address => Prediction[]) public userPredictions;
    event UserPrediction(address userAddress, uint32 teamId, uint256 tokens);

    mapping(uint32 => uint32) public top3;
    event SetTop3(uint32 rank, uint32 teamId);

    uint32[] public teamIDList;
    event SetTeamList(uint32[] teamList);



    constructor()  {
        // _setRoleAdmin(DEFAULT_ADMIN_ROLE, msg.sender);
        token = IERC20(_token);
    }

    function initiateGame(
        uint256 _initPrizePool, 
        uint256 _lastDate, 
        uint32[] memory _teamList
    ) onlyOwner internal{
        prizePool = _initPrizePool;
        emit InitPrizePool(_initPrizePool);

        lastDate = _lastDate;
        emit SetLastDate(_lastDate);

        for (uint32 i = 0; i < _teamList.length; i++) {
            teamIDList.push(_teamList[i]);
        }
        emit SetTeamList(_teamList);
    }

    function setTop3(uint32 _rank, uint32 _teamId) internal {
        top3[_rank] = _teamId;
        emit SetTop3(_rank, _teamId);
    }

    function getLastDate() external view returns (uint256) {
        return lastDate;
    }

    function getTotalPrizePool() external view returns(uint256){
        return prizePool;
    }
     
    function predict(uint32 _teamId, uint256 _tokens, string memory _typeReward) external {
        require(block.timestamp <= lastDate, "Prediction time is expired");
        require(_tokens >= 100, "Token amount should be at least 100");
        
        prizePool += _tokens;
        emit AddPrizePool(msg.sender, _tokens);

        userPredictions[msg.sender].push(Prediction(_teamId, _tokens, _typeReward, block.timestamp));
        emit UserPrediction(msg.sender, _teamId, _tokens);
    }

    function claimTop1() external onlyOwner {
        // Functionality to distribute rewards to the top 1 team
        // Needs implementation
    }

    function claimTop3() external onlyOwner {
        // Functionality to distribute rewards to the top 3 teams
        // Needs implementation
    }

    function checkReward(address _userAddress) external view returns (uint256) {
        // Functionality to check the reward for a user
        // Needs implementation
        return 0;
    }

    function getAllTeamPredictionPool(uint32 _teamId) external view returns (uint256) {
        // Functionality to get the total prediction pool for a team
        // Needs implementation
        return 0;
    }
}
