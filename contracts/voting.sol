
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract Voting {

    uint256 private startTime_;
    uint256 private lastVoteDate_;
    //address , time , votePoint
    //team select
    struct VoteDetail {
        uint256 voteTime;
        uint256 votePoint;
    }
    mapping( address => VoteDetail)[] voteData ;

    function setLastVoteDate(uint256 _lastDateVote) external  {
        lastVoteDate_ = _lastDateVote;
    }

    function vote(address user,uint256 _votePoint) public    {
        require(block.timestamp <= lastVoteDate_,"vote time is expired");
        voteData.push();
        voteData[voteData.length - 1][user] = VoteDetail(block.timestamp, _votePoint);
        
    }

    function seeUserVote(address _userAddress) view public returns (uint256 voteTime,uint256 votePoint) {
        for (uint256 i = 0; i <voteData.length; i ++) {
            if (voteData[i][_userAddress].voteTime != 0) {
                return (voteData[i][_userAddress].voteTime , voteData[i][_userAddress].votePoint );
            }
        }
    }
}