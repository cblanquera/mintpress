// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//labels contract owner only methods
import "@openzeppelin/contracts/access/Ownable.sol";
//interface of an ERC2981 compliant contract
import "../../ERC2981/IERC2981.sol";
//interface of a Rarible Royalties v2 compliant contract
import "../../Rarible/RoyaltiesV2.sol";
//abstract that considers royalty fees in multi classes
import "../../MultiClass/abstractions/MultiClassFees.sol";

/**
 * @dev Abstract of cross compliant royalties in multi classes
 */
abstract contract MintpressChargable is 
  MultiClassFees, 
  RoyaltiesV2, 
  Ownable 
{
  /*
   * bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
   */
  bytes4 internal constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

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
   * @dev Removes a fee
   */
  function deallocateAll(uint256 classId)
    external virtual onlyOwner
  {
    _deallocateFees(classId);
  }
  
  /**
   * @dev implements Rari getRaribleV2Royalties()
   */
  function getRaribleV2Royalties(uint256 tokenId) 
    external view virtual returns(LibPart.Part[] memory) 
  {
    uint256 classId = classOf(tokenId);
    uint256 size = _recipients[classId].length;
    //this is how to set the size of an array in memory
    LibPart.Part[] memory royalties = new LibPart.Part[](size);
    for (uint i = 0; i < size; i++) {
      address recipient = _recipients[classId][i];
      royalties[i] = LibPart.Part(
        payable(recipient), 
        _fee[classId][recipient]
      );
    }

    return royalties;
  }

  /**
   * @dev implements ERC2981 `royaltyInfo()`
   */
  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) 
    external 
    view 
    virtual 
    returns(address receiver, uint256 royaltyAmount) 
  {
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
}
