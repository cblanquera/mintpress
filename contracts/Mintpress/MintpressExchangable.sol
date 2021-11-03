// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//Abstract extension of MultiClass that allows tokens to be listed and exchanged considering royalty fees
import "../MultiClass/abstractions/MultiClassExchange.sol";

abstract contract MintpressExchangable is MultiClassExchange {
  /**
   * @dev Allows for a sender to exchange `tokenId` for the listed amount
   */
  function exchange(uint256 tokenId) external virtual override payable {
    _exchange(tokenId, msg.value);
  }
}
