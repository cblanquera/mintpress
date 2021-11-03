// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//IERC2981 interface
import "../BEP721/IBEP721.sol";
//implementation of ERC721
import "../ERC721/ERC721.sol";
//Abstract extension of MultiClass 
import "../MultiClass/abstractions/MultiClass.sol";
//Abstract extension of MultiClass that allows a class to reference data (like a uri)
import "../MultiClass/abstractions/MultiClassURIStorage.sol";

abstract contract MintpressInformable is 
  IBEP721, 
  ERC721,
  MultiClass, 
  MultiClassURIStorage 
{
  /**
   * @dev Shows the overall amount of tokens generated
   */
  function totalSupply() public view override(ERC721, IBEP721) returns (uint256) {}

  /**
   * @dev Specifies the name by which other contracts will recognize the BEP-721 token 
   */
  function name() 
    public view override(ERC721, IBEP721) returns(string memory) 
  {
    return super.name();
  }

  /**
   * @dev A concise name for the token, comparable to a ticker symbol 
   */
  function symbol() 
    public view override(ERC721, IBEP721) returns (string memory) 
  {
    return super.symbol();
  }

  /**
   * @dev Resolves duplicate tokenURI method definition
   * between ERC721 and ERC721URIStorage
   */
  function tokenURI(uint256 tokenId) 
    public 
    view 
    virtual 
    override 
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
