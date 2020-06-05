pragma solidity ^0.5.11;

// TODO: future goals for interface versions
interface IVoteCreator {
  // TODO: future goals about this right here
  // IVotingCredits votingCredits @ hash("mini-dao/voting-credits-v1")

  IVotingCredits votingCredits;

  function executeVote(bytes32 _voteId, int _decision) external returns(bool);
}
