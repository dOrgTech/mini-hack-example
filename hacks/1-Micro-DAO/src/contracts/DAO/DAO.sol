pragma solidity ^0.6.8;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./VotingMachine/lib/IVotingMachine.sol";
import "./VotingMachine/lib/IProposalExecute.sol";
import "./VotingCredits.sol";

// TODO: voting machine callbacks, modules are DAO agnostic (GnosisSafe, custom, etc)
contract DAO is Initializable, IProposalExecute {

  event NewCallProposal(
    address[] _to,
    bytes32 indexed _proposalId,
    bytes[]   _callData,
    uint256[] _value,
    string  _descriptionHash
  );

  event ProposalExecuted(
    bytes32 indexed _proposalId,
    bytes[] _genericCallReturnValue
  );

  event ProposalExecutedByVotingMachine(
    bytes32 indexed _proposalId,
    int256 _param
  );

  event ProposalDeleted(bytes32 indexed _proposalId);

  struct CallProposal {
    address[] to;
    bytes[] callData;
    uint256[] value;
    bool exist;
    bool passed;
  }

  mapping(bytes32=>CallProposal) public proposals;

  IVotingMachine public votingMachine;
  VotingCredits public votingCredits;

  function initialize(
    IVotingMachine _votingMachine,
    VotingCredits _votingCredits
  )
  external
  initializer
  {
    votingMachine = _votingMachine
    votingCredits = _votingCredits
  }

  function executeProposal(
    bytes32 _proposalId,
    int256 _decision
  )
  external
  onlyVotingMachine(_proposalId)
  returns(bool)
  {
    CallProposal storage proposal = proposals[_proposalId];
    require(proposal.exist, "must be a live proposal");
    require(proposal.passed == false, "cannot execute twice");

    if (_decision == 1) {
      proposal.passed = true;
      execute(_proposalId);
    } else {
      delete organizationProposals[_proposalId];
      emit ProposalDeleted(_proposalId);
    }

    emit ProposalExecutedByVotingMachine(_proposalId, _decision);
    return true;
  }

  function execute(
    bytes32 _proposalId
  )
  external
  {
    CallProposal storage proposal = organizationProposals[_proposalId];

    require(proposal.exist, "must be a live proposal");
    require(proposal.passed, "proposal must passed by voting machine");
    proposal.exist = false;

    bytes[] memory genericCallReturnValues = new bytes[](proposal.to.length);
    bytes memory genericCallReturnValue;
    bool success;

    for(uint i = 0; i < proposal.to.length; i ++) {
      (success, genericCallReturnValue) =
      address(proposal.to[i]).call.value(proposal.value[i])(proposal.callData[i]);
      genericCallReturnValues[i] = genericCallReturnValue;
    }

    if (success) {
      delete organizationProposals[_proposalId];
      emit ProposalDeleted(_proposalId);
      emit ProposalExecuted(_proposalId, genericCallReturnValues);
    } else {
      proposal.exist = true;
    }
  }

  function proposeCalls(
    address[] memory _to,
    bytes[] memory _callData,
    uint256[] memory _value,
    string memory _descriptionHash
  )
  external
  returns(bytes32)
  {
    require(_to.length == _callData.length, 'invalid callData length');
    require(_to.length == _value.length, 'invalid _value length');

    bytes32 proposalId = votingMachine.propose(
      2,
      msg.sender,
      this
    );

    proposals[proposalId] = CallProposal({
      to: _to,
      callData: _callData,
      value: _value,
      exist: true,
      passed: false
    });

    emit NewCallProposal(_to, proposalId, _callData, _value, _descriptionHash);
    return proposalId;
  }

  function getOrganizationProposal(
    bytes32 _proposalId
  )
  external
  view
  returns (
    address[] memory to,
    bytes[] memory callData,
    uint256[] memory value,
    bool exist,
    bool passed
  )
  {
    return (
      proposals[_proposalId].to,
      proposals[_proposalId].callData,
      proposals[_proposalId].value,
      proposals[_proposalId].exist,
      proposals[_proposalId].passed
    );
  }
}
