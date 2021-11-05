// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//interface of an ERC165 compliant contract
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard
 */
interface IERC2981 is IERC165 {
  /** 
   * @dev ERC165 bytes to add to interface array - set in parent contract
   *  implementing this standard
   * 
   *  bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
   *  bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
   *  _registerInterface(_INTERFACE_ID_ERC2981);
   */
  function royaltyInfo(
    uint256 _tokenId,
    uint256 _salePrice
  ) external view returns (
    address receiver,
    uint256 royaltyAmount
  );
}