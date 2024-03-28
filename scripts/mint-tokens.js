#!/usr/bin/env node

const { Web3 } = require('web3')
const fs = require('fs')

const web3 = new Web3('http://localhost:8545')

const filePath = process.argv[2]
const signerAccount = process.argv[3]
const receiverAccount = process.argv[4]
const nTokens = process.argv[5]

if (!filePath || !receiverAccount || !nTokens || !signerAccount) {
  console.log('Usage: mint-tokens.js <token-hardhat-deploy-json> <signer-account> <receiver-account> <token-ammount>')
  process.exit(1)
}

console.log(`Signer account is ${signerAccount}.`)
console.log(`Receiver account is ${receiverAccount}.`)

const deploy = JSON.parse(fs.readFileSync(filePath, 'utf8'));

const abi = deploy.abi;
const address = deploy.address;

console.log(`Read contract ABI. Address is ${address}.`)

const contract = new web3.eth.Contract(abi, address);

async function ensureEthBalance(account) {
  const balance = await web3.eth.getBalance(account)
  if (parseInt(balance) == 0) {
    console.log(`Account ${account} has no Ether. Sending 1 Ether.`)
    await web3.eth.sendTransaction({ from: signerAccount, to: account, value: web3.utils.toWei('1', 'ether') })
  }
  console.log(`ETH balance at ${account} is now ${web3.utils.fromWei(await web3.eth.getBalance(account), 'ether')}`)
}

async function mint(account) {
  try {
    console.log(`Minting ${nTokens} tokens to account ${account}`)
    const result = await contract.
      methods.
      mint(account, parseInt(nTokens)).
      send({ from: signerAccount });

    console.log(`CDX balance at ${account} is now ${await contract.methods.balanceOf(account).call()}`)
  } catch (error) {
    console.log(error.message);
  }
}

ensureEthBalance(receiverAccount)
mint(receiverAccount)