// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//interface of a MultiClassSupply compliant contract
import "./../interfaces/IMultiClassSupply.sol";

/**
 * @dev Abstract implementation of managing token supplies 
 *      in multi classes
 */
abstract contract MultiClassSupply is IMultiClassSupply {
  //index mapping of classId to current supply size
  mapping(uint256 => uint256) private _supply;
  //mapping of classId to total supply size
  mapping(uint256 => uint256) private _size;

  /**
   * @dev Returns true if `classId` supply and size are equal
   */
  function classFilled(uint256 classId) 
    public view virtual returns(bool) 
  {
    return _size[classId] != 0 && _supply[classId] == _size[classId];
  }

  /**
   * @dev Returns the total possible supply size of `classId`
   */
  function classSize(uint256 classId) 
    public view virtual returns(uint256) 
  {
    return _size[classId];
  }

  /**
   * @dev Returns the current supply size of `classId`
   */
  function classSupply(uint256 classId) 
    public view virtual returns(uint256) 
  {
    return _supply[classId];
  }

  /**
   * @dev Sets an immutable fixed `size` to `classId`
   */
  function _fixClassSize(uint256 classId, uint256 size) 
    internal virtual 
  {
    require (
      _size[classId] == 0,
      "MultiClass: Class is already sized."
    );
    _size[classId] = size;
  }

  /**
   * @dev Increases the supply of `classId` by `amount`
   */
  function _addClassSupply(uint256 classId, uint256 amount) 
    internal virtual 
  {
    uint256 size = _supply[classId] + amount;
    require(
      _size[classId] == 0 || size <= _size[classId],
      "MultiClass: Amount overflows class size."
    );
    _supply[classId] = size;
  }
}
