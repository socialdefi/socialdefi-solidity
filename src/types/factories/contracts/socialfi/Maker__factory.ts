/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { Maker, MakerInterface } from "../../../contracts/socialfi/Maker";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from_",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tokenId_",
        type: "uint256",
      },
    ],
    name: "MakerBurn",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from_",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tokenId_",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "dex_",
        type: "address",
      },
    ],
    name: "MakerMint",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from_",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tokenId_",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "settleSkuQuantityOrId_",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "settlePaymentOrId_",
        type: "uint256",
      },
    ],
    name: "MakerUpdate",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "makerId_",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "to_",
        type: "address",
      },
    ],
    name: "approveDex",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "index_",
        type: "uint256",
      },
    ],
    name: "makerByIndex",
    outputs: [
      {
        internalType: "uint256",
        name: "makerId_",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "makerId_",
        type: "uint256",
      },
    ],
    name: "makerMetadata",
    outputs: [
      {
        components: [
          {
            internalType: "address",
            name: "sku",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "skuQuantityOrId",
            type: "uint256",
          },
          {
            internalType: "address",
            name: "paymentCurrency",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "priceQuantityOrId",
            type: "uint256",
          },
          {
            internalType: "uint128",
            name: "skuType",
            type: "uint128",
          },
          {
            internalType: "uint128",
            name: "paymentCurrencyType",
            type: "uint128",
          },
        ],
        internalType: "struct IMaker.Metadata",
        name: "maker_",
        type: "tuple",
      },
      {
        internalType: "uint256",
        name: "sentSkuQuantityOrId_",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "receivedPaymentQuantityOrId_",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "dex_",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupplyOfMaker",
    outputs: [
      {
        internalType: "uint256",
        name: "totalSupply_",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

export class Maker__factory {
  static readonly abi = _abi;
  static createInterface(): MakerInterface {
    return new utils.Interface(_abi) as MakerInterface;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): Maker {
    return new Contract(address, _abi, signerOrProvider) as Maker;
  }
}
