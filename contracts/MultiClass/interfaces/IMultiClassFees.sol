// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an MultiClassFees compliant contract.
 */
interface IMultiClassFees {
  /**
   * @dev Returns the fee of a `recipient` in `classId`
   */
  function classFeeOf(uint256 classId, address recipient)
    external view returns(uint256);

  /**
   * @dev returns the total fees of `classId`
   */
  function classFees(uint256 classId)
    external view returns(uint256);
}
