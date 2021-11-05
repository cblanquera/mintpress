// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an MultiClassOrderBook compliant contract.
 */
interface IMultiClassOrderBook {
  /**
   * @dev Emitted when `owner` books their `tokenId` to
   *      be sold for `amount` in wei.
   */
  event Listed(
    address indexed owner,
    uint256 indexed tokenId,
    uint256 indexed amount
  );

  /**
   * @dev Emitted when `owner` removes their `tokenId` from the 
   *      order book.
   */
  event Delisted(address indexed owner, uint256 indexed tokenId);

  /**
   * @dev Returns the amount a `tokenId` is being offered for.
   */
  function listingOf(uint256 tokenId) external view returns(uint256);
}
