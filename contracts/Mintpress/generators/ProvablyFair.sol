// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Implementation of a provably fair library
 */
library ProvablyFair {
  /**
   * @dev Pattern to manage the roll settings
   */
  struct RollState {
    uint256 max;
    uint256 min;
    uint256 nonce;
    bytes32 seed;
  }

  /**
   * @dev Helper to expose the hashed version of the server seed
   */
  function serverSeed(RollState memory state) 
    internal pure returns(bytes32) 
  {
    require(
      state.seed.length != 0, 
      "ProvablyFair: Missing server seed."
    );
    return keccak256(abi.encodePacked(state.seed));
  }

  /**
   * @dev rolls the dice and makes it relative to the range
   */
  function roll(
    RollState memory state, 
    string memory seed, 
    bool saveSeed
  ) internal view returns(uint256) {
    require(
      state.seed.length != 0, 
      "ProvablyFair: Missing server seed."
    );

    require(
      state.min < state.max, 
      "ProvablyFair: Minimum is greater than maximum."
    );

    //roll the dice
    uint256 results = uint256(
      keccak256(
        abi.encodePacked(
          state.seed, 
          msg.sender, 
          seed, 
          state.nonce
        )
      )
    ) + state.min;

    //increase nonce
    state.nonce += 1;

    if (!saveSeed) {
      //reset server seed
      state.seed = "";
    }

    //if there is a max
    if (state.max > 0) {
      //cap the results
      return results % state.max;  
    }

    return results;
  }
}