// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {Deploy} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe private fundme;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.003 ether; //100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        Deploy deployFundMe = new Deploy();
        fundme = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testminumdollarisfive() public view {
        assertEq(fundme.MINIMUM_USD(), 5);
    }

    function testownerismsgsender() public view {
        // console.log(fundme.i_owner());
        // console.log(address(this));
        assertEq(fundme.getOwner(), msg.sender);
    }
    function testpricefeedversionisaccurate() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // hey,the next line,should revert!
        //assert(this tx fails/reverts)
        fundme.fund();
    }
    function testFundUpdatesFundedDataStructure() public {
        // vm.prank(USER);
        // uint256 converted=fundme.convertToUsd{value: SEND_VALUE}();
        // console.log("converted ",converted);
        vm.prank(USER); // the next TX will be sent by USER
        fundme.fund{value: SEND_VALUE}();
        uint256 ammountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(ammountFunded, SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // the next transaction expect to be reverted(withdraw function) so vm will be ignored cuz it's not transaction
        vm.prank(USER);
        fundme.withdraw();
    }
    function testWithdrawWithSingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;

        uint256 startingFundmeBalance = address(fundme).balance;
        // console.log("staringfundmebalance ", startingFundmeBalance);

        //act
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        //assert
        uint256 endingownerbalance = fundme.getOwner().balance;
        uint256 endingfundmebalance = address(fundme).balance;
        assertEq(endingfundmebalance, 0);
        assertEq(
            startingFundmeBalance + startingOwnerBalance,
            endingownerbalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded{
        uint160 numnberoFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numnberoFunders; i++){
            //vm.prank
            //vm.deal new address
            hoax(address(i),SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
            // fund the fundme
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        // Act
        // uint256 gasStart = gasleft(); use for anvilchain
        // vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd)* tx.gasprice;
        // console.log(gasUsed);

        //Assert
        assert(address(fundme).balance == 0);
        assert(startingFundmeBalance + startingOwnerBalance == fundme.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        uint160 numnberoFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numnberoFunders; i++){
            //vm.prank
            //vm.deal new address
            hoax(address(i),SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
            // fund the fundme
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        // Act
        // uint256 gasStart = gasleft(); use for anvilchain
        // vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundme.getOwner());
        fundme.cheaperWithdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd)* tx.gasprice;
        // console.log(gasUsed);

        //Assert
        assert(address(fundme).balance == 0);
        assert(startingFundmeBalance + startingOwnerBalance == fundme.getOwner().balance);
    }
}
