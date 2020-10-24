pragma solidity ^0.5.17;

import "./AbsoluteMajority.sol";

contract MinimumQuorum is AbsoluteMajority {
  /**
  * @dev check if the proposal has been decided, and if so, execute the proposal
  * @param _proposalId the id of the proposal
  */
  function execute(
    bytes32 _proposalId
  )
  external
  votable(_proposalId)
  returns(bool)
  {
    return _execute(_proposalId);
  }

  /**
  * @dev check if the proposal has been decided, and if so, execute the proposal
  * @param _proposalId the id of the proposal
  */
  function _execute(
    bytes32 _proposalId
  )
  internal
  votable(_proposalId)
  returns(bool)
  {
    Proposal storage proposal = proposals[_proposalId];
    uint256 totalReputation =
    IVotingMachineCallbacks(callbacks).getTotalSupply(_proposalId);
    uint256 percReq = parameters.percReq;

    // this is the actual voting rule:
    if (proposal.totalVotes > (totalReputation/100)*percReq) {
      uint256 max;
      uint256 maxInd;
      for (uint256 cnt = 0; cnt <= proposal.numOfChoices; cnt++) {
        if (proposal.votes[cnt] > max) {
          max = proposal.votes[cnt];
          maxInd = cnt;
        }
      }

      deleteProposal(_proposalId);
      emit ExecuteProposal(_proposalId, organization, maxInd, totalReputation);
      ProposalExecuteInterface(callbacks).executeProposal(_proposalId, int(maxInd));
      return true;
    }

    return false;
  }
}
