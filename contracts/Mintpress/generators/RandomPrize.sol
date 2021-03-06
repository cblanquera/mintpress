// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//provably fair library used as the prize roller
import "./ProvablyFair.sol";

/**
 * @dev Random prize roller 
 */
library RandomPrize {
  /**
   * @dev Pattern to manage prize pool and roll to prize map
   */
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
    uint256 less;
    uint256 difference = 0;
    for (uint8 i = 0; i < pool.rollToPrizeMap.length; i++) {
      if (i > 0 && pool.rollToPrizeMap[i - 1] > 0) {
        difference = pool.rollToPrizeMap[i - 1];
      }
      // if the roll value is not zero 
      // and the roll is less than the roll value
      if (prize == 0 
        && pool.rollToPrizeMap[i] > 0 
        && _roll <= pool.rollToPrizeMap[i]
      ) {
        //set the respective prize
        prize = pool.prizes[i];
        //get what we need to less
        less = pool.rollToPrizeMap[i] - difference;
        //set this now to zero so it can't be rolled for again
        pool.rollToPrizeMap[i] = 0;
        //less the max in the state
        pool.state.max -= less;
      }
      //if we have a prize, then we should just less the map range
      if (prize > 0 && pool.rollToPrizeMap[i] > 0) {
        pool.rollToPrizeMap[i] -= less;
      }
    }
    return prize;
  }
}