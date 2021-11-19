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
  deallocateAll: Function;
  makeOffer: Function;
  mint: Function;
  payAndMint: Function;
  register: Function;
  registerToCreator: Function;
  burn: Function;
  delist: Function;
  list: Function;
};