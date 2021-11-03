// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//For verifying messages in lazyMint
import "@openzeppelin/contracts/access/Ownable.sol";

//implementation of ERC721
import "../ERC721/ERC721.sol";
//implementation of ERC721 where transers can be paused
import "../ERC721/extensions/ERC721Pausable.sol";

abstract contract MintpressPausable is 
  ERC721, ERC721Pausable, Ownable
{
  /**
   * @dev Pauses all token transfers.
   *
   * See {ERC721Pausable} and {Pausable-_pause}.
   *
   * Requirements:
   *
   * - the caller must have the `PAUSER_ROLE`.
   */
  function pause() public virtual onlyOwner {
    _pause();
  }

  /**
   * @dev Unpauses all token transfers.
   *
   * See {ERC721Pausable} and {Pausable-_unpause}.
   *
   * Requirements:
   *
   * - the caller must have the `PAUSER_ROLE`.
   */
  function unpause() public virtual onlyOwner {
    _unpause();
  }

  /**
   * @dev Resolves duplicate _beforeTokenTransfer method definition
   * between ERC721 and ERC721Pausable
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override(ERC721, ERC721Pausable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }
}
