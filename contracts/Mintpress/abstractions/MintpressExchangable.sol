// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Abstract that allows tokens to be listed
 * and exchanged considering royalty fees in multi classes
 */
abstract contract MintpressExchangable {
  // manual ReentrancyGuard
  bool private _exchanging = false;

  /**
   * @dev abstract; defined in MultiClassOrderBook; Returns the 
   *      amount a `tokenId` is being offered for.
   */
  function listingOf(uint256 tokenId) 
    public view virtual returns(uint256);
  
  /**
   * @dev abstract; defined in ERC721; Returns the owner of a `tokenId`
   */
  function ownerOf(uint256 tokenId) 
    public view virtual returns(address);

  /**
   * @dev abstract; defined in MultiClassOrderBook; Removes `tokenId` 
   *      from the order book.
   */
  function _delist(uint256 tokenId) internal virtual;
  
  /**
   * @dev abstract; defined in MultiClassOrderBook; Pays the amount 
   *      to the recipients
   */
  function _escrowFees(uint256 tokenId, uint256 amount)
    internal virtual returns(uint256);
  
  /**
   * @dev abstract; defined in Context; Returns the address of the 
   *      method caller
   */
  function _msgSender() internal view virtual returns(address);
  
  /**
   * @dev abstract; defined in ERC721; Transfers `tokenId` from 
   *      `from` to `to`.
   */
  function _transfer(address from, address to, uint256 tokenId) 
    internal virtual;
  
  /**
   * @dev Allows for a sender to exchange `tokenId` for the listed amount
   */
  function exchange(uint256 tokenId) 
    external virtual payable 
  {
    //get listing
    uint256 listing = listingOf(tokenId);
    //should be a valid listing
    require(listing > 0, "Mintpress: Token is not listed");
    //value should equal the listing amount
    require(
      msg.value == listing,
      "Mintpress: Amount sent does not match the listing amount"
    );
    // manual ReentrancyGuard
    require(!_exchanging, "Mintpress: reentrant call");
    _exchanging = true;

    //payout the fees
    uint256 remainder = _escrowFees(tokenId, msg.value);
    //get the token owner
    address payable tokenOwner = payable(ownerOf(tokenId));
    //send the remainder to the token owner
    tokenOwner.transfer(remainder);
    //transfer token from owner to buyer
    _transfer(tokenOwner, _msgSender(), tokenId);
    //now that the sender owns it, delist it
    _delist(tokenId);

    _exchanging = false;
  }
}
