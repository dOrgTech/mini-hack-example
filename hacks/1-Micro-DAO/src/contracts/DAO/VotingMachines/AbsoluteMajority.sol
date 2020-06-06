pragma solidity ^0.5.11;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/upgrades/contrats/Initializable.sol";
import "../VotingCredits/VotingCredits.sol";
import "./lib/IProposalExecute.sol";
import "./lib/IVotingMachine";
import "./lib/IVotingMachineCallbacks.sol";

contract AbsoluteMajority is IVotingMachine, Initializable {
  using SafeMath for uint;

  struct Parameters {
    uint256 percReq;      // how many percentages required for the proposal to be passed
    address voteOnBehalf; // if this address is set so only this address is allowed
                          // to vote of behalf of someone else.
  }

  struct Vote {
    uint256 choice; // 0 - 'abstain'
    uint256 credits; // amount of voter's credits
  }

  struct Proposal {
    bool open; // voting open flag
    uint256 numOfChoices;
    uint256 totalCredits;
    mapping(uint=>uint) choiceCredits;
    mapping(address=>Vote) votes;
  }

  event AVVoteProposal(bytes32 indexed _proposalId, bool _isProxyVote);

  Parameters public parameters;

  // Mapping from the ID of the proposal to the proposal itself.
  mapping(bytes32=>Proposal) public proposals;

  address public callbacks;
  address public authorizedToPropose;

  uint256 public constant MAX_NUM_OF_CHOICES = 10;

  // Total amount of proposals
  uint256 public proposalsCnt;

  /////////////////
  /// MODIFIERS ///
  /////////////////

  /**
    * @dev Check that the proposal is votable (open and not executed yet)
    */
  modifier votable(
    bytes32 _proposalId
  )
  {
    require(proposals[_proposalId].open, "proposal is not votable");
    _;
  }

  ////////////////////
  /// TRANSACTIONS ///
  ////////////////////

  /**
    * @dev initialize
    * @param _percReq requre percentage for absolure majority
    * @param _voteOnBehalf enable vote on behalf
    * @param _callbacks should fulfill voting callbacks interface.
    * @param _authorizedToPropose only this address allow to propose (unless it is zero)
    */
  function initialize(
    uint256 _percReq,
    address _voteOnBehalf,
    address _callbacks,
    address _authorizedToPropose
  )
  external
  initializer
  {
    require(_percReq <= 100 && _percReq > 0, "wrong percReq");
    parameters = Parameters({
      percReq: _percReq,
      voteOnBehalf: _voteOnBehalf
    });
    callbacks = _callbacks;
    authorizedToPropose = _authorizedToPropose;
  }

  function createProposal(
    uint256 _numChoices,
    address,
  )
    external
    returns(bytes32)
  {
    require(
      (authorizedToPropose == address(0)) || (msg.sender == authorizedToPropose),
      "msg.sender not authorized to propose"
    );

    // Check valid params and number of choices:
    require(
      parameters.percReq > 0,
      "no initialized been called"
    );
    require(
      _numChoices > 0 && _numChoices <= MAX_NUM_OF_CHOICES,
      "numOfChoices out of range"
    );

    // Generate a unique ID:
    bytes32 proposalId = keccak256(abi.encodePacked(this, proposalsCnt));
    proposalsCnt = proposalsCnt.add(1);
    // Open proposal:
    Proposal memory proposal;
    proposal.numOfChoices = _numChoices;
    proposal.open = true;
    proposals[proposalId] = proposal;
    emit ProposalCreated(proposalId, msg.sender, _numChoices);
    return proposalId;
  }

  function vote(
    bytes32 _proposalId,
    uint256 _choice,
    uint256 _credits,
    address _voter
  )
  external
  votable(_proposalId)
  returns(bool)
  {
    Parameters memory params = parameters;
    address voter;
    if (params.voteOnBehalf != address(0)) {
      require(msg.sender == parameters.voteOnBehalf, "msg.sender is not authorized to vote");
      voter = _voter;
    } else {
      voter = msg.sender;
    }
    return internalVote(_proposalId, voter, _choice, _credits);
  }

  function cancelVote(
    bytes32 _proposalId
  )
  external
  votable(_proposalId)
  {
    cancelVoteInternal(_proposalId, msg.sender);
  }

  /**
    * @dev execute check if the proposal has been decided, and if so, execute the proposal
    * @param _proposalId the id of the proposal
    * @return bool true - the proposal has been executed
    *              false - otherwise.
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

  /////////////
  /// VIEWS ///
  /////////////

  function numberOfChoices(
    bytes32 _proposalId
  )
  external
  view
  returns(
    uint256 choices
  )
  {
    return proposals[_proposalId].numOfChoices;
  }

  function abstainAllowed()
  external
  pure
  returns(
    bool allowed
  )
  {
    return true;
  }

  function isVotable(
    bytes32 _proposalId
  )
  external
  view
  returns(
    bool isVotable
  )
  {
    return proposals[_proposalId].open;
  }

  function voterCreditsForChoice(
    bytes32 _proposalId,
    address _voter
  )
  external
  view
  returns(
    uint256 choice,
    uint256 credits
  )
  {
    Vote memory vote = proposals[_proposalId].votes[_voter];
    return (vote.choice, vote.credits);
  }

  function creditsForChoice(
    bytes32 _proposalId,
    uint256 _choice
  )
  external
  view
  returns(
    uint256 credits
  )
  {
    return proposals[_proposalId].choiceCredits[_choice];
  }

  /**
    * @dev getAllowedRangeOfChoices returns the allowed range of choices for a voting machine.
    * @return min - minimum number of choices
              max - maximum number of choices
    */
  function getAllowedRangeOfChoices()
  external
  pure
  returns(uint256 min, uint256 max)
  {
    return (0, MAX_NUM_OF_CHOICES);
  }

  /////////////////
  /// INTERNALS ///
  /////////////////

  function cancelVoteInternal(
    bytes32 _proposalId,
    address _voter
  )
  internal
  {
    Proposal storage proposal = proposals[_proposalId];
    Vote memory vote = proposal.votes[_voter];
    proposal.choiceCredits[vote.choice] =
      (proposal.choiceCredits[vote.choice]).sub(vote.credits);
    proposal.totalCredits = (proposal.totalCredits).sub(voter.reputation);
    delete proposal.voters[_voter];
    emit VoteReverted(_proposalId, _voter);
  }

  function deleteProposal(
    bytes32 _proposalId
  )
  internal
  {
    Proposal storage proposal = proposals[_proposalId];
    for (uint256 cnt = 0; cnt <= proposal.numOfChoices; cnt++) {
      delete proposal.votes[cnt];
    }
    delete proposals[_proposalId];
  }

  /**
    * @dev execute check if the proposal has been decided, and if so, execute the proposal
    * @param _proposalId the id of the proposal
    * @return bool true - the proposal has been executed
    *              false - otherwise.
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

    // Check if someone crossed the bar:
    for (uint256 cnt = 0; cnt <= proposal.numOfChoices; cnt++) {
      if (proposal.votes[cnt] > (totalReputation/100)*percReq) {
        deleteProposal(_proposalId);
        emit ProposalExecuted(_proposalId, cnt, totalReputation);
        return ProposalExecuteInterface(callbacks).executeProposal(_proposalId, int(cnt));
      }
    }

    return false;
  }

  /**
    * @dev Vote for a proposal, if the voter already voted, cancel the last vote and set a new one instead
    * @param _proposalId id of the proposal
    * @param _voter used in case the vote is cast for someone else
    * @param _vote a value between 0 to and the proposal's number of choices.
    * @return true in case of proposal execution otherwise false
    * throws if proposal is not open or if it has been executed
    * NB: executes the proposal if a decision has been reached
    */
  function internalVote(
    bytes32 _proposalId,
    address _voter,
    uint256 _vote,
    uint256 _rep
  )
  internal
  returns(bool)
  {
    Proposal storage proposal = proposals[_proposalId];

    // Check valid vote:
    require(_vote <= proposal.numOfChoices, "vote is out of range");

    // Check voter has enough reputation:
    uint256 reputation = IVotingMachineCallbacks(callbacks).reputationOf(_voter, _proposalId);
    require(reputation > 0, "_voter must have reputation");
    require(reputation >= _rep, "cannot vote with more reputation voter has");
    uint256 rep = _rep;
    if (rep == 0) {
      rep = reputation;
    }

    // If this voter has already voted, first cancel the vote:
    if (proposal.voters[_voter].reputation != 0) {
      cancelVoteInternal(_proposalId, _voter);
    }

    // The voting itself:
    proposal.votes[_vote] = rep.add(proposal.votes[_vote]);
    proposal.totalCredits = rep.add(proposal.totalCredits);
    proposal.voters[_voter] = Voter({
      reputation: rep,
      vote: _vote
    });

    // Event:
    emit VotePlaced(_proposalId, _voter, _vote, rep);
    emit AVVoteProposal(_proposalId, (_voter != msg.sender));

    // execute the proposal if this vote was decisive:
    return _execute(_proposalId);
  }
}
