// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract RovPrediction2024 is Ownable, AccessControl {
    using SafeERC20 for IERC20;

    IERC20 public token;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

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
 
    string constant Top1 = "Top1";
    string constant Top3 = "Top3";
    //prediction
    mapping(address => Prediction[]) public userPredictions;
    event UserPrediction(
        address userAddress, 
        uint32 teamId, 
        uint256 tokens,
        string predictionType,
        uint256 timeStamp
        );

    //set top 3
    // rank 1 => teamId
    // rank 2 => teamId
    // rank 3 => teamId
    mapping(uint32 => uint32) public winner;
    event SetTop3(uint32 rank, uint32 teamId);

    //for check reward
    struct Winner {
        uint256 Top1;
        uint256 Top2;
        uint256 Top3;
    }
    // Winner public  top3;
    struct RewardInfo {
        uint256 Champion;
        Winner top3;
    }
    struct UserCliamDetail {
        uint32  teamId;
        string  predictionType;
        bool    isClaimed;
        uint256 timeStamp;
    }

    //for claim reward
    mapping(address userAddress => UserCliamDetail[] userClaimDetails) public  userClaimDetails;
    event Claim(address _userAddress, string _predectionType, uint32 _teamId, bool isClaimed);
  

    uint32[] public teamIDList;
    event SetTeamList(uint32[] teamList);

  
    //correct total top1 spending
    mapping(uint32 => uint256) public totalTop1SpendingAmount ;
    //correct total top3 spending
    mapping(uint32 => uint256) public totalTop3SpendingAmount ;

    //for top spender
    struct UserPredictionHistory {
        address userAddress;
        uint32 teamId;
        uint256 tokens;
        string predictionType;
        uint256 timeStamp;
    }
    UserPredictionHistory[] public  userPredictionHistory ;
    struct TopSpender {
        address userAddress;
        uint256 totalToken;
        uint256 timeStamp;
    }
    TopSpender[] public topSpenders;

    //For team history
    struct TeamVoteSummary {
        uint256 total;
        uint256 champion;
        uint256 top3;
        uint256 timeStamp;
    }
    mapping(uint32 teamId => TeamVoteSummary summary) teamVoteSummary;

    constructor(address _initialOwner,address _token) Ownable(_initialOwner) {
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // Set contract deployer as admin
        token = IERC20(_token); // Set token address for usage in contract
    }

    function initGame(
        uint256 _initPrizePool, 
        uint256 _lastDate, 
        uint32[] memory _teamList
    ) external  onlyRole(ADMIN_ROLE)  {
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
        winner[_rank] = _teamId;
        emit SetTop3(_rank, _teamId);
    }

    function getLastDate() external view returns (uint256) {
        return lastDate;
    }

    function getTotalPrizePool() external view returns(uint256){
        return prizePool;
    }
     
    function predict(uint32 _teamId, uint256 _tokens, string memory _predictionType) external {
        require(block.timestamp <= lastDate, "Prediction time is expired");
        require(_tokens >= 100, "Token amount should be at least 100");
        // Ensure the token contract is set
        require(address(token) != address(0), "Token contract is not set");

         // Check if the user has enough tokens
        require(token.balanceOf(msg.sender) >= _tokens, "Insufficient balance");
        
        //add token to prize pool
        prizePool += _tokens;
        emit AddPrizePool(msg.sender, _tokens); //use to update prize pool

        string  memory predictionType ;
        //add total spending for using in calcuting reward
        if (keccak256(bytes(_predictionType)) == keccak256(bytes(Top1))) {
            totalTop1SpendingAmount[1] += _tokens;
            //add data to team vote summary
            teamVoteSummary[_teamId].total += _tokens;
            teamVoteSummary[_teamId].champion += _tokens;
            teamVoteSummary[_teamId].timeStamp = block.timestamp;
        }
         if(keccak256(bytes(_predictionType)) == keccak256(bytes(Top3)))  {
            totalTop3SpendingAmount[3] += _tokens;
              //add data to team vote summary
            teamVoteSummary[_teamId].total += _tokens;
            teamVoteSummary[_teamId].top3 += _tokens;
            teamVoteSummary[_teamId].timeStamp = block.timestamp;
        }
   
        //add token to state variable
        userPredictions[msg.sender].push(Prediction(_teamId, _tokens, _predictionType, block.timestamp));
        //tranfer token from user to token contract
        token.safeTransferFrom(msg.sender, address(token),_tokens);
        userPredictionHistory.push(UserPredictionHistory(msg.sender, _teamId, _tokens,predictionType,block.timestamp)); // record for top spender
    
       
        emit UserPrediction(msg.sender, _teamId, _tokens,predictionType,block.timestamp); //use to insert record in rov_2024_prediction_history table
    }

    function checkReward(address useAddress)  public  view returns (RewardInfo memory) {
        uint256 rewardTop1 ;
        uint256 rewardTop2 ;
        uint256 rewardTop3 ;
   
        for (uint256 i = 0 ; i<userPredictions[useAddress].length;i++){
            //check for champion
            if (userPredictions[useAddress][i].teamId == winner[1]) {
                //call calcualte fuction
                uint256 reward = _calculateRewardTop1(useAddress);
                rewardTop1 += reward;
            }
            if  (userPredictions[useAddress][i].teamId == winner[2]) {
                uint256 reward = _calculateRewardTop3(useAddress);
                rewardTop3 += reward;
            }
             if  (userPredictions[useAddress][i].teamId == winner[3]) {
                 uint256 reward = _calculateRewardTop3(useAddress);
                rewardTop3 += reward;
            }
        }
        uint256 championReward = rewardTop1;
        Winner memory top3Rewards = Winner({
            Top1: rewardTop1,
            Top2: rewardTop2,
            Top3: rewardTop3
        });

    return RewardInfo({
        Champion: championReward,
        top3: top3Rewards
    });
    }

