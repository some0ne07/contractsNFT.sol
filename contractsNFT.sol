pragma solidity >=0.4.21 <0.8.0;
pragma abicoder v2;

import "./ERC721.sol";

contract RaeNFT is ERC721 {

    string public collectionName;
    string public collectionNameSymbol;
    uint256 public raeCounter;

    struct Rae {
        uint256 tokenId;
        string tokenName;
        string tokenURI;
        address payable mintedBy;
        address payable currentOwner;
        address payable previousOwner;
        address payable initialOwner;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
    }

    mapping(uint256 => Rae) public allRaeNFT;
    mapping(string => bool) public tokenNameExists;
    mapping(string => bool) public tokenURIExists;

    constructor() ERC721("Rae NFT Collection", "RAE") {
        collectionName = name();
        collectionNameSymbol = symbol();
    }

    function mintRae(string memory _name, string memory _tokenURI, uint256 _price) external {
        require(msg.sender != address(0));
        raeCounter ++;
        require(!_exists(raeCounter));

        require(!tokenURIExists[_tokenURI]);
        require(!tokenNameExists[_name]);

        _mint(msg.sender, raeCounter);
        _setTokenURI(raeCounter, _tokenURI);

        tokenURIExists[_tokenURI] = true;
        tokenNameExists[_name] = true;

        Rae memory newRae = Rae(
            raeCounter,
            _name,
            _tokenURI,
            msg.sender,
            msg.sender,
            address(0),
            msg.sender,
            _price,
            0,
            true);
        allRaeNFT[raeCounter] = newRae;
    }

    function getTokenOwner(uint256 _tokenId) public view returns(address) {
        address _tokenOwner = ownerOf(_tokenId);
        return _tokenOwner;
    }

    function getTokenMetaData(uint _tokenId) public view returns(string memory) {
        string memory tokenMetaData = tokenURI(_tokenId);
        return tokenMetaData;
    }

    function getNumberOfTokensMinted() public view returns(uint256) {
        uint256 totalNumberOfTokensMinted = totalSupply();
        return totalNumberOfTokensMinted;
    }

    function getTotalNumberOfTokensOwnedByAnAddress(address _owner) public view returns(uint256) {
        uint256 totalNumberOfTokensOwned = balanceOf(_owner);
        return totalNumberOfTokensOwned;
    }

    function getTokenExists(uint256 _tokenId) public view returns(bool) {
        bool tokenExists = _exists(_tokenId);
        return tokenExists;
    }

    function buyToken(uint256 _tokenId) public payable {
        require(msg.sender != address(0));
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner != address(0));
        require(tokenOwner != msg.sender);
        Rae memory raenft = allRaeNFT[_tokenId];
        require(msg.value >= raenft.price);
        require(raenft.forSale);
        _transfer(tokenOwner, msg.sender, _tokenId);
        address payable sendTo = raenft.currentOwner;
        sendTo.transfer(((msg.value)*9)/10);

        address payable sendRoyalty = raenft.initialOwner;
        sendRoyalty.transfer(((msg.value)*1)/10);
        
        raenft.previousOwner = raenft.currentOwner;
        raenft.currentOwner = msg.sender;
        raenft.numberOfTransfers += 1;
        allRaeNFT[_tokenId] = raenft;
    }

    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        require(msg.sender != address(0));
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == msg.sender);
        Rae memory raenft = allRaeNFT[_tokenId];
        raenft.price = _newPrice;
        allRaeNFT[_tokenId] = raenft;
    }

    function toggleForSale(uint256 _tokenId) public {
        require(msg.sender != address(0));
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == msg.sender);
        Rae memory raenft = allRaeNFT[_tokenId];
        if(raenft.forSale) {
            raenft.forSale = false;
        } else {
            raenft.forSale = true;
        }
        allRaeNFT[_tokenId] = raenft;
    }
}
