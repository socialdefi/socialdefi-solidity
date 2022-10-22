/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  TakerReceiver,
  TakerReceiverInterface,
} from "../../../contracts/socialfi/TakerReceiver";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "from_",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "takerId_",
        type: "uint256",
      },
    ],
    name: "takerFrom",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export class TakerReceiver__factory {
  static readonly abi = _abi;
  static createInterface(): TakerReceiverInterface {
    return new utils.Interface(_abi) as TakerReceiverInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): TakerReceiver {
    return new Contract(address, _abi, signerOrProvider) as TakerReceiver;
  }
}
