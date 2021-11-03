// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//For verifying messages in lazyMint
import "@openzeppelin/contracts/access/Ownable.sol";
//For verifying messages in lazyMint
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

//IERC2309 interface
import "../ERC2309/IERC2309.sol";
//implementation of ERC721
import "../ERC721/ERC721.sol";
//Abstract extension of MultiClass 
import "../MultiClass/abstractions/MultiClass.sol";
//Abstract extension of MultiClass that manages class sizes
import "../MultiClass/abstractions/MultiClassSupply.sol";

abstract contract MintpressMintable is 
  IERC2309, 
  ERC721, 
  MultiClass, 
  MultiClassSupply, 
  Ownable 
{
  /**
   * @dev Multiclass batch minting
   */
  function batchMint(
    uint256[] memory classIds, 
    uint256 fromTokenId,
    address recipient
  ) external virtual onlyOwner {
    uint256 length = classIds.length;

    for (uint256 i = 0; i < length; i++) {
      //check size
      require(!classFilled(classIds[i]), "Mintpress: Class filled.");
      //mint first and wait for errors
      _safeSilentMint(recipient, fromTokenId + i);
      //then classify it
      _classify(fromTokenId + i, classIds[i]);
      //then increment supply
      _addClassSupply(classIds[i], 1);
    }

    uint256 toTokenId = (fromTokenId + length) - 1;
    emit ConsecutiveTransfer(fromTokenId, toTokenId, address(0), recipient);
  }

  /**
   * @dev Multiclass batch minting
   */
  function batchClassMint(
    uint256 classId, 
    uint256 fromTokenId,
    uint256 toTokenId,
    address recipient
  ) external virtual onlyOwner {
    require(
      fromTokenId < toTokenId, 
      "Mintpress: Invalid token range."
    );

    //check size
    uint256 length = (toTokenId - fromTokenId) + 1;
    uint256 supply = classSupply(classId);
    uint256 size = classSize(classId);

    require(
      size == 0 || ((supply + length) <= size), 
      "Mintpress: Class filled."
    );

    for (uint256 tokenId = fromTokenId; tokenId <= fromTokenId; tokenId++) {
      //mint first and wait for errors
      _safeSilentMint(recipient, tokenId);
      //then classify it
      _classify(tokenId, classId);
    }

    //then increment supply
    _addClassSupply(classId, length);

    emit ConsecutiveTransfer(fromTokenId, toTokenId, address(0), recipient);
  }

  /**
   * @dev Allows anyone to self mint a token
   */
  function lazyMint(
    uint256 classId,
    uint256 tokenId,
    address recipient,
    bytes calldata proof
  ) external virtual {
    //check size
    require(!classFilled(classId), "Mintpress: Class filled.");
    //make sure the admin signed this off
    require(
      ECDSA.recover(
        ECDSA.toEthSignedMessageHash(
          keccak256(
            abi.encodePacked(classId, tokenId, recipient)
          )
        ),
        proof
      ) == owner(),
      "Mintpress: Invalid proof."
    );

    //mint first and wait for errors
    _safeMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
    //then increment supply
    _addClassSupply(classId, 1);
  }

  /**
   * @dev Mints `tokenId`, classifies it as `classId` and transfers to `recipient`
   */
  function mint(uint256 classId, uint256 tokenId, address recipient)
    external virtual onlyOwner
  {
    //check size
    require(!classFilled(classId), "Mintpress: Class filled.");
    //mint first and wait for errors
    _safeMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
    //then increment supply
    _addClassSupply(classId, 1);
  }
}
