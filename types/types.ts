export type TX = { tx: string };

export type MintpressContract = {
  classOf: Function;
  classFilled: Function;
  classSize: Function;
  classSupply: Function;
  classFeeOf: Function;
  classFees: Function;
  classURI: Function;
  exchange: Function;
  lazyMint: Function;
  listingOf: Function;
  ownerOf: Function;
  tokenURI: Function;
  totalSupply: Function;
  allocate: Function;
  deallocate: Function;
  mint: Function;
  register: Function;
  burn: Function;
  delist: Function;
  list: Function;
};