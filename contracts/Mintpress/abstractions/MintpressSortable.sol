// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//abstract implementation of a multi class token factory
import "../../MultiClass/abstractions/MultiClass.sol";
//abstract implementation of managing token supplies in multi classes
import "../../MultiClass/abstractions/MultiClassSupply.sol";
//abstract implementation of attaching URIs in token classes
import "../../MultiClass/abstractions/MultiClassURIStorage.sol";

/**
 * @dev Passes multi class methods to Mintpress
 */
abstract contract MintpressSortable is 
  MultiClass, 
  MultiClassSupply, 
  MultiClassURIStorage
{
}
