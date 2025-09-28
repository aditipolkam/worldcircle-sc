// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WorldCircle {
    struct Person {
        string worldId;        // external-facing identifier (string)
        string name;
        string bio;
        string location;
        string company;
        bool isSelfVerified;
    }

    struct Event {
        uint256 id;
        string name;
        string about;
        string date;
        string venue;
        address creator;
    }

    // worldId (string hash → address mapping) not used directly
    // we’ll key people by `address` to keep things consistent
    mapping(address => Person) public people;

    // eventId => Event
    mapping(uint256 => Event) public events;

    // eventId => list of participants (addresses)
    mapping(uint256 => address[]) public eventParticipants;

    // connections: person => (eventId => list of connections)
    mapping(address => mapping(uint256 => address[])) private connections;

    // all connections of a person (not event-specific)
    mapping(address => address[]) private allConnections;

    uint256 private nextEventId;

    /* ------------------------ PERSON LOGIC ------------------------ */

    function registerPerson(
        string calldata worldId,
        string calldata name,
        string calldata bio,
        string calldata location,
        string calldata company
    ) external {
        require(bytes(people[msg.sender].worldId).length == 0, "Person already registered");

        people[msg.sender] = Person({
            worldId: worldId,
            name: name,
            bio: bio,
            location: location,
            company: company,
            isSelfVerified: false
        });
    }

    function selfVerify() external {
        require(bytes(people[msg.sender].worldId).length > 0, "Not registered");
        people[msg.sender].isSelfVerified = true;
    }

    /* ------------------------ EVENT LOGIC ------------------------ */

    function createEvent(
        string calldata name,
        string calldata about,
        string calldata date,
        string calldata venue
    ) external returns (uint256) {
        uint256 eventId = nextEventId++;
        events[eventId] = Event({
            id: eventId,
            name: name,
            about: about,
            date: date,
            venue: venue,
            creator: msg.sender
        });
        return eventId;
    }

    function registerForEvent(uint256 eventId) external {
        require(bytes(people[msg.sender].worldId).length > 0, "Not registered");
        require(events[eventId].creator != address(0), "Event not found");

        eventParticipants[eventId].push(msg.sender);
    }

    /* ------------------------ CONNECTIONS LOGIC ------------------------ */

    function addConnection(address otherPerson, uint256 eventId) external {
        require(bytes(people[msg.sender].worldId).length > 0, "You are not registered");
        require(bytes(people[otherPerson].worldId).length > 0, "Other not registered");
        require(events[eventId].creator != address(0), "Event not found");
        require(msg.sender != otherPerson, "Cannot connect to yourself");

        // Add connection event-wise
        connections[msg.sender][eventId].push(otherPerson);
        connections[otherPerson][eventId].push(msg.sender);

        // Add to all connections if not already present
        if (!_isAlreadyConnected(msg.sender, otherPerson)) {
            allConnections[msg.sender].push(otherPerson);
            allConnections[otherPerson].push(msg.sender);
        }
    }

    function getConnections(address person) external view returns (address[] memory) {
        return allConnections[person];
    }

    function getConnectionsByEvent(address person, uint256 eventId) external view returns (address[] memory) {
        return connections[person][eventId];
    }

    function getEventParticipants(uint256 eventId) external view returns (address[] memory) {
        return eventParticipants[eventId];
    }

    /* ------------------------ HELPERS ------------------------ */

    function _isAlreadyConnected(address person, address other) internal view returns (bool) {
        address[] memory conns = allConnections[person];
        for (uint256 i = 0; i < conns.length; i++) {
            if (conns[i] == other) return true;
        }
        return false;
    }
}
