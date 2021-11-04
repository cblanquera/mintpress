// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ProvablyFair.sol";
import "hardhat/console.sol";

library RandomPrize {
  struct PrizePool {
    ProvablyFair.RollState state;
    uint256[] prizes;
    uint256[] rollToPrizeMap;
  }

  /**
   * @dev rolls the dice and assigns the prize
   */
  function roll(
    PrizePool memory pool, 
    string memory clientSeed, 
    bool saveSeed
  ) internal view returns(uint256) {
    // provably fair roller
    uint256 _roll = ProvablyFair.roll(pool.state, clientSeed, saveSeed);
    //this is the determined prize
    uint256 prize;
    for (uint8 i = 0; i < pool.rollToPrizeMap.length; i++) {
      // if the roll value is not zero 
      // and the roll is less than the roll value
      if (prize == 0 
        && pool.rollToPrizeMap[i] > 0 
        && _roll <= pool.rollToPrizeMap[i]
      ) {
        //set the respective prize
        prize = pool.prizes[i];
        //less the max in the state
        pool.state.max -= 1;
      }
      //if we have a prize, then we should just less the map range
      if (prize > 0 && pool.rollToPrizeMap[i] > 0) {
        pool.rollToPrizeMap[i] -= 1;
      }
    }
    return prize;
  }
}