// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//ERC721 interface
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Required interface of an IERC721MultiClass compliant contract.
 */
interface IERC721MultiClass is IERC721 {
  /**
   * @dev Returns the class given `tokenId`
   */
  function classOf(uint256 tokenId) external view returns(uint256);
}
