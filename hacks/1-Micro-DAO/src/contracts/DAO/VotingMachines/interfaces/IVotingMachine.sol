pragma solidity ^0.5.11;

interface IVotingMachine {

// TODO: vote -> choice, proposal -> vote, events are actions

/// modifiers

  //When implementing this interface please do not only override function and modifier,
  //but also to keep the modifiers on the overridden functions.
  modifier onlyProposalOwner(
    bytes32 _proposalId
  ) {revert(); _;}

  modifier votable(
    bytes32 _proposalId
  ) {revert(); _;}

/// events

  event (
    bytes32 indexed _proposalId,
    address indexed _organization,
    uint256 _numOfChoices,
    address _proposer
  );

  event (
    bytes32 indexed _proposalId,
    address indexed _organization,
    uint256 _winningChoice,
    uint256 _totalReputation
  );

  event VoteMade(
    bytes32 indexed _proposalId,
    address indexed _organization,
    address indexed _voter,
    uint256 _choice,
    uint256 _reputation
  );

  event CancelProposal(
    bytes32 indexed _proposalId,
    address indexed _organization
  );

  event CancelVoting(
    bytes32 indexed _proposalId,
    address indexed _organization,
    address indexed _voter
  );

/// transactions

  function propose(
    uint256 _numOfChoices,
    address _proposer
  )
  external
  returns(bytes32);

  function vote(
    bytes32 _proposalId,
    uint256 _vote,
    uint256 _rep,
    address _voter
  )
  external
  votable(_proposalId)
  returns(bool);

  function cancelVote(
    bytes32 _proposalId
  )
  votable(_proposalId)
  external;

/// views

  function getNumberOfChoices(
    bytes32 _proposalId
  )
  external
  view
  returns(uint256);

  function isVotable(
    bytes32 _proposalId
  )
  external
  view
  returns(bool);

  function voteStatus(
    bytes32 _proposalId,
    uint256 _choice
  )
  external
  view
  returns(uint256);

  function abstainAllowed()
  external
  pure
  returns(bool allowed, uint256 abstainChoice);

  function choicesAvailable()
  external
  pure
  returns(uint256 min, uint256 max);
}
