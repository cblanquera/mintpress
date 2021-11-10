// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//interface of an ERC721 compliant contract
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev see: https://docs.opensea.io/docs/1-structuring-your-smart-contract
 *      see: https://github.com/ProjectOpenSea/opensea-creatures/blob/master/contracts/ERC721Tradable.sol#L70-L86
 */
interface IERC721OpenSea is IERC721 {
  /**
   * @dev The base URI for token data ex. https://creatures-api.opensea.io/api/creature/
   * Example Usage: 
   *  Strings.strConcat(baseTokenURI(), Strings.uint2str(tokenId))
   */
  function baseTokenURI() external view returns (string memory);

  /**
   * @dev The URI for contract data ex. https://creatures-api.opensea.io/contract/opensea-creatures/contract.json
   * Example Format:
   * {
   *   "name": "OpenSea Creatures",
   *   "description": "OpenSea Creatures are adorable aquatic beings primarily for demonstrating what can be done using the OpenSea platform. Adopt one today to try out all the OpenSea buying, selling, and bidding feature set.",
   *   "image": "https://openseacreatures.io/image.png",
   *   "external_link": "https://openseacreatures.io",
   *   "seller_fee_basis_points": 100, # Indicates a 1% seller fee.
   *   "fee_recipient": "0xA97F337c39cccE66adfeCB2BF99C1DdC54C2D721" # Where seller fees will be paid to.
   * }
   */
  function contractURI() external view returns (string memory);
}