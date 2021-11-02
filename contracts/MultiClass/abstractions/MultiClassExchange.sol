// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//contract user context (use this instead of msg.sender and msg.data)
import "@openzeppelin/contracts/utils/Context.sol";
//IMultiClass interface
import "./../../ERC721/interfaces/IERC721Exchange.sol";
//implementation of ERC721 Non-Fungible Token Standard
import "./../../ERC721/ERC721.sol";
//abstraction of MultiClassFees
import "./MultiClassFees.sol";

/**
 * @dev Abstract extension of MultiClass that allows tokens to be listed
 * and exchanged considering royalty fees
 */
abstract contract MultiClassExchange is
  Context, ERC721, MultiClassFees, IERC721Exchange
{
  // mapping of `tokenId` to amount
  // amount defaults to 0 and is in wei
  // apparently the data type for ether units is uint256 so we can interact
  // with it the same
  // see: https://docs.soliditylang.org/en/v0.7.1/units-and-global-variables.html
  mapping (uint256 => uint256) private _book;

  /**
   * @dev Returns the amount a `tokenId` is being offered for.
   */
  function listingOf(uint256 tokenId) public view override returns(uint256) {
    return _book[tokenId];
  }

  /**
   * @dev Lists `tokenId` on the order book for `amount` in wei.
   */
  function _list(uint256 tokenId, uint256 amount) internal {
    //error if the sender is not the owner
    // even the contract owner cannot list a token
    require(
      ownerOf(tokenId) == _msgSender(),
      "MultiClassExchange: Only the token owner can list a token"
    );
    //disallow free listings because solidity defaults amounts to zero
    //so it's impractical to determine a free listing from an unlisted one
    require(
      amount > 0,
      "MultiClassExchange: Listing amount should be more than 0"
    );
    //add the listing
    _book[tokenId] = amount;
    //emit that something was listed
    emit Listed(_msgSender(), tokenId, amount);
  }

  /**
   * @dev Removes `tokenId` from the order book.
   */
  function _delist(uint256 tokenId) internal {
    address owner = ownerOf(tokenId);
    //error if the sender is not the owner
    // even the contract owner cannot delist a token
    require(
      owner == _msgSender(),
      "MultiClassExchange: Only the token owner can delist a token"
    );
    //this is for the benefit of the sender so they
    //dont have to pay gas on things that dont matter
    require(
      _book[tokenId] != 0,
      "MultiClassExchange: Token is not listed"
    );
    //remove the listing
    delete _book[tokenId];
    //emit that something was delisted
    emit Delisted(owner, tokenId);
  }

  /**
   * @dev Allows for a sender to exchange `tokenId` for the listed `amount`
   */
  function _exchange(uint256 tokenId, uint256 amount) internal virtual {
    //get listing
    uint256 listing = listingOf(tokenId);
    //should be a valid listing
    require(listing > 0, "MultiClassExchange: Token is not listed");
    //value should equal the listing amount
    require(
      msg.value == listing,
      "MultiClassExchange: Amount sent does not match the listing amount"
    );

    //payout the fees
    uint256 remainder = _escrowFees(tokenId, amount);
    //get the token owner
    address payable tokenOwner = payable(ownerOf(tokenId));
    //send the remainder to the token owner
    tokenOwner.transfer(remainder);
    //transfer token from owner to buyer
    _transfer(tokenOwner, _msgSender(), tokenId);
    //now that the sender owns it, delist it
    _delist(tokenId);
  }
}
