// import ComplexStorage from './../build/contracts/ComplexStorage.json'
// import SimpleStorage from './../build/contracts/SimpleStorage.json'
// import TutorialToken from './../build/contracts/TutorialToken.json'
import FBAssets from '../build_contracts/FBAssets.json';

const drizzleOptions = {
  web3: {
    block: false,
    fallback: {
      type: 'ws',
      url: 'ws://127.0.0.1:8545'
    }
  },
  contracts: [
    FBAssets
    // ComplexStorage,
    // SimpleStorage,
    // TutorialToken
  ],
  events: {
    // SimpleStorage: ['StorageSet']
  },
  polls: {
    accounts: 1500
  }
}

export default drizzleOptions