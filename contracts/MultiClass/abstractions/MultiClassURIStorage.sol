// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//interface of a MultiClassURIStorage compliant contract
import "./../interfaces/IMultiClassURIStorage.sol";

/**
 * @dev Abstract implementation of attaching URIs in token classes
 */
abstract contract MultiClassURIStorage is IMultiClassURIStorage {
  //mapping of `classId` to `data`
  mapping(uint256 => string) private _classURIs;

  /**
   * @dev Returns the reference of `classId`
   */
  function classURI(uint256 classId)
    public view virtual returns(string memory)
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
      "Class is already referenced"
    );
    _classURIs[classId] = data;
  }
}
