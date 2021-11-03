// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//For verifying messages in lazyMint
import "@openzeppelin/contracts/access/Ownable.sol";

//implementation of ERC721
import "../ERC721/ERC721.sol";
//IERC2981 interface
import "../ERC2981/IERC2981.sol";
//implementation of ERC721 where transers can be paused
import "../MultiClass/abstractions/MultiClassFees.sol";

import "../Rarible/LibPart.sol";
import "../Rarible/LibRoyaltiesV2.sol";
import "../Rarible/RoyaltiesV2.sol";

abstract contract MintpressChargable is 
  ERC721, 
  IERC2981,
  MultiClassFees, 
  RoyaltiesV2,
  Ownable 
{
  /**
   * @dev Sets a fee that will be collected during the exchange method
   */
  function allocate(uint256 classId, address recipient, uint96 fee)
    external virtual onlyOwner
  {
    _allocateFee(classId, recipient, fee);
  }

  /**
   * @dev Removes a fee
   */
  function deallocate(uint256 classId, address recipient)
    external virtual onlyOwner
  {
    _deallocateFee(classId, recipient);
  }

  /**
   * @dev implements Rari getRaribleV2Royalties()
   */
  function getRaribleV2Royalties(uint256 tokenId) override external view returns (LibPart.Part[] memory) {
    uint256 classId = classOf(tokenId);
    uint256 size = _recipients[classId].length;
    LibPart.Part[] memory royalties;
    for (uint i = 0; i < size; i++) {
      LibPart.Part memory royalty;
      address recipient = _recipients[classId][i];
      royalty.account = payable(recipient);
      royalty.value = _fee[classId][recipient];
      royalties[i] = royalty;
    }

    return royalties;
  }

  /**
   * @dev implements ERC2981 royaltyInfo()
   */
  function royaltyInfo(
    uint256 _tokenId,
    uint256 _salePrice
  ) external view returns (
    address receiver,
    uint256 royaltyAmount
  ) {
    uint256 classId = classOf(_tokenId);
    if (_recipients[classId].length == 0) {
      return (address(0), 0);
    }

    address recipient = _recipients[classId][0];
    return (
      payable(recipient), 
      (_salePrice * _fee[classId][recipient]) / 10000
    );
  }

  /**
   * @dev Rarible support interface
   */
  function supportsInterface(bytes4 interfaceId) 
    public view virtual override(ERC721, IERC165) returns(bool)
  {
    if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
      return true;
    }

    return super.supportsInterface(interfaceId);
  }
}
