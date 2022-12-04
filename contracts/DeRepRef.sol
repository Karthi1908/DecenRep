// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Checker.sol";
import "./CheckerCountingSimple.sol";
import "./CheckerVotes.sol";
import "./CheckerVotesQuorumFraction.sol";

contract DeRepRef is Checker, CheckerCountingSimple, CheckerVotes, CheckerVotesQuorumFraction {
    constructor(IVotes _token)
        Checker("DeRepRef")
        CheckerVotes(_token)
        CheckerVotesQuorumFraction(4)
    {}

    uint256 public blocknum = block.number;

    
    struct RepScore {
        uint factCount;
        uint fakeCount;
    }
        struct TweetMap {
        string user;
        uint ind;
    }

    event UserRep(
        string indexed user,
        uint256 factCount,
        uint256 fakeCount,
        uint256 indexed tweetid,
        ProposalState status
    );

    mapping( string => RepScore ) public UserReputation;
    mapping( uint => TweetMap ) public UserTweetMap;

    function votingDelay() public pure override returns (uint256) {
        return 1; // 1 block
    }

    function votingPeriod() public pure override returns (uint256) {
        return 300; // 1 day
    }

    function newCheck(uint tweetId,  string memory description,  string memory userId) public {

        if(keccak256(abi.encodePacked(UserTweetMap[tweetId].user)) != keccak256(abi.encodePacked(userId))) {
            propose(tweetId, description);
            UserTweetMap[tweetId] = TweetMap(userId, 0);
        }
        
    }

    function updateRep(uint tweetId) public {

        ProposalState status =  state(tweetId);
        require(
            status == ProposalState.Fact || status == ProposalState.Fake,
            "Governor: Status not available"
        );
        if(UserTweetMap[tweetId].ind == 0) {
            UserTweetMap[tweetId].ind = 1;
            if(status == ProposalState.Fact) {
                UserReputation[UserTweetMap[tweetId].user].factCount +=1;
            } else {
                UserReputation[UserTweetMap[tweetId].user].fakeCount +=1;
            }

        }

        emit UserRep(UserTweetMap[tweetId].user ,
        UserReputation[UserTweetMap[tweetId].user].factCount,
        UserReputation[UserTweetMap[tweetId].user].fakeCount,
        tweetId, 
        status );

    }

    

    // The following functions are overrides required by Solidity.

    function quorum(uint256 blockNumber)
        public
        view
        override(IChecker, CheckerVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }


    
}