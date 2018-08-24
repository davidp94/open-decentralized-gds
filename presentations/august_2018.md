# dGDS - Open Decentralized GDS

NOTE: DRAFT

# Smart contracts
## Tokens
### Membership
- ERC20 Token
- Non transferrable
### Stablecoin (eg. Dai)
- 1 Dai = 1$  ( see https://github.com/makerdao/docs/blob/master/Dai.md )
- In order to pay for flights
- and a lot more.
### Loyalty Token
- Given when you book flight and conclude a flight
- when you pay at Airline partners
- when customer visits a Retail Airline Shop w/ Retail Shop Customer Tracking by IoT
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
# Extensions
# Technology Stack Summary
- Ethereum, Solidity, React, dApp
- Dev tools : Ganache, Truffle
