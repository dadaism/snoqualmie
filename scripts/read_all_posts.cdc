import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import SocialPost from "../contracts/SocialPost.cdc"

// This script returns an array of all the NFT IDs in an account's collection.

pub fun main(address: Address): [PostData] {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(SocialPost.CollectionPublicPath)
        .borrow<&SocialPost.Collection{SocialPost.PostCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    var rst: [PostData] = []
    for id in collectionRef.getIDs() {
        var postRef = collectionRef.borrowPost(id: id)!
        var postData = PostData()
        postData.id = id
        postData.content = postRef.content
        postData.createdAt = postRef.createdAt
        postData.passportID = postRef.passportID

        rst.append(postData)
    }

    return rst
}

pub struct PostData {
    pub(set) var id: UInt64
    pub(set) var content: String
    pub(set) var createdAt: UFix64
    pub(set) var passportID: UInt64

    init() {
        self.id = 0
        self.content = ""
        self.createdAt = 0.0
        self.passportID = 1
    }
}