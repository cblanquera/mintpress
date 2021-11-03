// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//For verifying messages in lazyMint
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
//For verifying messages in lazyMint
import "@openzeppelin/contracts/access/Ownable.sol";

//IERC2981 interface
import "./BEP721/IBEP721.sol";
//IERC2981 interface
import "./ERC2981/IERC2981.sol";
//implementation of ERC721 where tokens can be irreversibly burned (destroyed).
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//implementation of ERC721 where transers can be paused
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
//Abstract extension of MultiClass that allows a class to reference data (like a uri)
import "./MultiClass/abstractions/MultiClassURIStorage.sol";
//Abstract extension of MultiClass that allows tokens to be listed and exchanged considering royalty fees
import "./MultiClass/abstractions/MultiClassExchange.sol";
//Abstract extension of MultiClass that manages class sizes
import "./MultiClass/abstractions/MultiClassSupply.sol";

import "./Rarible/LibPart.sol";
import "./Rarible/LibRoyaltiesV2.sol";
import "./Rarible/RoyaltiesV2.sol";

contract Mintpress is
  IBEP721,
  IERC2981,
  ERC721Burnable,
  ERC721Pausable,
  MultiClassURIStorage,
  MultiClassExchange,
  MultiClassSupply,
  RoyaltiesV2,
  Ownable
{
  //for total supply
  uint256 private _supply = 0;

  /**
   * @dev Constructor function
   */
  constructor (string memory _name, string memory _symbol)
    ERC721(_name, _symbol) 
  {}

  /**
   * @dev Sets a fee that will be collected during the exchange method
   */
  function allocate(uint256 classId, address recipient, uint96 fee)
    external virtual onlyOwner
  {
    _allocateFee(classId, recipient, fee);
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

  /**
   * @dev implements Rari getRaribleV2Royalties()
   */
  function getRaribleV2Royalties(uint256 tokenId) override external view returns (LibPart.Part[] memory) {
    uint256 classId = classOf(tokenId);
    uint256 size = _recipients[classId].length;
    //this is how to set the size of an array in memory
    LibPart.Part[] memory royalties = new LibPart.Part[](size);
    for (uint i = 0; i < size; i++) {
      address recipient = _recipients[classId][i];
      royalties[i] = LibPart.Part(
        payable(recipient), 
        _fee[classId][recipient]
      );
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
    //add to supply
    _supply += 1;
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
    require(!classFilled(classId), "Mintpress: Class filled.");
    //mint first and wait for errors
    _safeMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
    //then increment supply
    _addClassSupply(classId, 1);
    //add to supply
    _supply += 1;
  }

  /**
   * @dev Specifies the name by which other contracts will recognize the BEP-721 token 
   */
  function name() 
    public view override(ERC721, IBEP721) returns(string memory) 
  {
    return super.name();
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
   * @dev implements ERC2981 royaltyInfo()
   */
  function royaltyInfo(
    uint256 _tokenId,
    uint256 _salePrice
  ) external view returns (
    address receiver,
    uint256 royaltyAmount
  ) {
    uint256 classId = classOf(_tokenId);
    if (_recipients[classId].length == 0) {
      return (address(0), 0);
    }

    address recipient = _recipients[classId][0];
    return (
      payable(recipient), 
      (_salePrice * _fee[classId][recipient]) / 10000
    );
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
   * @dev A concise name for the token, comparable to a ticker symbol 
   */
  function symbol() 
    public view override(ERC721, IBEP721) returns (string memory) 
  {
    return super.symbol();
  }

  /**
   * @dev Resolves duplicate tokenURI method definition
   * between ERC721 and ERC721URIStorage
   * Example Format:
   * {
   *   "description": "Friendly OpenSea Creature that enjoys long swims in the ocean.", 
   *   "external_url": "https://mywebsite.com/3", 
   *   "image": "https://mywebsite.com/3.png", 
   *   "name": "My NFT",
   *   "attributes": {
   *     "background_color": "#000000",
   *     "animation_url": "",
   *     "youtube_url": ""
   *   } 
   * }
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
      "Mintpress: Token is not apart of a multiclass"
    ); 
    
    return classURI(classId);
  }

  /**
   * @dev Shows the overall amount of tokens generated
   */
  function totalSupply() public virtual view returns (uint256) {
    return _supply;
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