function _calculateRewardTop1(address _userAddress) internal  view returns(uint256 reward) {
        //sum all top 1
        uint256 sumTop1 ;
        for (uint256 i = 0 ; i<userPredictions[_userAddress].length; i++){
           if (keccak256(bytes(userPredictions[_userAddress][i].typeReward)) == keccak256(bytes(Top1))) {
            sumTop1 += userPredictions[_userAddress][i].tokens;
            }
        }
         reward = (prizePool * 75 * sumTop1) / totalTop1SpendingAmount[1];
         return reward;
    }

      function _calculateRewardTop3(address _userAddress) internal  view returns(uint256 reward) {
   
        uint256 _sumTop3 ;
        for (uint256 i = 0 ; i<userPredictions[_userAddress].length; i++){
           if (keccak256(bytes(userPredictions[_userAddress][i].typeReward)) == keccak256(bytes(Top3))) {
            _sumTop3 += userPredictions[_userAddress][i].tokens;
            }
        }
         reward = (prizePool * 25 * _sumTop3) / totalTop3SpendingAmount[3];
         return reward;
    }


function ClaimReward(address _userAddress,uint32 _teamId)  public {

    //check if user had claim reward
    for(uint256 i=0;i<userClaimDetails[_userAddress].length;i++){
        //check Top1 is claimed
        if (userClaimDetails[_userAddress][i].teamId == _teamId &&keccak256(bytes(userClaimDetails[_userAddress][i].predictionType)) == keccak256(bytes(Top1)) && userClaimDetails[_userAddress][i].isClaimed){
               revert("Champion Reward already claimed");
        }
          if (userClaimDetails[_userAddress][i].teamId == _teamId &&keccak256(bytes(userClaimDetails[_userAddress][i].predictionType)) == keccak256(bytes(Top3)) && userClaimDetails[_userAddress][i].isClaimed){
               revert("Top3 Reward already claimed");
        }

    }

    RewardInfo memory userReward = checkReward(_userAddress);
        if (userReward.Champion > 0 && winner[1] == _teamId) {
            token.safeTransfer(_userAddress, userReward.Champion);
            //set to claimed
            userClaimDetails[_userAddress].push(UserCliamDetail(winner[1],Top1,true,block.timestamp));
            emit Claim(_userAddress,Top1,winner[1],true); // use to trigger disable claim button
            }
        if (userReward.top3.Top2 > 0 && winner[2] == _teamId) {
            token.safeTransfer(_userAddress, userReward.top3.Top2 );
            //set to claimed
            userClaimDetails[_userAddress].push(UserCliamDetail(winner[2],Top3,true,block.timestamp));
            emit Claim(_userAddress,Top1,winner[2],true); // use to trigger disable claim button
            }
        if (userReward.top3.Top3 > 0 && winner[3] == _teamId) {
            token.safeTransfer(_userAddress, userReward.top3.Top3 );
            //set to claimed
            userClaimDetails[_userAddress].push(UserCliamDetail(winner[3],Top3,true,block.timestamp));
            emit Claim(_userAddress,Top1,winner[3],true); // use to trigger disable claim button
            }
        }

  
  function getAllSpender() external  returns(TopSpender[] memory) {


        for (uint256 i=0;i<userPredictionHistory.length;i++){
            uint256 totalToken ;
            if (keccak256(bytes(userPredictionHistory[i].predictionType)) == keccak256(bytes(Top1))){
                totalToken += userPredictionHistory[i].tokens;
            }   
             if (keccak256(bytes(userPredictionHistory[i].predictionType)) == keccak256(bytes(Top3))){
                totalToken += userPredictionHistory[i].tokens;
            }      
            // topSpenders.push(TopSpender,totalToken,block.timestamp);
            topSpenders.push(TopSpender(userPredictionHistory[i].userAddress,totalToken,block.timestamp));
        }
        return topSpenders;
  }

function getAllTeamPredictionPool() internal  view returns (mapping(uint32 => TeamVoteSummary) storage) {
    return teamVoteSummary;
}
}