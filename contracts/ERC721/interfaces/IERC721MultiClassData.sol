// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//IERC721MultiClass interface
import "./IERC721MultiClass.sol";

/**
 * @dev Required interface of an IERC721MultiClassData compliant contract.
 */
interface IERC721MultiClassData is IERC721MultiClass {
  /**
   * @dev Returns the data of `classId`
   */
  function classURI(uint256 classId) external view returns(string memory);
}
