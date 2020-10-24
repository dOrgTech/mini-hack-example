pragma solidity ^0.5.11;

interface IProposalExecutor {
  function executeProposal(
    bytes32 _proposalId
  )
  external
  returns(
    bool proposalExecuted
  );
}
