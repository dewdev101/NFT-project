
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Rov {

    uint256 private startTime_;
    uint256 private lastVoteDate_;
    uint256 public  prizePool;
    uint256 private initPrizePool = 50000;

    event AddPrizePool(address user,uint256 token);

    //ID represent team id
    mapping (uint32 => string) public  teamList;

  struct VoteThisTeamHistory {
        uint256 teamVoteId;
        uint256 voteTime;
        uint256 token; //user bet each time 
    }
    mapping (uint32 => VoteThisTeamHistory[]) public  voteThisTeamHistory;

    event VoteDone(uint32 teamVoteId,uint256 voteTime, uint256 token);

    // otalToken ; //total token each team 
    mapping(uint32=> uint256) public totalToken;

    struct VoteDetail {
        uint256 teamVoteId;
        uint256 voteTime;
        uint256 token;
    }
    mapping( address =>  VoteDetail[]) public  voteData ;
  
    constructor() {
        prizePool = initPrizePool;
        //team list
        teamList[1] = "5 senior";
        teamList[2] = "Innocent";
        teamList[3] = "BaconTime";
        teamList[4] = "Talon";
        teamList[5] = "Full sense";
        lastVoteDate_ = 1716111314;
    }


    // function setLastVoteDate(uint256 _lastDateVote) external  {
    //     lastVoteDate_ = _lastDateVote;
    // }

    function vote(uint32 _teamVoteId,address user,uint256 _token) public    {
        require(_teamVoteId>1 && _teamVoteId <= 5,"team not found");
        require(user != address(0),"invalid address");
        require(_token >= 100,"minimum is 100 token");
        require(block.timestamp <= lastVoteDate_,"vote time is expired");
  
        //add token to prize pool
        prizePool += _token;
        emit AddPrizePool(user,_token);

        //add data for team voted detail
        voteThisTeamHistory[_teamVoteId].push(VoteThisTeamHistory(_teamVoteId,block.timestamp, _token));
        totalToken[_teamVoteId] += _token;
     

        //add data for user info
        voteData[user].push(VoteDetail(_teamVoteId,block.timestamp, _token));   
        emit  VoteDone(_teamVoteId,block.timestamp,_token);
    }

     function seeUserVote(address user) view public returns (VoteDetail[] memory) {
        return voteData[user];
    }
    //address
    //token
    //total

    function seeVoteForTeam(uint32 _teamId) view public  returns (VoteThisTeamHistory[] memory){
        return voteThisTeamHistory[_teamId];
    }

    //sum all token bet for all team
    //select top 1 and top 3
    //calculate prize for user
  
}