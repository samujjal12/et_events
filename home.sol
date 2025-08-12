// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleEventTicketing {
    
    struct Event {
        string name;
        uint256 ticketPrice;
        uint256 totalTickets;
        uint256 soldTickets;
        address organizer;
        bool exists;
    }
    
    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => uint256)) public ticketBalances;
    
    uint256 public eventCount = 0;
    
    event EventCreated(uint256 indexed eventId, string name, address organizer);
    event TicketPurchased(uint256 indexed eventId, address indexed buyer, uint256 quantity);
    
    modifier eventExists(uint256 _eventId) {
        require(_eventId < eventCount && events[_eventId].exists, "Event does not exist");
        _;
    }
    
    // 1. Create Event
    function createEvent(
        string memory _name, 
        uint256 _ticketPrice, 
        uint256 _totalTickets
    ) external returns (uint256) {
        require(bytes(_name).length > 0, "Event name cannot be empty");
        require(_ticketPrice > 0, "Ticket price must be greater than 0");
        require(_totalTickets > 0, "Total tickets must be greater than 0");
        
        uint256 eventId = eventCount;
        
        events[eventId] = Event({
            name: _name,
            ticketPrice: _ticketPrice,
            totalTickets: _totalTickets,
            soldTickets: 0,
            organizer: msg.sender,
            exists: true
        });
        
        emit EventCreated(eventId, _name, msg.sender);
        eventCount++;
        
        return eventId;
    }
    
    // 2. Buy Tickets
    function buyTickets(uint256 _eventId, uint256 _quantity) external payable eventExists(_eventId) {
        Event storage event_ = events[_eventId];
        
        require(_quantity > 0, "Must buy at least 1 ticket");
        require(_quantity <= 10, "Cannot buy more than 10 tickets at once");
        require(event_.soldTickets + _quantity <= event_.totalTickets, "Not enough tickets available");
        require(msg.value == event_.ticketPrice * _quantity, "Incorrect payment amount");
        
        // Update balances
        ticketBalances[_eventId][msg.sender] += _quantity;
        event_.soldTickets += _quantity;
        
        // Transfer payment to organizer
        (bool success, ) = payable(event_.organizer).call{value: msg.value}("");
        require(success, "Payment transfer failed");
        
        emit TicketPurchased(_eventId, msg.sender, _quantity);
    }
    
    // 3. Get My Ticket Balance
    function getMyTickets(uint256 _eventId) external view eventExists(_eventId) returns (uint256) {
        return ticketBalances[_eventId][msg.sender];
    }
    
    // 4. Get Event Details
    function getEventDetails(uint256 _eventId) external view eventExists(_eventId) returns (
        string memory name,
        uint256 ticketPrice,
        uint256 totalTickets,
        uint256 soldTickets,
        address organizer
    ) {
        Event memory event_ = events[_eventId];
        return (
            event_.name,
            event_.ticketPrice,
            event_.totalTickets,
            event_.soldTickets,
            event_.organizer
        );
    }
    
    // 5. Get Available Tickets
    function getAvailableTickets(uint256 _eventId) external view eventExists(_eventId) returns (uint256) {
        Event memory event_ = events[_eventId];
        return event_.totalTickets - event_.soldTickets;
    }
    
    // Bonus: Get total number of events
    function getTotalEvents() external view returns (uint256) {
        return eventCount;
    }
    
    // Bonus: Check if event exists
    function eventExistsCheck(uint256 _eventId) external view returns (bool) {
        return _eventId < eventCount && events[_eventId].exists;
    }
}
