import { Actor } from '@dfinity/agent';
import { idlFactory as texas_token_idl, canisterId as texas_token_id } from 'dfx-generated/texas_token';
import { idlFactory as texas_event_idl, canisterId as texas_event_id } from 'dfx-generated/texas_token_event_logger';
import { getHttpAgent, tokenLogout } from "./identity";
import store from '../store'
import { Modal } from "ant-design-vue";
import { divisionBigInt, multipBigInt } from './index'
import {Token, TokenEvent} from '../mock'

const ErrorHandle = () => {
    return
    const modal = Modal.error();
    modal.update({
      closable: false,
      title: 'Error',
      content: 'Login has expired, please log in again ',
      onOk: () => {
        // router.push("/");
      }
    });
}

export default class TokenInfo {
    static Instance = new TokenInfo();
    static TEXAL_TOKEN = "8ca93b50b3d080e0a18d1999c21596cf30b6823d0feb840107192aca972d7fe4"

    constructor() {
        this.isLogin = false
    }

    async login() {
        if (!this.isLogin) {
            // this.agent = await getHttpAgent()
            // this.token = Actor.createActor(texas_token_idl, { agent: this.agent, canisterId: texas_token_id });
            // this.tokenEvent = Actor.createActor(texas_event_idl, { agent: this.agent, canisterId: texas_event_id });
            this.token = new Token()
            this.tokenEvent = new TokenEvent()
            this.token.approve(TokenInfo.TEXAL_TOKEN, BigInt(10000000000000000000))
            this.isLogin = true
        }
      }

    async setTokenInfo() {
        const [name, symbol, decimals, totalMint, createTime, feePercent] = 
        await Promise.all([
            this.token.name(),
            this.token.symbol(),
            this.token.decimals(),
            this.token.totalMint(),
            this.token.createTime(),
            this.token.getFeePercent()
        ])

        this.name = name
        this.symbol = symbol
        this.decimals = 10 ** Number(decimals)
        this.totalMint = totalMint
        this.createTime = createTime
        this.feePercent = feePercent
        // this.name = await this.token.name()
        // this.symbol = await this.token.symbol()
        // this.decimals = 10 ** Number(await this.token.decimals());
        // this.totalMint = await this.token.totalMint() 
        // this.createTime = await this.token.createTime()
        // this.feePercent = await this.token.getFeePercent()
    }

    async getSelfAddress() {
        try {
            return await this.token.addressOf("")
        } catch {
            ErrorHandle()
        }
    }

    async getBalance(address) {
        try {
            return divisionBigInt(await this.token.balanceOf(address), this.decimals)
        } catch {
            ErrorHandle()
        }
    }

    async translate(address, number) {
        try {
            const flag = await this.token.transfer(address, multipBigInt(number, this.decimals))
            store.dispatch('user/setBalance')
            return flag
        } catch {
            ErrorHandle()
        }

    }

    async mint() {
        try {
            const flag = await this.token.mint()
            store.dispatch('user/setBalance')
            return flag
        } catch {
            ErrorHandle()
        } 
    }

    async getTransactions(address) {
        try {
            const result = await this.tokenEvent.getTransactionsOf(address)
            result.forEach(item => {
                item.amount = divisionBigInt(item.amount, this.decimals),
                item.direction = item.to === address
                item.time = new Date(Number(item.timestamp) / 1000000).toLocaleString()
            })
            return result.reverse()
        } catch {
            ErrorHandle()
        }

    }

    async approve(address, amount) {
        try {
            return await this.token.approve(address, multipBigInt(amount, this.decimals))
        } catch {
            ErrorHandle()
        }
    }

    async logout() {
        this.isLogin = false
        tokenLogout()
    }
}

window.token = TokenInfo.Instance;