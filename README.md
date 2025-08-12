# et_events

# Event - Simple Event Ticketing DApp

## Project Description

A simple blockchain-based event ticketing system that allows organizers to create events and sell tickets directly to users. No middlemen, no complex features - just basic ticket buying and selling on the blockchain.

## Project Vision

Create the simplest possible event ticketing system on blockchain that:
- Lets anyone create events
- Allows direct ticket purchases
- Ensures transparent transactions
- Eliminates ticket fraud

## Key Features

### 🎫 **Create Events**
- Anyone can create an event with name, price, and total tickets
- Simple one-step process

### 💰 **Buy Tickets**
- Pay with ETH directly to event organizer
- Automatic ticket balance tracking
- Real-time availability checking

### 📊 **Check Information**
- View your ticket balance for any event
- See event details (name, price, tickets sold)
- Check how many tickets are still available

### 🔒 **Security**
- Payments go directly to organizers
- Can't buy more tickets than available
- All transactions recorded on blockchain

## Future Scope

### Short Term (1-3 months)
- Add ticket transfer between users
- Event cancellation with refunds
- Maximum tickets per user limit

### Medium Term (3-6 months)
- Web interface for easy interaction
- Event categories and search
- Ticket validation system

### Long Term (6+ months)
- Mobile app
- NFT tickets
- Multiple payment tokens

## Contract Functions

1. **`createEvent(name, price, totalTickets)`** - Create a new event
2. **`buyTickets(eventId, quantity)`** - Buy tickets with ETH
3. **`getMyTickets(eventId)`** - Check your ticket balance
4. **`getEvent(eventId)`** - View event details
5. **`getAvailableTickets(eventId)`** - See remaining tickets

## How to Use

1. **Deploy** the contract to Ethereum network
2. **Create Event**: Call `createEvent("Concert", 1000000000000000000, 100)` (1 ETH per ticket, 100 total)
3. **Buy Tickets**: Call `buyTickets(0, 2)` with 2 ETH to buy 2 tickets for event 0
4. **Check Balance**: Call `getMyTickets(0)` to see your tickets

Contract details : 0xd9145CCE52D386f254917e481eB44e9943F39138

<img width="1914" height="945" alt="image" src="https://github.com/user-attachments/assets/68456b50-c8c4-4265-a9c1-0fd4f3262848" />
