import { drizzleConnect } from 'drizzle-react'
import React, { Component } from 'react'
import PropTypes from 'prop-types'

import { ContractData, ContractForm } from 'drizzle-react-components';

class Assets extends Component {
    constructor(props, context) {
        super(props)
        this.props = props;
        this.contracts = context.drizzle.contracts;
        this.dataKey = context.drizzle.contracts.FBAssets.methods.getAssetCount.cacheCall();

        this.sellAsset = this.sellAsset.bind(this)
        this.throwAsset = this.throwAsset.bind(this)

    }

    sellAsset = (_index) => {
        console.log('sell asset', _index)
        this.contracts.FBAssets.methods.sellAsset.cacheSend(_index);
    }

    sellAssetButton = (_index) => {
        return (<button key={`sell-${_index}`} className="pure-button" type="button" onClick={() => this.sellAsset(_index)}>Sell</button>)
    }

    throwAsset = (_index) => {
        console.log('throwAsset', _index)
        this.contracts.FBAssets.methods.throwAsset.cacheSend(_index);
    }

    throwAssetButton = (_index) => {
        return (<button key={`throw-${_index}`} className="pure-button" type="button" onClick={() => this.throwAsset(_index)}>Throw</button>)
    }

    render() {




        if (!this.props.contracts.FBAssets.initialized) {
            return (
                <span>Initializing...</span>
            )
        }
        if (!(this.dataKey in this.props.contracts.FBAssets.getAssetCount)) {
            return (
                <span>Fetching...</span>
            )
        }
        console.log(this.assetCount)
        this.assetCount = this.props.contracts.FBAssets.getAssetCount[this.dataKey].value

        console.log(this.assetCount)

        let assetList = [];
        for (let i = this.assetCount - 1; i >= 0; i--) {
            assetList.push(
                <li key={i}>
                    <h4>ID: {i}</h4>
                    <ContractData contract="FBAssets" method="getAsset" methodArgs={[i]} />
                    {this.sellAssetButton(i)}
                    {this.throwAssetButton(i)}

                </li>)
        }

        console.log(assetList)

        return <ul>{assetList}</ul>
    }
}


Assets.contextTypes = {
    drizzle: PropTypes.object
}

/*
 * Export connected component.
 */

const mapStateToProps = state => {
    return {
        contracts: state.contracts
    }
}

export default drizzleConnect(Assets, mapStateToProps)