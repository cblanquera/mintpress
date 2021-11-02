// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//IERC2309 interface
import "./ERC2309/IERC2309.sol";
//implementation of ERC721 where tokens can be irreversibly burned (destroyed).
import "./ERC721/extensions/ERC721Burnable.sol";
//implementation of ERC721 where transers can be paused
import "./ERC721/extensions/ERC721Pausable.sol";
//Abstract extension of MultiClass that allows a class to reference data (like a uri)
import "./MultiClass/abstractions/MultiClassURIStorage.sol";
//Abstract extension of MultiClass that allows tokens to be listed and exchanged considering royalty fees
import "./MultiClass/abstractions/MultiClassExchange.sol";
//Abstract extension of MultiClass that manages class sizes
import "./MultiClass/abstractions/MultiClassSupply.sol";
//For verifying messages in lazyMint
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
//For verifying messages in lazyMint
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Rarible/LibPart.sol";
import "./Rarible/LibRoyaltiesV2.sol";
import "./Rarible/RoyaltiesV2.sol";

contract Mintpress is
  IERC2309,
  ERC721Burnable,
  ERC721Pausable,
  MultiClassURIStorage,
  MultiClassExchange,
  MultiClassSupply,
  RoyaltiesV2,
  Ownable
{
  /**
   * @dev Constructor function
   */
  constructor (string memory _name, string memory _symbol)
    ERC721(_name, _symbol) {}

  /**
   * @dev Sets a fee that will be collected during the exchange method
   */
  function allocate(uint256 classId, address recipient, uint96 fee)
    external virtual onlyOwner
  {
    _allocateFee(classId, recipient, fee);
  }

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
      require(!classFilled(classIds[i]), "Marketplace: Class filled.");
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
      "Marketplace: Invalid token range."
    );

    //check size
    uint256 length = (toTokenId - fromTokenId) + 1;
    uint256 supply = classSupply(classId);
    uint256 size = classSize(classId);

    require(
      size == 0 || ((supply + length) <= size), 
      "Marketplace: Class filled."
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
   * @dev Removes a fee
   */
  function deallocate(uint256 classId, address recipient)
    external virtual onlyOwner
  {
    _deallocateFee(classId, recipient);
  }

  /**
   * @dev Removes `tokenId` from the order book.
   */
  function delist(uint256 tokenId) external virtual {
    _delist(tokenId);
  }

  /**
   * @dev Allows for a sender to exchange `tokenId` for the listed amount
   */
  function exchange(uint256 tokenId) external virtual override payable {
    _exchange(tokenId, msg.value);
  }

  function getRaribleV2Royalties(uint256 tokenId) override external view returns (LibPart.Part[] memory) {
    uint256 classId = classOf(tokenId);
    uint256 size = _recipients[classId].length;
    LibPart.Part[] memory royalties;
    for (uint i = 0; i < size; i++) {
      LibPart.Part memory royalty;
      address recipient = _recipients[classId][i];
      royalty.account = payable(recipient);
      royalty.value = _fee[classId][recipient];
      royalties[i] = royalty;
    }

    return royalties;
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
    require(!classFilled(classId), "Marketplace: Class filled.");
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
      "Marketplace: Invalid proof."
    );

    //mint first and wait for errors
    _safeMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
    //then increment supply
    _addClassSupply(classId, 1);
  }

  /**
   * @dev Lists `tokenId` on the order book for `amount` in wei.
   */
  function list(uint256 tokenId, uint256 amount) external virtual {
    _list(tokenId, amount);
  }

  /**
   * @dev Mints `tokenId`, classifies it as `classId` and transfers to `recipient`
   */
  function mint(uint256 classId, uint256 tokenId, address recipient)
    external virtual onlyOwner
  {
    //check size
    require(!classFilled(classId), "Marketplace: Class filled.");
    //mint first and wait for errors
    _safeMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
    //then increment supply
    _addClassSupply(classId, 1);
  }

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
   * @dev References `classId` to `data` and `size`
   */
  function register(uint256 classId, uint256 size, string memory uri)
    external virtual onlyOwner
  {
    _setClassURI(classId, uri);
    //if size was set, fix it. Setting a zero size means no limit.
    if (size > 0) {
      _fixClassSize(classId, size);
    }
  }

  /**
   * @dev Rarible support interface
   */
  function supportsInterface(bytes4 interfaceId) 
    public view virtual override(ERC721, IERC165) returns(bool)
  {
    if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
      return true;
    }

    return super.supportsInterface(interfaceId);
  }

  /**
   * @dev Resolves duplicate tokenURI method definition
   * between ERC721 and ERC721URIStorage
   */
  function tokenURI(uint256 tokenId) 
    public 
    view 
    virtual 
    override 
    returns(string memory) 
  {
    uint256 classId = classOf(tokenId);

    require(
      classId > 0, 
      "Marketplace: Token is not apart of a multiclass"
    ); 
    
    return classURI(classId);
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

  /**
   * @dev Resolves duplicate _beforeTokenTransfer method definition
   * between ERC721 and ERC721Pausable
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override(ERC721, ERC721Pausable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }
}
