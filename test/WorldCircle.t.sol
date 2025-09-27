// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/WorldCircle.sol";

contract WorldCircleTest is Test {
    WorldCircle wc;

    // Example worldIds
    uint256 alice = 1;
    uint256 bob = 2;
    uint256 charlie = 3;

    function setUp() public {
        wc = new WorldCircle();

        // Register some people
        wc.registerPerson(alice, "Alice", "Bio A", "Company A");
        wc.registerPerson(bob, "Bob", "Bio B", "Company B");
        wc.registerPerson(charlie, "Charlie", "Bio C", "Company C");
    }

    function testRegisterPerson() public {
        uint256 david = 4;
        wc.registerPerson(david, "David", "Bio D", "Company D");

        (string memory name, string memory bio, string memory company, bool exists) = wc.people(david);

        assertEq(name, "David");
        assertEq(bio, "Bio D");
        assertEq(company, "Company D");
        assertTrue(exists);
    }

    function testCreateEvent() public {
        uint256 eventId = wc.createEvent("ETHConf", "2025-10-01", "Convention Center", "Pune");

        (uint256 id, string memory name, , string memory venue, string memory location, address creator, bool exists) = wc.events(eventId);

        assertEq(id, eventId);
        assertEq(name, "ETHConf");
        assertEq(venue, "Convention Center");
        assertEq(location, "Pune");
        assertEq(creator, address(this));
        assertTrue(exists);
    }

function testRegisterForEvent() public {
    uint256 eventId = wc.createEvent("Hackathon", "2025-11-01", "Auditorium", "Delhi");

    wc.registerForEvent(alice, eventId);
    wc.registerForEvent(bob, eventId);

    uint256[] memory participants = wc.getEventParticipants(eventId);
    assertEq(participants.length, 2);
    assertEq(participants[0], alice);
    assertEq(participants[1], bob);
}

    function testAddConnection() public {
        uint256 eventId = wc.createEvent("DevCon", "2025-12-01", "Expo Hall", "Bangalore");

        wc.registerForEvent(alice, eventId);
        wc.registerForEvent(bob, eventId);

        wc.addConnection(alice, bob, eventId);

        // Check all connections
        uint256[] memory aliceConns = wc.getConnections(alice);
        uint256[] memory bobConns = wc.getConnections(bob);

        assertEq(aliceConns.length, 1);
        assertEq(bobConns.length, 1);
        assertEq(aliceConns[0], bob);
        assertEq(bobConns[0], alice);

        // Check event-wise connections
        uint256[] memory aliceEventConns = wc.getConnectionsByEvent(alice, eventId);
        assertEq(aliceEventConns.length, 1);
        assertEq(aliceEventConns[0], bob);
    }

    function testCannotConnectToSelf() public {
        uint256 eventId = wc.createEvent("Summit", "2025-09-30", "Grand Hall", "Mumbai");

        vm.expectRevert("Cannot connect to yourself");
        wc.addConnection(alice, alice, eventId);
    }

    function testDuplicateConnectionNotAddedTwice() public {
        uint256 eventId = wc.createEvent("Meetup", "2025-10-05", "CoWork Hub", "Goa");

        wc.addConnection(alice, bob, eventId);
        wc.addConnection(alice, bob, eventId); // should not duplicate

        uint256[] memory aliceConns = wc.getConnections(alice);
        uint256[] memory bobConns = wc.getConnections(bob);

        assertEq(aliceConns.length, 1);
        assertEq(bobConns.length, 1);
    }
}
