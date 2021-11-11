# ICTexas Beta

![NnsDAO Protocol](https://nnsdao.org/imgs/ec-logo.png)

Welcome to your new Texas project and to the internet computer development community. By default, creating a new project adds this README and some template files to your project directory. You can edit these template files to customize your project and to include your own code to speed up the development cycle.

To get started, you might want to explore the project directory structure and the default configuration file. Working with this project in your development environment will not affect any production deployment or identity tokens.

## Quick start to experience the game

[Live ICTexas](https://lm5fh-ayaaa-aaaah-aafua-cai.raw.ic0.app)

[How to try out Texas Hold'em on IC and get NFTs?](https://nnsdao.substack.com/p/how-to-try-out-texas-holdem-on-ic)

## Quick Start Developer

To learn more before you start working with Texas, see the following documentation available online:

- [Quick Start](https://sdk.dfinity.org/docs/quickstart/quickstart-intro.html)
- [SDK Developer Tools](https://sdk.dfinity.org/docs/developers-guide/sdk-guide.html)
- [Motoko Programming Language Guide](https://sdk.dfinity.org/docs/language-guide/motoko.html)
- [Motoko Language Quick Reference](https://sdk.dfinity.org/docs/language-guide/language-manual.html)

If you want to start working on your project right away, you might want to try the following commands:

### Install DFX

- DFX_VERSION=0.7.2 sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"

- cd ICTexas-UI

- npm install

- dfx start

- dfx deploy

- dfx build

- npm run serve

### deploy IC Network

- sudo dfx identity get-principal

- Authorize the local controller to each canister through II.

- sudo dfx deploy --no-wallet --network ic

## About NnsDAO Protocol

Nnsdao is simply a boundaryless autonomous organization. that provides some basic modular programmable services for building the world of DAOn.

### COMMUNITY

[Offical Website](https://nnsdao.org/)

[Twitter](https://twitter.com/NnsDaos)

[Telegram](https://t.me/NnsDaos)

[Distrikt](https://az5sd-cqaaa-aaaae-aaarq-cai.ic0.app/u/nnsdaos)

### Fix bug

+ [webpack-cli version fix](https://github.com/webpack/webpack-cli/issues/2990)
+ Update package.json , I am not using webpack-cli 4.9.0. I am using webpack-cli 4.8.0