// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//IERC721MultiClass interface
import "./../interfaces/IERC721MultiClassFees.sol";
//abstraction of ERC721MultiClass
import "./ERC721MultiClass.sol";

/**
 * @dev Abstract extension of ERC721MultiClass that attaches royalty fees
 */
abstract contract ERC721MultiClassFees is
  ERC721MultiClass, IERC721MultiClassFees
{
  //10000 means 100.00%
  uint256 private constant TOTAL_ALLOWABLE_FEES = 10000;
  //mapping of `classId` to total fees (could be problematic if not synced)
  mapping(uint256 => uint256) private _fees;
  //mapping of `classId` to `recipient` fee
  mapping(uint256 => mapping(address => uint256)) private _fee;
  //index mapping of `classId` to recipients (so we can loop the map)
  mapping(uint256 => address[]) private _recipients;

  /**
   * @dev Returns the fee of a `recipient` in `classId`
   */
  function classFeeOf(uint256 classId, address recipient)
    public view override returns(uint256)
  {
    return _fee[classId][recipient];
  }

  /**
   * @dev returns the total fees of `classId`
   */
  function classFees(uint256 classId) public view override returns(uint256) {
    return _fees[classId];
  }

  /**
   * @dev Sets a fee that will be collected during the exchange method
   */
  function _allocateFee(uint256 classId, address recipient, uint256 fee)
    internal virtual
  {
    require(
      fee > 0,
      "ERC721MultiClassFees: Fee should be more than 0"
    );

    //if no recipient
    if (_fee[classId][recipient] == 0) {
      //add recipient
      _recipients[classId].push(recipient);
      //map fee
      _fee[classId][recipient] = fee;
      //add to total fee
      _fees[classId] += fee;
    //else there"s already an existing recipient
    } else {
      //remove old fee from total fee
      _fees[classId] -= _fee[classId][recipient];
      //map fee
      _fee[classId][recipient] = fee;
      //add to total fee
      _fees[classId] += fee;
    }

    //safe check
    require(
      _fees[classId] <= TOTAL_ALLOWABLE_FEES,
      "ERC721MultiClassFees: Exceeds allowable fees"
    );
  }

  /**
   * @dev Removes a fee
   */
  function _deallocateFee(uint256 classId, address recipient) internal virtual {
    //this is for the benefit of the sender so they
    //dont have to pay gas on things that dont matter
    require(
      _fee[classId][recipient] != 0,
      "ERC721MultiClassFees: Recipient has no fees"
    );
    //deduct total fees
    _fees[classId] -= _fee[classId][recipient];
    //remove fees from the map
    delete _fee[classId][recipient];
    //Tricky logic to remove an element from an array...
    //if there are at least 2 elements in the array,
    if (_recipients[classId].length > 1) {
      //find the recipient
      for (uint i = 0; i < _recipients[classId].length; i++) {
        if(_recipients[classId][i] == recipient) {
          //move the last element to the deleted element
          uint last = _recipients[classId].length - 1;
          _recipients[classId][i] = _recipients[classId][last];
          break;
        }
      }
    }

    //either way remove the last element
    _recipients[classId].pop();
  }

  /**
   * @dev Pays the amount to the recipients
   */
  function _escrowFees(uint256 tokenId, uint256 amount)
    internal virtual returns(uint256)
  {
    //get class from token
    uint256 classId = classOf(tokenId);
    require(classId != 0, "ERC721MultiClassFees: Class does not exist");

    //placeholder for recipient in the loop
    address recipient;
    //release payments to recipients
    for (uint i = 0; i < _recipients[classId].length; i++) {
      //get the recipient
      recipient = _recipients[classId][i];
      // (10 eth * 2000) / 10000 =
      payable(recipient).transfer(
        (amount * _fee[classId][recipient]) / TOTAL_ALLOWABLE_FEES
      );
    }

    //determine the remaining fee percent
    uint256 remainingFee = TOTAL_ALLOWABLE_FEES - _fees[classId];
    //return the remainder amount
    return (amount * remainingFee) / TOTAL_ALLOWABLE_FEES;
  }
}
