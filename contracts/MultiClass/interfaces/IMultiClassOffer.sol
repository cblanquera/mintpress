// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an MultiClassFees compliant contract.
 */
interface IMultiClassOffer {
  /**
   * @dev Returns the offer of a `classId`
   */
  function offerOf(uint256 classId)
    external view returns(uint256);

  /**
   * @dev Returns the creator of a `classId`
   */
  function creatorOf(uint256 classId)
    external view returns(address);
}
