pragma solidity ^0.4.8;

import "./BokerCommon.sol";
import "./BokerManager.sol";

contract BokerFileData is BokerManaged {
    using SafeMath for uint256;
    using PageUtil for uint256;

    //文件信息
    struct FileInfo {
        address uploader;                       //上传用户地址
        address owner;						    //视频版权归属
        uint256 fileId;						    //文件id
        string ipfsHash;						//IPFS hash        
        string ipfsUrl;						    //IPFS Url
        string aliDnaFileId;			        //阿里视频dna file id
        uint256 createTime;                     //创建时间

        uint256 playCount;						//播放次数
        uint256 playTime;        				//播放总时长
        uint256 userCount;        				//播放用户总数
        mapping(address => uint256) users;	    //播放用户map
    }
    mapping(uint256 => FileInfo) public mapId2File;     //fileId to FileInfo
    uint256[] public fileIds;

    //上传信息
    struct UploadInfo {
        address addrUser;						                //用户地址
        mapping(uint256 => uint256) fileMap;		            //上传文件列表
        uint256[] fileArray;		                            //上传文件列表
    }
    mapping(address => UploadInfo) public mapUser2Files;

    constructor(address addrManager) BokerManaged(addrManager) public {
    }
       
    function addFile(address uploader, address owner, uint256 fileId, string ipfsHash, string ipfsUrl, string aliDnaFileId) public onlyContract {
        FileInfo storage fInfo = mapId2File[fileId];

        if(fInfo.fileId <= 0) {
            fInfo.uploader = uploader;
            fInfo.owner = owner;
            fInfo.fileId = fileId;
            fInfo.ipfsHash = ipfsHash;
            fInfo.ipfsUrl = ipfsUrl;
            fInfo.aliDnaFileId = aliDnaFileId;
            fInfo.createTime = now;
            fileIds.push(fileId);
        }

        addUserFile(uploader, fileId);
    }

    function addUserFile(address uploader, uint256 fileId) public onlyContract {
        UploadInfo storage uInfo = mapUser2Files[uploader];
        uInfo.addrUser = uploader;
        if (uInfo.fileMap[fileId] == 0) {
            uInfo.fileMap[fileId] = now;
            uInfo.fileArray.push(fileId);
        }
    }

    function fileCount() public view returns (uint256) {
        return fileIds.length;
    }
    
    function updateWatch(address user, uint256 fileId, uint256 playTime) public onlyContract {
        FileInfo storage fInfo = mapId2File[fileId];

        //not exists
        if(fInfo.fileId <= 0) {
            return;
        }

        fInfo.playCount = fInfo.playCount.add(1);
        fInfo.playTime = fInfo.playTime.add(playTime);
        if (fInfo.users[user] <= 0) {
            fInfo.userCount = fInfo.userCount.add(1);
        }
        fInfo.users[user] = fInfo.users[user].add(playTime);
    }
    
    function fileOwnerGet(uint256 fileId) public view returns (address) {
        FileInfo storage fInfo = mapId2File[fileId];

        //not exists
        if(fInfo.fileId <= 0) {
            return address(0);
        }

        return fInfo.owner;
    }

    /** @dev Get all files user uploaded.
    * @param user address of user.
    * @param page page number of result.
    * @param pageSize page size of result.
    * @return fileIds file id.
    * @return playCounts play total count.
    * @return playTimes play total time.
    * @return userCounts play total user count.
    * @return createTimes create time.
    */
    function userFilesGet(address user, uint256 page, uint256 pageSize) public view returns (
        uint256[] fileIds, uint256[] playCounts, uint256[] playTimes, uint256[] userCounts, uint256[] createTimes) {
        UploadInfo storage uploadInfo = mapUser2Files[user];

        //not exists
        if(uploadInfo.addrUser == 0) {
            return;
        }

        if(uploadInfo.fileArray.length == 0) {
            return;
        }

        (uint256 start, uint256 end) = uploadInfo.fileArray.length.pageRange(page, pageSize);
        uint256 len = end - start + 1;
        fileIds = new uint256[](len);
        playCounts = new uint256[](len);
        playTimes = new uint256[](len);
        userCounts = new uint256[](len);
        createTimes = new uint256[](len);
        for (uint256 index = start; index <= end; index++) {
            FileInfo storage fInfo = mapId2File[uploadInfo.fileArray[index]];
            fileIds[index-start] = uploadInfo.fileArray[index];
            playCounts[index-start] = fInfo.playCount;
            playTimes[index-start] = fInfo.playTime;
            userCounts[index-start] = fInfo.userCount;
            createTimes[index-start] = fInfo.createTime;
        }
    }
}