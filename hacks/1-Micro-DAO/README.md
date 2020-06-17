# Micro DAO
## Personal Intro
Hi my name is Jordan Ellis (dOrgJelli). I'm a human who loves to collaborate with others humans at dOrg.

Things I've done:
- [GitHub](https://github.com/dOrgJelli)
- [Twitter](https://twitter.com/dOrgJelli)
- [LinkedIn](https://www.linkedin.com/in/jordancellis/)
- [A Project From DigiPen](https://games.digipen.edu/games/rafflesia)
- [A Project From Microsoft](https://www.moog.com/news/operating-group-news/2019/Moog_Inc_Microsoft_Air_New_Zealand_ST_Engineering_Microsoft_Air_New_Zealand_and_ST_Engineering_Announce_Ground_Breaking_Digital_Collaboration.html)

## Description
I'd like to create a Minimum Viable DAO with as little custom code as possible, utilizing already existing building blocks. This DAO must be extendable for any use-case you can imagine.

In order to do this, I've taken heavy inspiration from DAOstack's Arc contracts, and Gnosis's Safe contracts, and Jordi Baylina's MiniMe Token.

## Time-Frame
15 hours

## Components
[DAO](./src/contracts/DAO/DAO.sol) - A simple contract that allows VotingCredits holders to vote on propoosals using a voting machine. These proposals are for a collection of executable calldatas.  
[VotingCredits](./src/contracts/VotingCredits/VotingCredits.sol) - A non-transferable MiniMe token.  
[VotingMachines](./src/contracts/VotingMachines) - A fork of [DAOstack's infra voting machines](https://github.com/daostack/infra).  
[IVotingMachine](./src/contracts/VotingMachines/IVotingMachine.sol) - A refactor of [DAOstack's IVotingMachine interface](https://github.com/daostack/infra/blob/master/contracts/votingMachines/IntVoteInterface.sol).  
[Registry](./src/contracts/Registry/OwnedItemRegistry.sol) - A fork of Level-K's ["Registry Builder"](https://github.com/levelkdev/registry-builder).  

## Closing Notes
This project is left in a very incomplete and experimental state. Here are some things I'd like to do in the future:  
- Recreate MiniMe using OpenZeppelin primitives.  
- Finish and use the newly refactored [IVotingMachine](./src/contracts/VotingMachines/IVotingMachine.sol) interface for the voting machines.  
  - Improve the interface to handle nonces & signature digests in a uniform way.  
  - Find a generic way to handle both msg.sender & signature based executions in a single function signature. This would reduce code bloat.  
- Move the "Generic Multi Call" proposal functionality out of the DAO smart contract, and utilize a modules pattern for all desired additive functionality.  
  - Maybe use the diamond contract pattern?
- Create a test scenario of a DAO that manages a registry.
- Implement a standard upgrade & versioning pattern for all components.  
  - Version upgrades should respect interfaces, and be able to deprecate old + introduce new.  
- Interface specific initializers.
  - This way a user can understand what interfaces are being used, what initializers those require, and if they have all been called meaning the contract / system is fully initialized.  
