// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { WorldCircle } from "../src/WorldCircle.sol";


contract WorldCircleTest is Test {
    WorldCircle wc;

    // Mock addresses
    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x3);

    function setUp() public {
        wc = new WorldCircle();

        // Register some people from their addresses
        vm.prank(alice);
        wc.registerPerson("alice.world", "Alice", "Bio A", "Pune", "Company A");

        vm.prank(bob);
        wc.registerPerson("bob.world", "Bob", "Bio B", "Delhi", "Company B");

        vm.prank(charlie);
        wc.registerPerson("charlie.world", "Charlie", "Bio C", "Goa", "Company C");
    }

    function testRegisterPerson() public {
        address david = address(0x4);

        vm.prank(david);
        wc.registerPerson("david.world", "David", "Bio D", "Hyd", "Company D");

        (
            string memory worldId,
            string memory name,
            string memory bio,
            string memory location,
            string memory company,
            bool isSelfVerified
        ) = wc.people(david);

        assertEq(worldId, "david.world");
        assertEq(name, "David");
        assertEq(bio, "Bio D");
        assertEq(location, "Hyd");
        assertEq(company, "Company D");
        assertFalse(isSelfVerified);
    }

    function testCreateEvent() public {
        uint256 eventId =
            wc.createEvent("ETHConf", "Biggest Ethereum Conf", "2025-10-01", "Convention Center");

        (uint256 id, string memory name, string memory about, string memory date, string memory venue, address creator) =
            wc.events(eventId);

        assertEq(id, eventId);
        assertEq(name, "ETHConf");
        assertEq(about, "Biggest Ethereum Conf");
        assertEq(date, "2025-10-01");
        assertEq(venue, "Convention Center");
        assertEq(creator, address(this));
    }

    function testRegisterForEvent() public {
        uint256 eventId =
            wc.createEvent("Hackathon", "Build fast", "2025-11-01", "Auditorium");

        vm.prank(alice);
        wc.registerForEvent(eventId);

        vm.prank(bob);
        wc.registerForEvent(eventId);

        address[] memory participants = wc.getEventParticipants(eventId);
        assertEq(participants.length, 2);
        assertEq(participants[0], alice);
        assertEq(participants[1], bob);
    }

    function testAddConnection() public {
        uint256 eventId =
            wc.createEvent("DevCon", "Builders unite", "2025-12-01", "Expo Hall");

        vm.prank(alice);
        wc.registerForEvent(eventId);

        vm.prank(bob);
        wc.registerForEvent(eventId);

        // Alice connects to Bob
        vm.prank(alice);
        wc.addConnection(bob, eventId);

        // Check all connections
        address[] memory aliceConns = wc.getConnections(alice);
        address[] memory bobConns = wc.getConnections(bob);

        assertEq(aliceConns.length, 1);
        assertEq(bobConns.length, 1);
        assertEq(aliceConns[0], bob);
        assertEq(bobConns[0], alice);

        // Check event-wise connections
        address[] memory aliceEventConns = wc.getConnectionsByEvent(alice, eventId);
        assertEq(aliceEventConns.length, 1);
        assertEq(aliceEventConns[0], bob);
    }

    function testCannotConnectToSelf() public {
        uint256 eventId =
            wc.createEvent("Summit", "Networking", "2025-09-30", "Grand Hall");

        vm.prank(alice);
        vm.expectRevert("Cannot connect to yourself");
        wc.addConnection(alice, eventId);
    }

    function testDuplicateConnectionNotAddedTwice() public {
        uint256 eventId =
            wc.createEvent("Meetup", "Community vibes", "2025-10-05", "CoWork Hub");

        vm.startPrank(alice);
        wc.addConnection(bob, eventId);
        wc.addConnection(bob, eventId); // should not duplicate
        vm.stopPrank();

        address[] memory aliceConns = wc.getConnections(alice);
        address[] memory bobConns = wc.getConnections(bob);

        assertEq(aliceConns.length, 1);
        assertEq(bobConns.length, 1);
    }
}
