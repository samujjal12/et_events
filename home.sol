// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title EventTicketing
 * @dev A decentralized event ticketing system that prevents scalping and ensures secure ticket transfers
 */
contract EventTicketing {
    
    struct Event {
        string name;
        uint256 date;
        uint256 ticketPrice;
        uint256 totalTickets;
        uint256 availableTickets;
        address organizer;
        bool isActive;
    }
    
    struct Ticket {
        uint256 eventId;
        address owner;
        bool isUsed;
        uint256 purchaseTime;
    }
    
    mapping(uint256 => Event) public events;
    mapping(uint256 => Ticket) public tickets;
    mapping(uint256 => mapping(address => uint256)) public userTicketCount;
    
    uint256 public eventCounter;
    uint256 public ticketCounter;
    uint256 public constant MAX_TICKETS_PER_USER = 5;
    
    event EventCreated(uint256 indexed eventId, string name, address indexed organizer);
    event TicketPurchased(uint256 indexed ticketId, uint256 indexed eventId, address indexed buyer);
    event TicketTransferred(uint256 indexed ticketId, address indexed from, address indexed to);
    event TicketUsed(uint256 indexed ticketId, uint256 indexed eventId);
    event EventCancelled(uint256 indexed eventId);
    
    modifier onlyOrganizer(uint256 _eventId) {
        require(events[_eventId].organizer == msg.sender, "Only event organizer can perform this action");
        _;
    }
    
    modifier eventExists(uint256 _eventId) {
        require(_eventId < eventCounter, "Event does not exist");
        _;
    }
    
    modifier ticketExists(uint256 _ticketId) {
        require(_ticketId < ticketCounter, "Ticket does not exist");
        _;
    }
    
    /**
     * @dev Create a new event
     * @param _name Event name
     * @param _date Event date (timestamp)
     * @param _ticketPrice Price per ticket in wei
     * @param _totalTickets Total number of tickets available
     */
    function createEvent(
        string memory _name,
        uint256 _date,
        uint256 _ticketPrice,
        uint256 _totalTickets
    ) external {
        require(_date > block.timestamp, "Event date must be in the future");
        require(_totalTickets > 0, "Total tickets must be greater than 0");
        require(_ticketPrice > 0, "Ticket price must be greater than 0");
        
        events[eventCounter] = Event({
            name: _name,
            date: _date,
            ticketPrice: _ticketPrice,
            totalTickets: _totalTickets,
            availableTickets: _totalTickets,
            organizer: msg.sender,
            isActive: true
        });
        
        emit EventCreated(eventCounter, _name, msg.sender);
        eventCounter++;
    }
    
    /**
     * @dev Purchase tickets for an event
     * @param _eventId The event ID to purchase tickets for
     * @param _quantity Number of tickets to purchase
     */
    function buyTickets(uint256 _eventId, uint256 _quantity) external payable eventExists(_eventId) {
        Event storage event_ = events[_eventId];
        
        require(event_.isActive, "Event is not active");
        require(block.timestamp < event_.date, "Event has already occurred");
        require(_quantity > 0, "Quantity must be greater than 0");
        require(_quantity <= event_.availableTickets, "Not enough tickets available");
        require(userTicketCount[_eventId][msg.sender] + _quantity <= MAX_TICKETS_PER_USER, "Exceeds maximum tickets per user");
        require(msg.value == event_.ticketPrice * _quantity, "Incorrect payment amount");
        
        // Transfer payment to organizer
        payable(event_.organizer).transfer(msg.value);
        
        // Create tickets
        for(uint256 i = 0; i < _quantity; i++) {
            tickets[ticketCounter] = Ticket({
                eventId: _eventId,
                owner: msg.sender,
                isUsed: false,
                purchaseTime: block.timestamp
            });
            
            emit TicketPurchased(ticketCounter, _eventId, msg.sender);
            ticketCounter++;
        }
        
        event_.availableTickets -= _quantity;
        userTicketCount[_eventId][msg.sender] += _quantity;
    }
    
    /**
     * @dev Transfer ticket to another address
     * @param _ticketId The ticket ID to transfer
     * @param _to Address to transfer the ticket to
     */
    function transferTicket(uint256 _ticketId, address _to) external ticketExists(_ticketId) {
        Ticket storage ticket = tickets[_ticketId];
        
        require(ticket.owner == msg.sender, "You don't own this ticket");
        require(!ticket.isUsed, "Ticket has already been used");
        require(_to != address(0), "Invalid recipient address");
        require(_to != msg.sender, "Cannot transfer to yourself");
        
        uint256 eventId = ticket.eventId;
        require(block.timestamp < events[eventId].date, "Cannot transfer after event date");
        require(userTicketCount[eventId][_to] < MAX_TICKETS_PER_USER, "Recipient exceeds maximum tickets");
        
        // Update ownership
        userTicketCount[eventId][msg.sender]--;
        userTicketCount[eventId][_to]++;
        ticket.owner = _to;
        
        emit TicketTransferred(_ticketId, msg.sender, _to);
    }
    
    /**
     * @dev Use/redeem a ticket (only by event organizer)
     * @param _ticketId The ticket ID to use
     */
    function useTicket(uint256 _ticketId) external ticketExists(_ticketId) {
        Ticket storage ticket = tickets[_ticketId];
        uint256 eventId = ticket.eventId;
        
        require(events[eventId].organizer == msg.sender, "Only event organizer can use tickets");
        require(!ticket.isUsed, "Ticket has already been used");
        require(events[eventId].isActive, "Event is not active");
        
        ticket.isUsed = true;
        emit TicketUsed(_ticketId, eventId);
    }
    
    /**
     * @dev Cancel an event and refund all tickets
     * @param _eventId The event ID to cancel
     */
    function cancelEvent(uint256 _eventId) external eventExists(_eventId) onlyOrganizer(_eventId) {
        Event storage event_ = events[_eventId];
        require(event_.isActive, "Event is already cancelled");
        require(block.timestamp < event_.date, "Cannot cancel past events");
        
        event_.isActive = false;
        
        // Refund logic would require tracking all ticket holders
        // For simplicity, this marks the event as cancelled
        // In a production system, you'd implement a refund mechanism
        
        emit EventCancelled(_eventId);
    }
    
    // View functions
    function getEvent(uint256 _eventId) external view eventExists(_eventId) returns (Event memory) {
        return events[_eventId];
    }
    
    function getTicket(uint256 _ticketId) external view ticketExists(_ticketId) returns (Ticket memory) {
        return tickets[_ticketId];
    }
    
    function getUserTicketCount(uint256 _eventId, address _user) external view returns (uint256) {
        return userTicketCount[_eventId][_user];
    }
}
