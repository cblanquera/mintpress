// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//labels contract owner only methods
import "@openzeppelin/contracts/access/Ownable.sol";
//for verifying messages in lazyMint
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
//provably fair library for `mintPack()`
import "../generators/ProvablyFair.sol";
//random prize picker for `mintPack()`
import "../generators/RandomPrize.sol";

/**
 * @dev Abstract that opens up various minting methods
 */
abstract contract MintpressMintable is Ownable {
  // manual ReentrancyGuard
  bool private _minting = false;

  /**
   * @dev abstract; defined in MultiClassSupply; Returns true if 
   *      `classId` supply and size are equal
   */
  function classFilled(uint256 classId) 
    public view virtual returns(bool);

  /**
   * @dev abstract; defined in MultiClassSupply; Returns the total 
   *      possible supply size of `classId`
   */
  function classSize(uint256 classId) 
    public view virtual returns(uint256);

  /**
   * @dev abstract; defined in MultiClassSupply; Returns the current 
   *      supply size of `classId`
   */
  function classSupply(uint256 classId) 
    public view virtual returns(uint256);

  /**
   * @dev abstract; defined in MultiClassSupply; Increases the supply 
   *      of `classId` by `amount`
   */
  function _addClassSupply(uint256 classId, uint256 amount) 
    internal virtual;

  /**
   * @dev abstract; defined in BEP721; Adds to the overall amount 
   *      of tokens generated in the contract
   */
  function _addSupply(uint256 supply) internal virtual;

  /**
   * @dev abstract; defined in MultiClass; Maps `tokenId` to `classId`
   */
  function _classify(uint256 tokenId, uint256 classId) 
    internal virtual;
    
  /**
   * @dev abstract; defined in ERC721; Same as `_safeMint()`, with an 
   *      additional `data` parameter which is forwarded in 
   *      {IERC721Receiver-onERC721Received} to contract recipients.
   */
  function _safeMint(address to, uint256 tokenId) 
    internal virtual;
  
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
    require(!classFilled(classId), "Class filled.");
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
      "Invalid proof."
    );
    // manual ReentrancyGuard
    require(!_minting, "reentrant call");
    _minting = true;

    //mint first and wait for errors
    _safeMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
    //then increment supply
    _addClassSupply(classId, 1);
    //add to supply
    _addSupply(1);

    _minting = false;
  }

  /**
   * @dev Mints `tokenId`, classifies it as `classId` and 
   *      transfers to `recipient`
   */
  function mint(uint256 classId, uint256 tokenId, address recipient)
    public virtual onlyOwner
  {
    //check size
    require(!classFilled(classId), "Class filled.");
    //mint first and wait for errors
    _safeMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
    //then increment supply
    _addClassSupply(classId, 1);
    //add to supply
    _addSupply(1);
  }

  /**
   * @dev Randomly assigns a set of NFTs to a `recipient`
   */
  function mintPack(
    uint256[] memory classIds, 
    uint256 fromTokenId,
    address recipient, 
    uint8 tokensInPack,
    uint256 defaultSize,
    string memory seed
  ) external virtual onlyOwner {
    require(defaultSize > 0, "Missing default size");
    uint256[] memory rollToPrizeMap = new uint256[](classIds.length);
    uint256 size;
    uint256 supply;
    //loop through classIds
    for (uint8 i = 0; i < classIds.length; i++) {
      //get the class size
      size = classSize(classIds[i]);
      //if the class size is no limits
      if (size == 0) {
        //use the default size
        size = defaultSize;
      }
      //get the supply
      supply = classSupply(classIds[i]);
      //if the supply is greater than the size
      if (supply >= size) {
        //then we should zero out the 
        rollToPrizeMap[i] = 0;
        continue;
      }
      //determine the roll range for this class
      rollToPrizeMap[i] = size - supply;
      //to make it really a range we need 
      //to append the the last class range
      if (i > 0) {
        rollToPrizeMap[i] += rollToPrizeMap[i - 1];
      }
    }

    //figure out the max roll value 
    //(which should be the last value in the roll to prize map)
    uint256 maxRollValue = rollToPrizeMap[rollToPrizeMap.length - 1];
    //max roll value is also the total available tokens that can be 
    //minted if the tokens in pack is more than that, then we should 
    //error
    require(
      tokensInPack <= maxRollValue, 
      "Not enough tokens to make a mint pack"
    );

    //now we can create a prize pool
    RandomPrize.PrizePool memory pool = RandomPrize.PrizePool(
      ProvablyFair.RollState(
        maxRollValue, 0, 0, blockhash(block.number - 1)
      ), 
      classIds, 
      rollToPrizeMap
    );

    // manual ReentrancyGuard
    require(!_minting, "reentrant call");
    _minting = true;

    uint256 classId;
    // for each token in the pack
    for (uint8 i = 0; i < tokensInPack; i++) {
      //figure out what the winning class id is
      classId = RandomPrize.roll(pool, seed, (i + 1) < tokensInPack);
      //if there is a class id
      if (classId > 0) {
        //then lets mint it
        mint(classId, fromTokenId + i, recipient);
      }
    }

    _minting = false;
  }
}