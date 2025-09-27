// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WorldCircle {
    struct Person {
        string name;
        string bio;
        string company;
        bool exists;
    }

    struct Event {
        uint256 id;
        string name;
        string date;
        string venue;
        string location;
        address creator;
        bool exists;
    }

    // worldId => Person
    mapping(uint256 => Person) public people;

    // eventId => Event
    mapping(uint256 => Event) public events;

    // eventId => list of participants
    mapping(uint256 => uint256[]) public eventParticipants;

    // connections: worldId => (eventId => list of connections)
    mapping(uint256 => mapping(uint256 => uint256[])) private connections;

    // all connections of a person (not event-specific)
    mapping(uint256 => uint256[]) private allConnections;

    uint256 private nextEventId;

    /* ------------------------ PERSON LOGIC ------------------------ */

    function registerPerson(
        uint256 worldId,
        string calldata name,
        string calldata bio,
        string calldata company
    ) external {
        require(!people[worldId].exists, "Person already registered");

        people[worldId] = Person({
            name: name,
            bio: bio,
            company: company,
            exists: true
        });
    }

    /* ------------------------ EVENT LOGIC ------------------------ */

    function createEvent(
        string calldata name,
        string calldata date,
        string calldata venue,
        string calldata location
    ) external returns (uint256) {
        uint256 eventId = nextEventId++;
        events[eventId] = Event({
            id: eventId,
            name: name,
            date: date,
            venue: venue,
            location: location,
            creator: msg.sender,
            exists: true
        });
        return eventId;
    }

    function registerForEvent(uint256 worldId, uint256 eventId) external {
        require(people[worldId].exists, "Person not registered");
        require(events[eventId].exists, "Event not found");

        eventParticipants[eventId].push(worldId);
    }

    /* ------------------------ CONNECTIONS LOGIC ------------------------ */

    function addConnection(
        uint256 yourWorldId,
        uint256 otherWorldId,
        uint256 eventId
    ) external {
        require(people[yourWorldId].exists, "You are not registered");
        require(people[otherWorldId].exists, "Other person not registered");
        require(events[eventId].exists, "Event not found");
        require(yourWorldId != otherWorldId, "Cannot connect to yourself");

        // Add connection event-wise
        connections[yourWorldId][eventId].push(otherWorldId);
        connections[otherWorldId][eventId].push(yourWorldId);

        // Add to all connections if not already present
        if (!_isAlreadyConnected(yourWorldId, otherWorldId)) {
            allConnections[yourWorldId].push(otherWorldId);
            allConnections[otherWorldId].push(yourWorldId);
        }
    }

    function getConnections(uint256 worldId)
        external
        view
        returns (uint256[] memory)
    {
        return allConnections[worldId];
    }

    function getConnectionsByEvent(uint256 worldId, uint256 eventId)
        external
        view
        returns (uint256[] memory)
    {
        return connections[worldId][eventId];
    }

		function getEventParticipants(uint256 eventId) external view returns (uint256[] memory) {
    	return eventParticipants[eventId];
		}

    /* ------------------------ HELPERS ------------------------ */

    function _isAlreadyConnected(uint256 worldId, uint256 otherWorldId)
        internal
        view
        returns (bool)
    {
        uint256[] memory conns = allConnections[worldId];
        for (uint256 i = 0; i < conns.length; i++) {
            if (conns[i] == otherWorldId) return true;
        }
        return false;
    }
}
