/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../../common";

export interface TakerInterface extends utils.Interface {
  functions: {
    "takerByIndex(uint256)": FunctionFragment;
    "takerCallback(uint256,uint256,uint256)": FunctionFragment;
    "takerMetadata(uint256)": FunctionFragment;
    "totalSupplyOfTaker()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "takerByIndex"
      | "takerCallback"
      | "takerMetadata"
      | "totalSupplyOfTaker"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "takerByIndex",
    values: [PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "takerCallback",
    values: [
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "takerMetadata",
    values: [PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "totalSupplyOfTaker",
    values?: undefined
  ): string;

  decodeFunctionResult(
    functionFragment: "takerByIndex",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "takerCallback",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "takerMetadata",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "totalSupplyOfTaker",
    data: BytesLike
  ): Result;

  events: {
    "TakerBurn(address,uint256,uint256,uint256)": EventFragment;
    "TakerMint(address,uint256,uint256,uint256)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "TakerBurn"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TakerMint"): EventFragment;
}

export interface TakerBurnEventObject {
  from_: string;
  tokenId_: BigNumber;
  responseSkuQuantityOrId_: BigNumber;
  responsePriceQuantityOrId_: BigNumber;
}
export type TakerBurnEvent = TypedEvent<
  [string, BigNumber, BigNumber, BigNumber],
  TakerBurnEventObject
>;

export type TakerBurnEventFilter = TypedEventFilter<TakerBurnEvent>;

export interface TakerMintEventObject {
  from_: string;
  tokenId_: BigNumber;
  requestSkuQuantityOrId_: BigNumber;
  requestPriceQuantityOrId_: BigNumber;
}
export type TakerMintEvent = TypedEvent<
  [string, BigNumber, BigNumber, BigNumber],
  TakerMintEventObject
>;

export type TakerMintEventFilter = TypedEventFilter<TakerMintEvent>;

export interface Taker extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: TakerInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    takerByIndex(
      index_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { takerId_: BigNumber }>;

    takerCallback(
      takerId_: PromiseOrValue<BigNumberish>,
      responseSkuQuantityOrId_: PromiseOrValue<BigNumberish>,
      responsePriceQuantityOrId_: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    takerMetadata(
      takerId_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<
      [string, BigNumber, BigNumber, BigNumber] & {
        maker_: string;
        makerId_: BigNumber;
        requestSkuQuantityOrId_: BigNumber;
        requestPriceQuantityOrId_: BigNumber;
      }
    >;

    totalSupplyOfTaker(
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { totalSupply_: BigNumber }>;
  };

  takerByIndex(
    index_: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  takerCallback(
    takerId_: PromiseOrValue<BigNumberish>,
    responseSkuQuantityOrId_: PromiseOrValue<BigNumberish>,
    responsePriceQuantityOrId_: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  takerMetadata(
    takerId_: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<
    [string, BigNumber, BigNumber, BigNumber] & {
      maker_: string;
      makerId_: BigNumber;
      requestSkuQuantityOrId_: BigNumber;
      requestPriceQuantityOrId_: BigNumber;
    }
  >;

  totalSupplyOfTaker(overrides?: CallOverrides): Promise<BigNumber>;

  callStatic: {
    takerByIndex(
      index_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    takerCallback(
      takerId_: PromiseOrValue<BigNumberish>,
      responseSkuQuantityOrId_: PromiseOrValue<BigNumberish>,
      responsePriceQuantityOrId_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<void>;

    takerMetadata(
      takerId_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<
      [string, BigNumber, BigNumber, BigNumber] & {
        maker_: string;
        makerId_: BigNumber;
        requestSkuQuantityOrId_: BigNumber;
        requestPriceQuantityOrId_: BigNumber;
      }
    >;

    totalSupplyOfTaker(overrides?: CallOverrides): Promise<BigNumber>;
  };

  filters: {
    "TakerBurn(address,uint256,uint256,uint256)"(
      from_?: PromiseOrValue<string> | null,
      tokenId_?: PromiseOrValue<BigNumberish> | null,
      responseSkuQuantityOrId_?: null,
      responsePriceQuantityOrId_?: null
    ): TakerBurnEventFilter;
    TakerBurn(
      from_?: PromiseOrValue<string> | null,
      tokenId_?: PromiseOrValue<BigNumberish> | null,
      responseSkuQuantityOrId_?: null,
      responsePriceQuantityOrId_?: null
    ): TakerBurnEventFilter;

    "TakerMint(address,uint256,uint256,uint256)"(
      from_?: PromiseOrValue<string> | null,
      tokenId_?: PromiseOrValue<BigNumberish> | null,
      requestSkuQuantityOrId_?: null,
      requestPriceQuantityOrId_?: null
    ): TakerMintEventFilter;
    TakerMint(
      from_?: PromiseOrValue<string> | null,
      tokenId_?: PromiseOrValue<BigNumberish> | null,
      requestSkuQuantityOrId_?: null,
      requestPriceQuantityOrId_?: null
    ): TakerMintEventFilter;
  };

  estimateGas: {
    takerByIndex(
      index_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    takerCallback(
      takerId_: PromiseOrValue<BigNumberish>,
      responseSkuQuantityOrId_: PromiseOrValue<BigNumberish>,
      responsePriceQuantityOrId_: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    takerMetadata(
      takerId_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    totalSupplyOfTaker(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    takerByIndex(
      index_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    takerCallback(
      takerId_: PromiseOrValue<BigNumberish>,
      responseSkuQuantityOrId_: PromiseOrValue<BigNumberish>,
      responsePriceQuantityOrId_: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    takerMetadata(
      takerId_: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    totalSupplyOfTaker(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
