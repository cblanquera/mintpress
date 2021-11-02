# MultiClass

Native ERC721 token that allows tokens to be categorized in classes.
ERC1155 is very similar to this type of token but the differences is 
how tokens are handled. In ERC1155, a recipient and others could have 
multiple copies of the same token ID. In ERC721, a unique token ID 
could only have one owner and in an ERC721 multi class token a unique 
token ID is simply assigned to a token class.

When comparing the two, ERC1155 token IDs are token classes with no 
unique tokens inside of them. Instead it basically says:

 - `Jane owns 20 of token 1`,
 - `John owns 30 of token 1` and
 - `James owns 10 of token 2`.

If no one else owned tokens, this means that:

 - `token 1 has 2 owners and 50 copies` and
 - `token 2 has 1 owners and 10 copies`.

In an ERC721 multi-class contract using the same example:

 - `Jane owns token 1 to token 20`,
 - `John owns token 21 to token 50` and
 - `John owns token 51 to token 60`.
 - `Token 1 to token 50 are class 1 tokens` and
 - `Token 51 to token 60 are class 2 tokens`.

Based on the above examples ERC1155 can be thought as monopoly money 
and an ERC721 multi-class can be thought as real money with serial 
numbers. Using an ERC721 multi-class made it so much easier to attach 
a decentralized exchange.

## Compatibility

Solidity ^0.8.0

 - Recommended v0.8.9