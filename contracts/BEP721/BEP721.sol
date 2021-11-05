// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//interface of a BEP721 compliant contract
import "./interfaces/IBEP721.sol";

/**
 * @dev Abstract of a BEP721 that pre defines total supply
 */
abstract contract BEP721 is IBEP721 {
  //for total supply
  uint256 private _supply = 0;

  /**
   * @dev Shows the overall amount of tokens generated in the contract
   */
  function totalSupply() public virtual view returns (uint256) {
    return _supply;
  }

  /**
   * @dev Adds to the overall amount of tokens generated in the contract
   */
  function _addSupply(uint256 supply) internal virtual {
    _supply += supply;
  }
}
