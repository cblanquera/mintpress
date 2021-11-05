// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//abstract of an OpenSea compliant contract
import "../../OpenSea/ERC721OpenSea.sol";

/**
 * @dev Abstract defines common publicly accessable contract methods
 */
abstract contract MintpressInformable is ERC721OpenSea {
  /**
   * @dev abstract; defined in MultiClass; Returns the class 
   *      given `tokenId`
   */
  function classOf(uint256 tokenId) 
    public virtual view returns(uint256);

  /**
   * @dev abstract; defined in MultiClassURIStorage; Returns the 
   *      data of `classId`
   */
  function classURI(uint256 classId) 
    public virtual view returns(string memory);

  /**
   * @dev Constructor function
   */
  constructor (string memory _baseTokenURI, string memory _contractURI) 
    ERC721OpenSea(_baseTokenURI, _contractURI)
  {}

  /**
   * @dev Returns the URI of the given `tokenId`
   *      Example Format:
   *      {
   *        "description": "Friendly OpenSea Creature.", 
   *        "external_url": "https://mywebsite.com/3", 
   *        "image": "https://mywebsite.com/3.png", 
   *        "name": "My NFT",
   *        "attributes": {
   *          "background_color": "#000000",
   *          "animation_url": "",
   *          "youtube_url": ""
   *        } 
   *      }
   */
  function tokenURI(uint256 tokenId) 
    public 
    view 
    virtual 
    returns(string memory) 
  {
    uint256 classId = classOf(tokenId);

    require(
      classId > 0, 
      "Mintpress: Token is not apart of a multiclass"
    ); 
    
    return classURI(classId);
  }
}
