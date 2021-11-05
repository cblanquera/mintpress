// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//abstract that allows tokens to be listed in an order book
import "../../MultiClass/abstractions/MultiClassOrderBook.sol";

/**
 * @dev Abstract that opens the order book methods
 */
abstract contract MintpressListable is MultiClassOrderBook {
  /**
   * @dev Removes `tokenId` from the order book.
   */
  function delist(uint256 tokenId) external virtual {
    _delist(tokenId);
  }

  /**
   * @dev Lists `tokenId` on the order book for `amount` in wei.
   */
  function list(uint256 tokenId, uint256 amount) 
    external virtual 
  {
    _list(tokenId, amount);
  }
}
