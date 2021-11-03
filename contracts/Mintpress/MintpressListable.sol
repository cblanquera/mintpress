// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//Abstract extension of MultiClass that allows tokens to be listed and exchanged considering royalty fees
import "../MultiClass/abstractions/MultiClassExchange.sol";

abstract contract MintpressListable is MultiClassExchange {
  /**
   * @dev Removes `tokenId` from the order book.
   */
  function delist(uint256 tokenId) external virtual {
    _delist(tokenId);
  }

  /**
   * @dev Lists `tokenId` on the order book for `amount` in wei.
   */
  function list(uint256 tokenId, uint256 amount) external virtual {
    _list(tokenId, amount);
  }
}
