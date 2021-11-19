// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//interface of a MultiClassOffer compliant contract
import "./../interfaces/IMultiClassOffer.sol";

/**
 * @dev Abstract implementation of managing token offers 
 *      in multi classes
 */
abstract contract MultiClassOffer is IMultiClassOffer {
  //index mapping of classId to offer
  mapping(uint256 => uint256) private _offer;
  //index mapping of classId to creator
  mapping(uint256 => address) private _creator;
  //index mapping of classId to sale period
  mapping(uint256 => uint256[2]) private _period;

  /**
   * @dev abstract; defined in Ownable; Returns the address of the 
   *      current owner.
   */
  function owner() public view virtual returns (address);

  /**
   * @dev abstract; defined in Context; Returns the msg.sender.
   */
  function _msgSender() internal view virtual returns (address);

  /**
   * @dev Checks the validity of the offer
   */
  modifier offerValid(uint256 classId) {
    uint256 offer = _offer[classId];
    require(_creator[classId] != address(0), "No offer recipient");
    require(_offer[classId] > 0, "No offer availalable");
    require(
      _period[classId][0] == 0 || block.timestamp >= _period[classId][0], 
      "Offer not started"
    );

    require(
      _period[classId][1] == 0 || block.timestamp <= _period[classId][1], 
      "Offer has ended"
    );

    _;
  }

  /**
   * @dev Permission for creator or owner
   */
  modifier onlyCreatorOrOwner(uint256 classId) {
    uint256 offer = _offer[classId];
    address sender = _msgSender();
    require(
      sender == owner() || sender == _creator[classId], 
      "Caller is not the owner or creator"
    );

    _;
  }

  /**
   * @dev Returns the offer of a `classId`
   */
  function offerOf(uint256 classId)
    public view returns(uint256)
  {
    return _offer[classId];
  }

  /**
   * @dev Returns the creator of a `classId`
   */
  function creatorOf(uint256 classId)
    public view returns(address) 
  {
    return _creator[classId];
  }

  /**
   * @dev Sets the offer of `amount` in `classId`
   */
  function _makeOffer(
    uint256 classId, 
    uint256 amount, 
    uint256 start, 
    uint256 end
  ) internal virtual {
    require(_creator[classId] != address(0), "No offer recipient");
    require(amount > 0, "Offer amount should be more than zero");
    require(
      (start == 0 && end == 0) || end > start, 
      "Start time exceeds end time"
    );
    _offer[classId] = amount;
    
    if (start > 0) {
      _period[classId][0] = start;
    }

    if (end > 0) {
      _period[classId][1] = end;
    }
  }

  /**
   * @dev Sets the `creator` of the `classId`
   */
  function _setCreator(uint256 classId, address creator) 
    internal virtual 
  {
    _creator[classId] = creator;
  }
}
