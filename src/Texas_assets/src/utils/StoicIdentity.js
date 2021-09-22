import { StoicIdentity } from "ic-stoic-identity";
import { HttpAgent } from '@dfinity/agent';

let agent = null;

async function isAgentExpiration() {
    return new Promise(async (resolve, reject) => {
        resolve(await StoicIdentity.load() === false)
    })
}

async function getHttpAgent() {
    return new Promise(async (resolve, reject) => {
        if (agent) {
            resolve(agent)
            return 
        }

        let identity = await StoicIdentity.load()
        if (identity === false) {
            identity = await StoicIdentity.connect();
        }
         
        agent = new HttpAgent({ identity }) 
        resolve(agent) 
    })
}

async function tokenLogout() {
    StoicIdentity.disconnect()
} 

window.sss = StoicIdentity

export { getHttpAgent, isAgentExpiration, tokenLogout };