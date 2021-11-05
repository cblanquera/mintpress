// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//interface of a MultiClassOrderBook compliant contract
import "./../interfaces/IMultiClassOrderBook.sol";

/**
 * @dev Abstract that allows tokens to be listed in an order book
 */
abstract contract MultiClassOrderBook is IMultiClassOrderBook {
  // mapping of `tokenId` to amount
  // amount defaults to 0 and is in wei
  // apparently the data type for ether units is uint256 so we can interact
  // with it the same
  // see: https://docs.soliditylang.org/en/v0.7.1/units-and-global-variables.html
  mapping (uint256 => uint256) private _book;

  /**
   * @dev abstract; defined in ERC721; See {IERC721-ownerOf}.
   */
  function ownerOf(uint256 tokenId) 
    public view virtual returns (address);

  /**
   * @dev abstract; defined in Context; Returns the caller of 
   *      a contract method
   */
  function _msgSender() internal view virtual returns (address);

  /**
   * @dev Returns the amount a `tokenId` is being offered for.
   */
  function listingOf(uint256 tokenId) 
    public view virtual returns(uint256) 
  {
    return _book[tokenId];
  }

  /**
   * @dev Lists `tokenId` on the order book for `amount` in wei.
   */
  function _list(uint256 tokenId, uint256 amount) internal virtual {
    //error if the sender is not the owner
    // even the contract owner cannot list a token
    require(
      ownerOf(tokenId) == _msgSender(),
      "MultiClass: Only the token owner can list a token"
    );
    //disallow free listings because solidity defaults amounts to zero
    //so it's impractical to determine a free listing from an unlisted one
    require(
      amount > 0,
      "MultiClass: Listing amount should be more than 0"
    );
    //add the listing
    _book[tokenId] = amount;
    //emit that something was listed
    emit Listed(_msgSender(), tokenId, amount);
  }

  /**
   * @dev Removes `tokenId` from the order book.
   */
  function _delist(uint256 tokenId) internal virtual {
    address owner = ownerOf(tokenId);
    //error if the sender is not the owner
    // even the contract owner cannot delist a token
    require(
      owner == _msgSender(),
      "MultiClass: Only the token owner can delist a token"
    );
    //this is for the benefit of the sender so they
    //dont have to pay gas on things that dont matter
    require(
      _book[tokenId] != 0,
      "MultiClass: Token is not listed"
    );
    //remove the listing
    delete _book[tokenId];
    //emit that something was delisted
    emit Delisted(owner, tokenId);
  }
}
