// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//ERC721 interface
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Required interface of an IERC721Exchange compliant contract.
 */
interface IERC2309 is IERC721 {
  /**
   * @dev Emitted when `owner` books their `tokenId` to
   * be sold for `amount` in wei.
   */
  event ConsecutiveTransfer(
    uint256 indexed fromTokenId, 
    uint256 toTokenId, 
    address indexed fromAddress, 
    address indexed toAddress
  );
}
