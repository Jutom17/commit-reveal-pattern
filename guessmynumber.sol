pragma solidity ^0.4.23;

contract GuessMyNumber {
    address public house;
    address public guesser;
    bytes32 private housePickHash;
    bytes32 private guesserPickHash;
    uint public housePick;
    uint public guesserPick;
    uint public initialRevealTime;

    modifier isHouse() {
        require(house == msg.sender, "You are not the house.");
        _;
    }
    modifier isGuesser() {
        require(guesser == msg.sender, "You are not the guesser.");
        _;
    }
    modifier isRegistered() {
        require(house == msg.sender || guesser == msg.sender, "You are not registered to play.");
        _;
    }
    modifier isValidInput(uint number) {
        require(number > 0 && number < 11, "The number is not a valid input.");
        _;
    }
    modifier hasPaidEnough(uint amount) {
        require(msg.value == amount, "You did not pay exact amount.");
        _;
    }
    modifier hasBothPartiesSubmitted() {
        require(housePickHash > 0 && guesserPickHash > 0, "Both parties have not submitted number yet.");
        _;
    }
    
    function registerAs(string role) 
        public 
    {
        if (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("house"))) {
            require(house == address(0), "There is already a house player.");
            house = msg.sender;
        }
        if (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("guesser"))) {
            require(guesser == address(0), "There is already a guessor player.");
            guesser = msg.sender;
        }
    }
    
    function pickNumber(uint number, string randomString) 
        public 
        payable
        isHouse
        isValidInput(number)
        hasPaidEnough(1 ether)
    {
        housePickHash = keccak256(abi.encodePacked(number, randomString));
    }
    
    function guessNumber(uint number, string randomString) 
        public
        payable
        isGuesser
        isValidInput(number)
        hasPaidEnough(1 ether)
    {
        guesserPickHash = keccak256(abi.encodePacked(number, randomString));
    }
    
    function reveal(uint number, string randomString) 
        public
        isRegistered
        isValidInput(number)
        hasBothPartiesSubmitted
        returns (bool success)
    {
        if (msg.sender == house) {
            if(keccak256(abi.encodePacked(number, randomString)) == housePickHash) {
                housePick = number;
                startTimer();
                return true;
            }
        } else if (msg.sender == guesser) {
            if(keccak256(abi.encodePacked(number,randomString)) == guesserPickHash) {
                guesserPick = number;
                startTimer();
                return true;
            }
        }
        return false;
    }
    
    function payWinner() 
        public 
        payable
        isRegistered
        returns (bool success)
    {
        require(housePick > 0 || guesserPick > 0, "No one has revealed yet.");
        // check if both have revealed
        if (housePick > 0 && guesserPick > 0) {
            if(housePick == guesserPick) {
                guesser.transfer(address(this).balance);
                return true;
            } else {
                house.transfer(address(this).balance);
                return true;
            }
        } else {
            // If 5 min has passed since initialRevealTime, declare the first party to reveal the winner
            if (initialRevealTime + 300 < now) {
                if (guesserPick > 0) {
                    guesser.transfer(address(this).balance);
                    return true;
                } else {
                    house.transfer(address(this).balance);
                    return true;
                }
            }
        }
        return false;
    }
    
    function startTimer() private {
        // Start only if initialRevealTime has not been set yet
        if (initialRevealTime == 0) {
            if (housePick > 0 || guesserPick > 0) {
                initialRevealTime = now;
            }
        }
    }
    
    // Functions for testing
    function returnTimeNow() 
        public 
        view 
        returns (uint timeNow) 
    {
        return now;
    }
    
    function getBalance() 
        public 
        constant
        returns (uint balance)
    {
        return address(this).balance;
    }
}
