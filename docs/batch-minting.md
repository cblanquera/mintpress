# About Batch Minting

Mintpress does not encourage batch minting because we already tried. 
The following is a report of our findings.

## About the ERC2309

This spec provides a way to batch mint. The spec requires that the 
following `ConsecutiveTransfer` event to be defined and emitted after a 
batch call.

```js
//ERC721 interface
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Required interface of an IERC721Exchange compliant contract.
 */
interface IERC2309 is IERC721 {
  /**
   * @dev Emitted when `owner` books their `tokenId` to
   * be sold for `amount` in wei.
   */
  event ConsecutiveTransfer(
    uint256 indexed fromTokenId, 
    uint256 toTokenId, 
    address indexed fromAddress, 
    address indexed toAddress
  );
}
```

If you are using the `@openzeppelin` ERC721 contract, this would require 
you to modify the `_mint()` function or create a new `_silentMint()`, 
one that doesn't emit the `Transfer` event *(or hey maybe it was 
intended for both events to be emitted...)*. Either way since the 
`_balances` and `_owners` properties on the ERC721 contract is private,
you would eventually need to have a modified version of this file in 
your project if you are looking to optimize the mint process in order 
to save gas.

## Flexible Batch Minting 

Consider the following function that allows to batch mint multiple 
tokens in multiple token classes.

```js
/**
 * @dev Multiclass batch minting
 */
function batchMint(
  uint[] memory classIds, 
  uint fromTokenId,
  address recipient
) external virtual onlyOwner {
  uint length = classIds.length;

  for (uint i = 0; i < length; i++) {
    //check size
    require(!classFilled(classIds[i]), "Mintpress: Class filled.");
    //mint first and wait for errors
    _safeSilentMint(recipient, fromTokenId + i);
    //then classify it
    _classify(fromTokenId + i, classIds[i]);
    //then increment supply
    _addClassSupply(classIds[i], 1);
  }

  uint toTokenId = (fromTokenId + length) - 1;
  emit ConsecutiveTransfer(fromTokenId, toTokenId, address(0), recipient);
}
```

This is the gas report for batch minting 100 tokens. After the 100, it sometimes runs out of gas.

```
·--------------------------------|---------------------------|-------------|-----------------------------·
|      Solc version: 0.8.9       ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 12450000 gas  │
·································|···························|·············|······························
|  Methods                       ·              200 gwei/gas               ·       4578.47 usd/eth       │
··············|··················|·············|·············|·············|···············|··············
|  Contract   ·  Method          ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  batchMint       ·     338855  ·    4816814  ·    2577835  ·            2  ·    2360.51  │
··············|··················|·············|·············|·············|···············|··············
|  Deployments                   ·                                         ·  % of limit   ·             │
·································|·············|·············|·············|···············|··············
|  Mintpress                     ·          -  ·          -  ·    3302492  ·       26.5 %  ·    3024.07  │
·--------------------------------|-------------|-------------|-------------|---------------|-------------·
```

## Practical Batch Minting 

Consider the following safer function that allows to batch mint multiple 
tokens per token class.

```js
/**
 * @dev Multiclass batch minting
 */
function batchMint(
  uint classId, 
  uint fromTokenId,
  uint toTokenId,
  address recipient
) external virtual onlyOwner {
  require(
    fromTokenId < toTokenId, 
    "Mintpress: Invalid token range."
  );

  //check size
  uint length = (toTokenId - fromTokenId) + 1;
  uint supply = classSupply(classId);
  uint size = classSize(classId);

  require(
    size == 0 || ((supply + length) <= size), 
    "Mintpress: Batch mint exceeds class size."
  );

  for (uint tokenId = fromTokenId; tokenId <= toTokenId; tokenId++) {
    //mint first and wait for errors
    _safeSilentMint(recipient, tokenId);
    //then classify it
    _classify(tokenId, classId);
  }

  //then increment supply
  _addClassSupply(classId, length);

  emit ConsecutiveTransfer(fromTokenId, toTokenId, address(0), recipient);
}
```

This is the gas report for batch minting 200 tokens. After the 200, it sometimes runs out of gas.

```
·--------------------------------|---------------------------|-------------|-----------------------------·
|      Solc version: 0.8.9       ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 12450000 gas  │
·································|···························|·············|······························
|  Methods                       ·              200 gwei/gas               ·       4578.47 usd/eth       │
··············|··················|·············|·············|·············|···············|··············
|  Contract   ·  Method          ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
··············|··················|·············|·············|·············|···············|··············
|  Mintpress  ·  batchMint       ·          -  ·          -  ·    9320281  ·            1  ·    8552.87  │
··············|··················|·············|·············|·············|···············|··············
|  Deployments                   ·                                         ·  % of limit   ·             │
·································|·············|·············|·············|···············|··············
|  Mintpress                     ·          -  ·          -  ·    3302492  ·       26.5 %  ·    3024.07  │
·--------------------------------|-------------|-------------|-------------|---------------|-------------·
```

Both gas reports indicates that though batch minting is a wanted idea, the implementation of it is impractical.