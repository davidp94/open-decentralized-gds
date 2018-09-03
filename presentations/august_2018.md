# dGDS - Open Decentralized GDS

NOTE: DRAFT

# Smart contracts
## Tokens
### Membership Token
- ERC20 Token
- Non transferrable
### Stablecoin (eg. Dai)
- 1 Dai = 1$  ( see https://github.com/makerdao/docs/blob/master/Dai.md )
- In order to pay for flights
- and a lot more.
### Loyalty Token
- Given when you book flight and conclude a flight
- when you pay at Airline partners
- when customer visits a Retail Airline Shop (eg. KrisShop) w/ Retail Shop Customer Tracking by IoT
## Flight Inventory
- Flight Inventory is managing the flight seats
- It interacts with FlightSeat contracts
- It interacts with Revenue ManagementSystem to retrieve the price
- It interacts with F&B Assets in order to track what F&B came
- It interacts with Loyalty Tokens for rewarding consumers
- It interacts with Stablecoin (Dai) in order to pay with stable asset
- It interacts with ATC/IoT that would track the actual departure and arrival (separation of concerns via ethereum identities)
- The data from the Flight Inventory can be then used to refund the consumer if there has been some delay automatically, and eventually used by some external Insurance contract
### Revenue Management System
- Automatically gives the price given multiple parameters such as Membership token, number of remaining seats, who is the sender
### Flight Seat
- The contract (could be a token) that lets the users manage his flight seat
- Extensions: change it to a mintable token
### F&B Assets
- F&B Assets would be uniquely identified and be interacting with Flight Inventory via IoT
- The consumption of them would be cached by the Airplane via NFC/RFID and then settled on chain
- All these data can be used to do predictive analysis
## Flight Inventories Registry
- Flight Inventories Registry is all **ONE** airline flights inventories
## Consortium of Airline Flights Registry (unlock Consortium Membership Token)
- Then we can link all these Airline to one consortium, that could enable the emission of Consortium Membership Token or discount regarding their RevenueManagementSystem smart contracts
eg. StarAlliance, ...
## Insurance
- It is an external insurance contract that the consumer will contract with, that will read the Flight Inventory Data and have some logic around refund
# Demo & Diagram Flow
- Airline : Deployment of Flight Inventory, Management of FlightSeat, Simple RevenueManagementSystem
- Airline: FlightRegistry to see all flight inventory's
> Consumer : See that on chain, can book using Dai
- InsuranceContract that interacts w/ FlightInventory and w/Consumer for escrow and gives bonus to Consumer
> External Insurance is deployed and is binded to the Flight, if the flight is delayed more than 2 hours, he will give <Consumer> 100Dai, price of insurance is 10Dai.

> Consumer takes it

> Consumer checks in

> Consumer consumes his ticket

> Flight happens

> F&B assets are uniquely identified in the F&B smart contract, and are scanned via NFC via the airplane that shows that they are there

> ATC does tx on chain to give actual departure time

> F&B assets are sold, the NFC chip is destroyed when opening the food, meaning that only wasted food is responding to NFC scan, having statistical data on the flight

> ATC does tx on chain to give actual landing time

> Flight delays more than 2 hours

> Consumer can directly withdraw his 100 Dai from the InsuranceContract

> And the automatic escrow of FlightInventory will refund his ticket accordingly to the length of the flight

> Consumer will get loyalty tokens

- More complex RevenueManagementSystem that checks if sender has AirlineMembershipTokenLevel1
- Consortium Airlines Contract - RevenueManagementSystem that interacts with consortium in order to do more complex price computation
- Consumer pays in retail w/ Loyalty tokens & Dai + Fiat
- Consumer can exchange his Loyalty Tokens to Dai on Decentralized Exchange or exchange for fiat on Kraken/Coinbase...
- IoT Retail rewards consumer when he is in store w/ Loyalty tokens
- IoT Retail create campaign on chain in order to increase frequentation of the retail store
# Extensions
# Technology Stack Summary
- Ethereum, Solidity, React, dApp
- Dev tools : Ganache, Truffle



## Problem statement & Value proposition

Blockchain advantages (Incentivization, Openness)

Open Data to open different markets (Insurance, etc)

Loyalty Tokens that can be exchanged for real money

Linking Data and analyzing the Data easily, predictive analysis

Near-instant settlement of the refund of the consumer

Direct interaction with the consumer

## Differentiation (from what is currently existing)

Application that connects directly to the user and give instant rewards (tokens)

## Core technology / Architecture

WIP: UML

## Roadmap / Go-to-market

TODO

## Team Experience and Skillset

TODO

## Presentation of User Journey of the product

See above.

## Any other relevant element to the idea specifically


## Optional – Video demo, Github link

This link.