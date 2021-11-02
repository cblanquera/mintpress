// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//IERC721MultiClassData interface
import "./../interfaces/IERC721MultiClassData.sol";

/**
 * @dev Abstract extension of ERC721MultiClass that allows a
 * class to reference data (like a uri)
 */
abstract contract ERC721MultiClassData is IERC721MultiClassData {
  //mapping of `classId` to `data`
  mapping(uint256 => string) private _classURIs;

  /**
   * @dev Returns the reference of `classId`
   */
  function classURI(uint256 classId)
    public view returns(string memory)
  {
    return _classURIs[classId];
  }

  /**
   * @dev References `data` to `classId`
   */
  function _setClassURI(uint256 classId, string memory data)
    internal virtual
  {
    require(
      bytes(_classURIs[classId]).length == 0,
      "ERC721MultiClass: Class is already referenced"
    );
    _classURIs[classId] = data;
  }
}
