import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from '@dfinity/agent';
import { getHttpAgent as getStoicAgent, 
        isAgentExpiration as isStoicAgentExpiration,
        tokenLogout as stoicLogout } from './StoicIdentity'

let identityProvider = "http://rwlgt-iiaaa-aaaaa-aaaaa-cai.localhost:8000/";
// let identityProvider = null;
let localhostProvider = !!identityProvider;
let authClient;
let inInitAuthClient = false;
let agent = null;

function isStonic() {
    return window.localStorage.getItem('identity') === "stoic"
}

async function getAuthClient() {
    while (inInitAuthClient) {
        await new Promise(resolve => {
            setTimeout(() => {
                resolve();
            }, 100)
        });
    }
    if (authClient) {
        return authClient;
    }
    inInitAuthClient = true;
    try {
        authClient = await AuthClient.create();
    } catch (e) {
        console.log(e);
    }
    inInitAuthClient = false
    return authClient;
}

async function isAgentExpiration() {
    return new Promise(async (resolve, reject) => {
        if (isStonic()) {
            resolve(await isStoicAgentExpiration())
            return
        }

        await getAuthClient()
        const identity = authClient.getIdentity()
        if (authClient.isAuthenticated() && identity.getDelegation) {
            const nextExpiration = identity.getDelegation().delegations
                                    .map(d => d.delegation.expiration)
                                    .reduce((current, next) => next < current ? next : current);
            const expirationDuration  = nextExpiration - BigInt(Date.now()) * BigInt(1000_000);

            // 120 second
            resolve(expirationDuration < BigInt(120000000000))
        }

        resolve(true)
    })
}

async function getHttpAgent() {
    return new Promise(async (resolve, reject) => {
        if (isStonic()) {
            resolve(await getStoicAgent())
            return
        }

        await getAuthClient()
        const isExpiration = await isAgentExpiration()
        if (!isExpiration) {
            if (agent) {
                resolve(agent)
            }

            agent = new HttpAgent({identity: authClient.getIdentity()})
            if (localhostProvider) {
                await agent.fetchRootKey()
            }
            resolve(agent)
            return
        }

        if (authClient) {
            authClient.login({
                identityProvider,
                maxTimeToLive: BigInt(24 * 3600_000_000_000),
                onSuccess: async () => {
                    let identity = authClient.getIdentity()
                    // store.dispatch('user/setPrincipal', identity.getPrincipal().toString())
                    agent = new HttpAgent({identity: authClient.getIdentity()})
                    if (localhostProvider) {
                        await agent.fetchRootKey()
                    }
                    resolve(agent)
                },
                onError: (e) => {
                    agent = new HttpAgent()
                    reject(agent)
                }
          })
        }
    })
}

async function tokenLogout() {
    if (isStonic()) {
        stoicLogout()
        return
    }

    authClient.logout()
} 

export { getAuthClient, getHttpAgent, isAgentExpiration, tokenLogout };