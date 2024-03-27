#!/usr/bin/env node

const web3 = require('web3');
const fs = require('fs').promises;
const networkId = process.env.NETWORK_ID || '12345';

async function decryptAccount(accountFile) {
  try {
    const contents = await fs.readFile(accountFile, "binary");
    const account = await web3.eth.accounts.decrypt(contents, "");
    return account
  } catch (error) {
    console.log(error.message);
  }
}

async function decryptAllAccounts(keystore) {
  try {
    const files = await fs.readdir(keystore);
    return Promise.all(files.map(keyPath => decryptAccount(`${keystore}/${keyPath}`)));
  } catch (error) {
    console.log(error.message);
  }
}

async function main() {
  const accounts = await decryptAllAccounts(`./networks/${networkId}/data1/keystore`);
  if (process.argv.length < 3) {
    console.log(JSON.stringify(accounts, null, 2))
    return
  }
  
  const account = accounts.filter(account => account.address == process.argv[2])
  if (account.length == 1) {
    console.log(account[0].privateKey)
  } else {
    console.log(`Account ${process.argv[2]} not found.`)
    process.exit(1)
  }
}

main()


