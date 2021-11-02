// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//IERC721MultiClass interface
import "./IERC721MultiClass.sol";

/**
 * @dev Required interface of an IERC721MultiClassSize compliant contract.
 */
interface IERC721MultiClassSize is IERC721MultiClass {
  /**
   * @dev Returns the total possible supply size of `classId`
   */
  function classSize(uint256 classId) external view returns(uint256);

  /**
   * @dev Returns true if `classId` supply and size are equal
   */
  function classFilled(uint256 classId) external view returns(bool);

  /**
   * @dev Returns the current supply size of `classId`
   */
  function classSupply(uint256 classId) external view returns(uint256);
}
