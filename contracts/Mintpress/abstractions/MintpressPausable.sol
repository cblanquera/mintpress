// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//labels contract owner only methods
import "@openzeppelin/contracts/access/Ownable.sol";
//implementation of ERC721 where transers can be paused
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

/**
 * @dev Opens up the pausible methods
 */
abstract contract MintpressPausable is ERC721Pausable, Ownable {
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
}
