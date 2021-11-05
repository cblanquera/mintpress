// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an MultiClassURIStorage compliant contract.
 */
interface IMultiClassURIStorage {
  /**
   * @dev Returns the data of `classId`
   */
  function classURI(uint256 classId) 
    external view returns(string memory);
}
