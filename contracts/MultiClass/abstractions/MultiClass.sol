// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//IMultiClass interface
import "./../interfaces/IMultiClass.sol";

/**
 * @dev Abstract of an ERC721 managing multiple classes of tokens
 */
abstract contract MultiClass is IMultiClass {
  //mapping of token id to class
  mapping(uint256 => uint256) private _tokens;

  /**
   * @dev Returns the class given `tokenId`
   */
  function classOf(uint256 tokenId) public view override returns(uint256) {
    return _tokens[tokenId];
  }

  /**
   * @dev Maps `tokenId` to `classId`
   */
  function _classify(uint256 tokenId, uint256 classId) internal virtual {
    require(
      _tokens[tokenId] == 0,
      "MultiClass: Token is already classified"
    );
    _tokens[tokenId] = classId;
  }
}
