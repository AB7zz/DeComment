// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract DeThread {
    struct Comment {
        uint256 id;
        string url;
        string comment;
        address userAddress;
        string username;
        int votes;
        address[] upvoters;
        address[] downvoters;
        uint256 parentId;
    }

    struct CommentMetadata {
        uint256 id;
        string url;
    }

    mapping(address => string) public userAccounts;
    mapping(string => address) public usernameToAddress;
    Comment[] public comments;
    CommentMetadata[] public commentsMetadata;

    function createAccount(string memory _username) public returns (bool) {
        require(usernameToAddress[_username] == address(0), "Username already exists");
        address _walletAddress = msg.sender;

        userAccounts[_walletAddress] = _username;
        usernameToAddress[_username] = _walletAddress;
        return true;
    }

    function insertComment(string memory _url, string memory _comment) public returns (bool) {
        uint256 parentId = 0;
        comments.push(Comment(comments.length + 1, _url, _comment, msg.sender, userAccounts[msg.sender], 0, new address[](0), new address[](0), parentId));
        commentsMetadata.push(CommentMetadata(comments.length, _url));
        return true;
    }

    function addReply(uint256 _parentCommentId, string memory _url, string memory _comment) public {
        require(_parentCommentId > 0 && _parentCommentId <= comments.length, "Invalid parent comment ID");

        uint256 parentId = _parentCommentId;
        comments.push(Comment(comments.length + 1, _url, _comment, msg.sender, userAccounts[msg.sender], 0, new address[](0), new address[](0), parentId));
        commentsMetadata.push(CommentMetadata(comments.length, _url));
    }

    function readComments(string memory _url) public view returns (Comment[] memory) {
        uint256 length = comments.length;

        Comment[] memory result = new Comment[](length);
        uint256 commentCount = 0;

        for (uint256 i = 0; i < length; i++) {
            if (keccak256(bytes(comments[i].url)) == keccak256(bytes(_url))) {
                result[commentCount] = Comment({
                    id: comments[i].id,
                    url: comments[i].url,
                    comment: comments[i].comment,
                    userAddress: comments[i].userAddress,
                    username: comments[i].username,
                    votes: comments[i].votes,
                    upvoters: comments[i].upvoters,
                    downvoters: comments[i].downvoters,
                    parentId: comments[i].parentId
                });
                commentCount++;
            }
        }

        return result;
    }


    function upvote(uint256 _commentId) public {
        require(_commentId > 0 && _commentId <= comments.length, "Invalid comment ID");
        require(bytes(userAccounts[msg.sender]).length > 0, "Commenter does not exist");
        require(!isUserInArray(getComment(_commentId).upvoters, msg.sender), "Already upvoted");

        getComment(_commentId).upvoters.push(msg.sender);
        getComment(_commentId).votes++;
    }

    function downvote(uint256 _commentId) public {
        require(_commentId > 0 && _commentId <= comments.length, "Invalid comment ID");
        require(bytes(userAccounts[msg.sender]).length > 0, "Commenter does not exist");
        require(!isUserInArray(getComment(_commentId).downvoters, msg.sender), "Already downvoted");

        getComment(_commentId).downvoters.push(msg.sender);
        getComment(_commentId).votes--;
    }

    function getCommentVotes(uint256 _commentId) public view returns (int) {
        require(_commentId > 0 && _commentId <= comments.length, "Invalid comment ID");
        return getComment(_commentId).votes;
    }

    function getComment(uint256 _commentId) internal view returns (Comment storage) {
        return comments[_commentId - 1];
    }

    function showUserInfo(string memory _username) public view returns (address, int, uint256[] memory) {
        require(usernameToAddress[_username] != address(0), "User does not exist");

        address userAddress = usernameToAddress[_username];
        int userVotes = 0;
        uint256[] memory userCommentIds = new uint256[](comments.length);
        uint256 commentCount = 0;

        for (uint256 i = 0; i < comments.length; i++) {
            if (keccak256(bytes(comments[i].username)) == keccak256(bytes(_username))) {
                userVotes += comments[i].votes;
                userCommentIds[commentCount] = comments[i].id;
                commentCount++;
            }
        }

        // Trim the array to remove empty elements if any
        uint256[] memory trimmedUserCommentIds = new uint256[](commentCount);
        for (uint256 i = 0; i < commentCount; i++) {
            trimmedUserCommentIds[i] = userCommentIds[i];
        }

        return (userAddress, userVotes, trimmedUserCommentIds);
}

    function isUserInArray(address[] memory _array, address _user) internal pure returns (bool) {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i] == _user) {
                return true;
            }
        }
        return false;
    }
}
