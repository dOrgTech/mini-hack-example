pragma solidity ^0.6.8;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "./BasicRegistry.sol";

/**
 * @title OwnedItemRegistry
 * @dev A registry where items are only removable by an item owner.
 */
contract OwnedItemRegistry is Initializable, Ownable, BasicRegistry {

  /**
   * @dev Overrides BasicRegistry.add(), sets msg.sender as item owner.
   * @param id The item to add to the registry.
   */
  function add(bytes32 id)
    public
    onlyOwner
  {
    super.add(id);
    owners[id] = msg.sender;
  }

  /**
   * @dev Overrides BasicRegistry.remove(), deletes item owner state.
   * @param id The item to remove from the registry.
   */
  function remove(bytes32 id)
    public
    onlyOwner
  {
    delete owners[id];
    super.remove(id);
  }
}
