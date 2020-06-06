import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";

interface IVotingCredits is ERC20 {

  function balanceOfAt(
    address _owner,
    uint _blockNumber
  )
  public
  constant
  returns (uint);

  function totalSupplyAt(
    uint _blockNumber
  )
  public
  constant
  returns(uint);

  function createCloneToken(
    string _cloneTokenName,
    uint8 _cloneDecimalUnits,
    string _cloneTokenSymbol,
    uint _snapshotBlock,
    bool _transfersEnabled
  ) public returns(address);
}
