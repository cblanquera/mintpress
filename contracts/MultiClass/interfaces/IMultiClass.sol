// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an MultiClass compliant contract.
 */
interface IMultiClass {
  /**
   * @dev Returns the class given `tokenId`
   */
  function classOf(uint256 tokenId) external view returns(uint256);
}
