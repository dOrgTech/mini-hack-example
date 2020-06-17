pragma solidity ^0.5.11;

interface IVotingMachine {

  //////////////
  /// EVENTS ///
  //////////////

  event ProposalCreated(
    bytes32 indexed _proposalId,
    address indexed _proposalCreator,
    uint256 _numChoices
  );

  event ProposalReverted(
    bytes32 indexed _proposalId
  );

  event ProposalExecuted(
    bytes32 indexed _proposalId,
    uint256[] _winningChoices,
    uint256 _totalCredits
  );

  event VotePlaced(
    bytes32 indexed _proposalId,
    address indexed _voter,
    uint256 _choice,
    uint256 _credits
  );

  event VoteReverted(
    bytes32 indexed _proposalId,
    address indexed _voter
  );

  /////////////////
  /// MODIFIERS ///
  /////////////////

  modifier validProposalCreator(
    address _creator
  )
  {revert(); _;}

  modifier validProposalReverter(
    address _reverter
  )
  {revert(); _;}

  modifier validProposalChoice(
    uint256 _choice
  )
  {revert(); _;}

  modifier validVoterCredits(
    address _voter,
    uint256 _credits
  )
  {revert(); _;}

  modifier validVotableProposal(
    bytes32 _proposalId
  )
  {revert(); _;}

  ////////////////////
  /// TRANSACTIONS ///
  ////////////////////

  /**
    * @dev msg.sender will create a new proposal. Every proposal has a unique ID.
    * @param _numChoices number of choices
    * @return proposalId - The new proposal's id.
    */
  function createProposal(
    uint256 _numChoices
  )
  external
  validProposalCreator(msg.sender)
  returns(
    bytes32 proposalId
  );

  /**
    * @dev msg.sender will revert the proposal.
    * @param _proposalId id of the proposal
    * @return bool proposalReverted - If the proposal has been reverted.
    */
  function revertProposal(
    bytes32 _proposalId
  )
  external
  validProposalReverter(msg.sender)
  returns(
    bool proposalReverted
  );

  /**
    * @dev msg.sender will vote for a proposal choice.
    * @param _proposalId id of the proposal
    * @param _choice a value between 0 to and the proposal's number of choices.
    * @param _credits the amount of credits to vote with. if _amount == 0 it will use all voter credits.
    * @return bool proposalExecuted - If the proposal has been executed.
    */
  function vote(
    bytes32 _proposalId,
    uint256 _choice,
    uint256 _credits
  )
  external
  votable(_proposalId)
  validProposalChoice(_choice)
  validVoterCredits(msg.sender, _credits)
  returns(
    bool proposalExecuted
  );

  /**
    * @dev msg.sender will revert their vote.
    * and delete the voter from the proposal struct
    * @param _proposalId id of the proposal
    */
  function revertVote(
    bytes32 _proposalId,
    uint256 _choice
  )
  external
  votable(_proposalId)
  validProposalChoice(_choice);

  /**
    * @dev execute the proposal (if it's been decided)
    * @param _proposalId the id of the proposal
    * @return bool proposalExecuted - if the proposal has been executed
    */
  function execute(
    bytes32 _proposalId
  )
  external
  votable(_proposalId)
  returns(
    bool proposalExecuted
  );

  ///////////////////////////////
  /// PRE-SIGNED TRANSACTIONS ///
  ///////////////////////////////

  // TODO: define digests here?

  /**
    * @dev Signer will create a new proposal. Every proposal has a unique ID.
    * @param _numChoices number of choices
    * @return proposalId - The new proposal's id.
    */
  function createProposalWithSignature(
    uint256 _numChoices,
    address _signer,
    uint256 _nonce,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  )
  external
  returns(
    bytes32 proposalId
  );

  /**
    * @dev Signer will revert the proposal.
    * @param _proposalId id of the proposal
    * @return bool proposalReverted - If the proposal has been reverted.
    */
  function revertProposalWithSignature(
    bytes32 _proposalId,
    address _signer,
    uint256 _nonce,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  )
  external
  returns(
    bool proposalReverted
  );

  /**
    * @dev Signer will vote for a proposal choice.
    * @param _proposalId id of the proposal
    * @param _choice a value between 0 to and the proposal's number of choices.
    * @param _credits the amount of credits to vote with. if _amount == 0 it will use all voter credits.
    * @return bool proposalExecuted - If the proposal has been executed.
    */
  function voteWithSignature(
    bytes32 _proposalId,
    uint256 _choice,
    uint256 _credits,
    address _signer,
    uint256 _nonce,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  )
  external
  votable(_proposalId)
  validProposalChoice(_choice)
  returns(
    bool proposalExecuted
  );

  /**
    * @dev Signer will revert their vote.
    * and delete the voter from the proposal struct
    * @param _proposalId id of the proposal
    */
  function revertVote(
    bytes32 _proposalId,
    uint256 _choice,
    address _signer,
    uint256 _nonce,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  )
  external
  votable(_proposalId)
  validProposalChoice(_choice);

  /////////////
  /// VIEWS ///
  /////////////

  /**
    * @dev returns the number of choices possible for this proposal,
    *      excluding the abstain choice
    * @param _proposalId the ID of the proposal
    * @return uint256 choices - number of choices
    */
  function numberOfChoices(
    bytes32 _proposalId
  )
  external
  view
  returns(
    uint256 choices
  );

  /**
    * @dev returns if the voting machine allows abstain (choice 0)
    * @return bool allowed - true or false if abstain is allowed
    */
  function abstainAllowed()
  external
  pure
  returns(
    bool allowed
  );

  /**
    * @dev check if the proposal is votable
    * @param _proposalId the ID of the proposal
    * @return bool isVotable - true or false
    */
  function isVotable(
    bytes32 _proposalId
  )
  external
  view
  returns(
    bool isVotable
  );

  /**
    * @dev returns the choice and the amount of voting credits the user committed to the proposal
    * @param _proposalId the ID of the proposal
    * @param _voter the address of the voter
    * @return uint256 choice - the _voter's choice for _proposalId
    *         uint256 credits - amount of voting credits committed by _voter to _proposalId
    */
  function voterCreditsForChoice(
    bytes32 _proposalId,
    address _voter
  )
  external
  view
  returns(
    uint256 choice,
    uint256 credits
  );

  /**
    * @dev returns the credits voted for a specific proposal choice
    * @param _proposalId the ID of the proposal
    * @param _choice the choice index
    * @return uint256 credits - credits voted for the given choice
    */
  function creditsForChoice(
    bytes32 _proposalId,
    uint256 _choice
  )
  external
  view
  returns(
    uint256 credits
  );

  /**
    * @dev returns true if the choices has been finalized,
    *      along with the winning choices
    * @param _proposalId the ID of the proposal
    * @return bool finalized - if the choices are finalized
    *         uint256[] choices - the winning choices
    */
  function choicesFinalized(
    bytes32 _proposalId
  )
  external
  returns(
    bool finalized,
    uint256[] choices
  );
}
