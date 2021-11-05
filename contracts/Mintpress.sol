// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//implementation of ERC721
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//implementation of ERC721 where tokens can be irreversibly 
//burned (destroyed).
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//abstract of cross compliant royalties in multi classes
import "./Mintpress/abstractions/MintpressChargable.sol";
//abstract that allows tokens to be listed and exchanged considering 
//royalty fees in multi classes
import "./Mintpress/abstractions/MintpressExchangable.sol";
//abstract defines common publicly accessable contract methods
import "./Mintpress/abstractions/MintpressInformable.sol";
//abstract that opens the order book methods
import "./Mintpress/abstractions/MintpressListable.sol";
//abstract that opens up various minting methods
import "./Mintpress/abstractions/MintpressMintable.sol";
//opens up the pausible methods
import "./Mintpress/abstractions/MintpressPausable.sol";
//passes multi class methods to Mintpress
import "./Mintpress/abstractions/MintpressSortable.sol";
//abstract of a BEP721 that pre defines total supply
import "./BEP721/BEP721.sol";
//rarible royalties v2 library
import "./Rarible/LibRoyaltiesV2.sol";

contract Mintpress is
  ERC721,
  BEP721,
  MintpressSortable,
  MintpressMintable,
  MintpressListable,
  MintpressChargable,
  MintpressPausable,
  MintpressExchangable,
  MintpressInformable,
  ERC721Burnable
{
  /**
   * @dev Constructor function
   */
  constructor (
    string memory _name, 
    string memory _symbol, 
    string memory _baseTokenURI, 
    string memory _contractURI
  ) 
    ERC721(_name, _symbol)
    MintpressInformable(_baseTokenURI, _contractURI)
  {}

  /**
   * @dev override; super defined in MultiClass; Returns the class 
   *      given `tokenId`
   */
  function classOf(uint256 tokenId) 
    public 
    virtual 
    view 
    override(MintpressInformable, MultiClass, MultiClassFees) 
    returns(uint256) 
  {
    return super.classOf(tokenId);
  }

  /**
   * @dev override; super defined in MultiClassSupply; Returns true if 
   *      `classId` supply and size are equal
   */
  function classFilled(uint256 classId) 
    public 
    view 
    virtual 
    override(MintpressMintable, MultiClassSupply) 
    returns(bool)
  {
    return super.classFilled(classId);
  }

  /**
   * @dev override; super defined in MultiClassSupply; Returns the  
   *      total possible supply size of `classId`
   */
  function classSize(uint256 classId) 
    public 
    view 
    virtual 
    override(MintpressMintable, MultiClassSupply) 
    returns(uint256)
  {
    return super.classSize(classId);
  }

  /**
   * @dev override; super defined in MultiClassSupply; Returns the  
   *      current supply size of `classId`
   */
  function classSupply(uint256 classId) 
    public 
    view 
    virtual 
    override(MintpressMintable, MultiClassSupply) 
    returns(uint256)
  {
    return super.classSupply(classId);
  }

  /**
   * @dev override; super defined in MultiClassURIStorage; Returns the 
   *      data of `classId`
   */
  function classURI(uint256 classId) 
    public 
    virtual 
    view 
    override(MintpressInformable, MultiClassURIStorage) 
    returns(string memory) 
  {
    return super.classURI(classId);
  }

  /**
   * @dev override; super defined in MultiClassOrderBook; Returns the 
   *      amount a `tokenId` is being offered for.
   */
  function listingOf(uint256 tokenId) 
    public 
    view 
    virtual 
    override(MultiClassOrderBook, MintpressExchangable) 
    returns(uint256) 
  {
    return super.listingOf(tokenId);
  }

  /**
   * @dev override; super defined in ERC721; Specifies the name by 
   *      which other contracts will recognize the BEP-721 token 
   */
  function name() 
    public virtual view override(IBEP721, ERC721) returns(string memory) 
  {
    return super.name();
  }
  
  /**
   * @dev override; super defined in ERC721; Returns the owner of 
   *      a `tokenId`
   */
  function ownerOf(uint256 tokenId) 
    public 
    view 
    virtual 
    override(IERC721, ERC721, MultiClassOrderBook, MintpressExchangable) 
    returns(address) 
  {
    return super.ownerOf(tokenId);
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
   * @dev override; super defined in ERC721; A concise name for the token, 
   *      comparable to a ticker symbol 
   */
  function symbol() 
    public 
    virtual 
    view 
    override(IBEP721, ERC721) returns(string memory) 
  {
    return super.symbol();
  }

  /**
   * @dev override; super defined in MintpressInformable; Returns the 
   *      URI of the given `tokenId`. Example Format:
   *      {
   *        "description": "Friendly OpenSea Creature", 
   *        "external_url": "https://mywebsite.com/3", 
   *        "image": "https://mywebsite.com/3.png", 
   *        "name": "My NFT",
   *        "attributes": {
   *          "background_color": "#000000",
   *          "animation_url": "",
   *          "youtube_url": ""
   *        } 
   *      }
   */
  function tokenURI(uint256 tokenId) 
    public 
    view 
    virtual 
    override(ERC721, MintpressInformable)
    returns(string memory) 
  {
    return super.tokenURI(tokenId);
  }

  /**
   * @dev override; super defined in MultiClassSupply; Increases the  
   *      supply of `classId` by `amount`
   */
  function _addClassSupply(uint256 classId, uint256 amount) 
    internal virtual override(MintpressMintable, MultiClassSupply)
  {
    super._addClassSupply(classId, amount);
  }

  /**
   * @dev override; super defined in BEP721; Adds to the overall amount 
   *      of tokens generated in the contract
   */
  function _addSupply(uint256 supply) 
    internal virtual override(BEP721, MintpressMintable)
  {
    super._addSupply(supply);
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

  /**
   * @dev override; super defined in MultiClass; Maps `tokenId` 
   *      to `classId`
   */
  function _classify(uint256 tokenId, uint256 classId) 
    internal virtual override(MintpressMintable, MultiClass)
  {
    super._classify(tokenId, classId);
  }
  
  /**
   * @dev override; super defined in MultiClassListings; Removes 
   *      `tokenId` from the order book.
   */
  function _delist(uint256 tokenId) 
    internal 
    virtual 
    override(MintpressExchangable, MultiClassOrderBook) 
  {
    return super._delist(tokenId);
  }
  
  /**
   * @dev Pays the amount to the recipients
   */
  function _escrowFees(uint256 tokenId, uint256 amount)
    internal 
    virtual 
    override(MintpressExchangable, MultiClassFees) 
    returns(uint256) 
  {
    return super._escrowFees(tokenId, amount);
  }

  /**
   * @dev override; super defined in Context; Returns the address of  
   *      the method caller
   */
  function _msgSender() 
    internal 
    view 
    virtual 
    override(Context, MultiClassOrderBook, MintpressExchangable) 
    returns(address) 
  {
    return super._msgSender();
  }
    
  /**
   * @dev override; super defined in ERC721; Same as `_safeMint()`, 
   *      with an additional `data` parameter which is forwarded in 
   *      {IERC721Receiver-onERC721Received} to contract recipients.
   */
  function _safeMint(address to, uint256 tokenId) 
    internal virtual override(ERC721, MintpressMintable)
  {
    super._safeMint(to, tokenId);
  }
  
  /**
   * @dev override; super defined in ERC721; Transfers `tokenId` 
   *      from `from` to `to`.
   */
  function _transfer(address from, address to, uint256 tokenId) 
    internal virtual override(ERC721, MintpressExchangable) 
  {
    return super._transfer(from, to, tokenId);
  }
}
