import React, { Component } from 'react'
import { AccountData, ContractData, ContractForm } from 'drizzle-react-components'
import logo from '../../logo.png'

import Assets from '../Assets/Assets';

class Home extends Component {
  render() {
    return (
      <main className="container">
        <div className="pure-g">
          <div className="pure-u-1-1 header">
            <img src={logo} alt="coffee-logo" />
            <h1>Food & Beverages Contract Manager</h1>
            {/* <p>Examples of how to get started with Drizzle in various situations.</p> */}

            <br /><br />
          </div>

          <div className="pure-u-1-1">
            <h3>Active Account</h3>
            <AccountData accountIndex="0" units="ether" precision="2" />
            <br /><br />
            <h2>Manager of this Contract</h2>
            <ContractData contract="FBAssets" method="owner" />
            <h2>FlightInventory of this Contract</h2>
            <ContractData contract="FBAssets" method="flightInventory" />
            <ContractForm contract="FBAssets" method="setFlightInventory" />
          </div>

          <div className="pure-u-1-1">
            <h2>List of food and beverages</h2>
            <p>
              Tracked Assets :
              <ContractData contract="FBAssets" method="getAssetCount" methodArgs={[]} />
            </p>
            <h3>Add an asset</h3>
            <ContractForm contract="FBAssets" method="addAsset" labels={['SKU', 'Add an asset']} />
            {/* <p><strong>Stored Value</strong>: <ContractData contract="FBAssets" method="getAsset" methodArgs={[0]} /></p> */}
            <br />
            <h3>List</h3>
            <ul>
            <Assets />
              
            </ul>
            <br /><br />
          </div>

          {/* 
          <div className="pure-u-1-1">
            <h2>SimpleStorage</h2>
            <p>This shows a simple ContractData component with no arguments, along with a form to set its value.</p>
            <p><strong>Stored Value</strong>: <ContractData contract="SimpleStorage" method="storedData" /></p>
            <ContractForm contract="SimpleStorage" method="set" />

            <br/><br/>
          </div>

          <div className="pure-u-1-1">
            <h2>TutorialToken</h2>
            <p>Here we have a form with custom, friendly labels. Also note the token symbol will not display a loading indicator. We've suppressed it with the <code>hideIndicator</code> prop because we know this variable is constant.</p>
            <p><strong>Total Supply</strong>: <ContractData contract="TutorialToken" method="totalSupply" methodArgs={[{from: this.props.accounts[0]}]} /> <ContractData contract="TutorialToken" method="symbol" hideIndicator /></p>
            <p><strong>My Balance</strong>: <ContractData contract="TutorialToken" method="balanceOf" methodArgs={[this.props.accounts[0]]} /></p>
            <h3>Send Tokens</h3>
            <ContractForm contract="TutorialToken" method="transfer" labels={['To Address', 'Amount to Send']} />

            <br/><br/>
          </div>

          <div className="pure-u-1-1">
            <h2>ComplexStorage</h2>
            <p>Finally this contract shows data types with additional considerations. Note in the code the strings below are converted from bytes to UTF-8 strings and the device data struct is iterated as a list.</p>
            <p><strong>String 1</strong>: <ContractData contract="ComplexStorage" method="string1" toUtf8 /></p>
            <p><strong>String 2</strong>: <ContractData contract="ComplexStorage" method="string2" toUtf8 /></p>
            <strong>Single Device Data</strong>: <ContractData contract="ComplexStorage" method="singleDD" />

            <br/><br/>
          </div> */}
        </div>
      </main>
    )
  }
}

export default Home