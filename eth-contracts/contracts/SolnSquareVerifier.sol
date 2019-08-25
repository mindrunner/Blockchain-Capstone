pragma solidity >=0.4.21 <0.6.0;

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
import "./Verifier.sol";
import "./ERC721Mintable.sol";



// define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is Verifier, LuToken {

    // define a solutions struct that can hold an index & an address
    struct Solution {
        bytes32 index;
        address addr;
        uint256 tokenId;
        bool exist;
    }

    // define an array of the above struct
    mapping (uint256 => Solution) solutions;
    // define a mapping to store unique solutions submitted
    mapping(bytes32 => bool) private uniqueSolutions;

    // Create an event to emit when a solution is added
    event SolutionAdded(bytes32 key, address addr, uint256 tokenId);

    // Create a function to add the solutions to the array and emit the event
    function addSolution(address addr, uint256 tokenId, uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory input ) public {
        bytes32 key = keccak256(abi.encodePacked(a, b, c, input));
        require(!uniqueSolutions[key], "This solution was already used!");
        bool isValidProof = verifyTx(a, b, c, input);
        require(isValidProof, "The provided proof is not valid!");
        Solution memory solution = Solution(key, addr, tokenId, true);
        solutions[tokenId] = solution;
        uniqueSolutions[key] = true;
        emit SolutionAdded(key, addr, tokenId);
    }

    function mint(
        address to,
        uint256 tokenId
    ) public returns (bool) {
        require(solutions[tokenId].exist, "Requires solution has been added for token");
        return super.mint(to, tokenId);
    }

}
