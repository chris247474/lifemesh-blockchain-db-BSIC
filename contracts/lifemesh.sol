pragma solidity ^0.4.11;

//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./strings.sol";

contract LifeMesh {
    using strings for *;

    /* TODO
    * need to delete records?
    * locker mechanism?
    * change Material.size to string
     */

    // if someone tries to send ether to this contract (not sure if this is right)
    function() {
        revert();
    }

    function DataContract() {
        // init?
    }

    /*struct Properties {//add these into provider, recipient, tx classes for common props?
        uint id;
        string locations;
        string name;
    }*/
    struct Provider {
    uint id; //increment by 1 for every new provider - don't skip numbers
    string name;
    string location;

    //string reputationScore;
    //other properties
    }
    struct Recipient { //will consolidate Provider and Recipient into single User struct if no diff later on
    uint id; //increment by 1 for every new recipient - don't skip numbers
    string name;
    string location;

    //string reputationScore;
    //other properties
    }
    struct Tx {
    uint id; //auto increments by 1 for every new tx - don't skip numbers
    string provider;
    string recipient;
    string location;
    //other properties
    }
    struct Material {
    uint id;
    uint ownerId; //id of provider or recipient
    string ownerName;
    string materialType;
    uint quantity;
    string size;

    /* we'll store these Longitude and Latitude vars in the string format,
        Decimal degrees (DD): 41.40338, 2.17403
     solidity doesn't support floating point values
     primarily used for needs*/
    string long;
    string lat;
    }

    //mapping declarations - change uint to string to store references to main DB instead?
    mapping (uint => Provider) providers;
    mapping (uint => Recipient) recipients;
    mapping (uint => Tx) transactions;
    mapping (uint => Material) needs;
    mapping (uint => Material) offers;

    // these shadow counters are incremented in this code assuming that object.id
    // is incremented by 1 as well (see providerDoesExist, recipientDoesExist, txDoesExist)
    uint public providerCount = 0;
    uint public recipientCount = 0;
    uint public txCount = 0;
    uint public needsCount = 0;
    uint public offersCount = 0;

    // Needs list helpers
    function createNeed(uint ownerid, string ownerName, string materialType, uint quantity, string size, string long, string lat)
    returns (uint needID)
    {
        /*
            :uint ownerid: recipient's uint id, could funciton as 'primary key'
            :string ownerName: owner's string name, could funciton as 'primary key'
            :string materialType: any string value describing resource/material type such as but not limited to 'food', 'blankets', anything - to be catgorized by Wit.ai
            :uint quantity: any positive integer describing the amount of the materialType
            :string size: any string describing any possible size - to be categorized by Wit.ai
            :string long: string represnetation of longitude. format sample - Decimal degrees (DD): 41.40338, 2.17403
            :string long: string represnetation of lattitude. format sample - Decimal degrees (DD): 41.40338, 2.17403
            :return: current index value of 'row' about to be added as previously incremented by needsCount
        */
        if (needDoesExist(needsCount) && recipientDoesExist(ownerid) && isLatLong(long) && isLatLong(lat)) {
            revert();
        }
        needs[needsCount] = Material(needsCount, ownerid, ownerName, materialType, quantity, size, long, lat);
        needID = needsCount;
        needsCount++;
    }
    function getNeedByID(uint index)
    constant returns (uint id, uint ownerId, string ownerName, string materialType, uint quantity, string size, string long, string lat)
    {
        /*
         :uint index: any postive integer representing index position of need in list
         :return: returns all values contained in Material in needs list

         *  contant keywords means func doesn't change any data
            thus can be executed with no tx fee on network
        */
        if (index < needsCount) {
            id = needs[index].id;
            ownerId = needs[index].ownerId;
            ownerName = needs[index].ownerName;
            materialType = needs[index].materialType;
            quantity = needs[index].quantity;
            size = needs[index].size;
            long = needs[index].long;
            lat = needs[index].lat;
        }
    }
    function updateLongbyNeedID(uint index, string newlong) returns (bool success) {
        /*
         :uint index: any positive integer describing the data position in the 'list'
         :string newlong: new longitude string, in the decimal format

         Checks if index is within bounds of currrent needs count and if newlong param follows
         the decimal format for longitude.
         Then after long property is updated, triggers an event that sends out the changed string values

         (int values are sent out as is, due to lack of 'irrelevant markers'
         uint - only positive integers which are all relevant in our implementation)
         */

        if (index > needsCount || !isNeedsZeroPositionInitialized() || !isLatLong(newlong)) {
            success = false;
        } else {
            needs[index].long = newlong;
            success = true;
        }    }
    function updateLatbyNeedID(uint index, string newlat) returns (bool success) {
        /*
         :uint index: any postive integer representing index position of need in list
         :string newlat: any string value representing the new latitude location of the need, in decimal format
         :return: returns true if preconds satisfied, false otherwise
        */
        if (index > needsCount || !isNeedsZeroPositionInitialized() || !isLatLong(newlat)) {
            success = false;
        } else {
            needs[index].lat = newlat;
            success = true;
        }    }
    // if we change ownerid, then we have to change name too since both belong to same owner
    function updateNeedOwnerIDAndNameByID(uint index, uint ownerid, string ownerName) returns (bool success) {
        if (index > needsCount || !isNeedsZeroPositionInitialized()) {
            success = false;
        } else {
            needs[index].ownerId = ownerid;
            needs[index].ownerName = ownerName;
            success = true;
        }    }
    function updateNeedMaterialTypeByID(uint index, string materialType) returns (bool success) {
        if (index > needsCount || !isNeedsZeroPositionInitialized()) {
            success = false;
        } else {
            needs[index].materialType = materialType;
            success = true;
        }    }
    function updateNeedQuantityByID(uint index, uint quantity) returns (bool success) {
        if (index > needsCount || !isNeedsZeroPositionInitialized()) {
            success = false;
        } else {
            needs[index].quantity = quantity;
            success = true;
        }
    }
    function updateNeedSizeByID(uint index, string size) returns (bool success) {
        if (index > needsCount || !isNeedsZeroPositionInitialized()) {
            success = false;
        } else {
            needs[index].size = size;
            success = true;
        }
    }

    // Offers list helpers
    // note: offer location must match need location
    function createOffer(uint ownerid, string ownerName, string materialType, uint quantity, string size, string long, string lat) returns (uint offerID) {
        /*
            :uint ownerid: provider's uint id, could funciton as 'primary key'
            :string ownerName: owner's string name, could funciton as 'primary key'
            :string materialType: any string value describing resource/material type such as but not limited to 'food', 'blankets', anything - to be catgorized by Wit.ai
            :uint quantity: any positive integer describing the amount of the materialType
            :string size: any string describing any possible size - to be categorized by Wit.ai
            :string long: string represnetation of longitude. format sample - Decimal degrees (DD): 41.40338, 2.17403
            :string long: string represnetation of lattitude. format sample - Decimal degrees (DD): 41.40338, 2.17403
            :return: current index value of 'row' about to be added as previously incremented by offersCount
        */
        if (offerDoesExist(offersCount) && providerDoesExist(ownerid) && isLatLong(long) && isLatLong(lat)) {
            revert();
        }
        offers[offersCount] = Material(offersCount, ownerid, ownerName, materialType, quantity, size, long, lat);
        offerID = offersCount;
        offersCount++;
    }
    function getOfferByID(uint index)
    constant returns (uint id, uint ownerId, string ownerName, string materialType, uint quantity, string size, string long, string lat)
    {
        if (index < offersCount) {
            id = offers[index].id;
            ownerId = offers[index].ownerId;
            ownerName = offers[index].ownerName;
            materialType = offers[index].materialType;
            quantity = offers[index].quantity;
            size = offers[index].size;
            long = offers[index].long;
            lat = offers[index].lat;
        }
    }
    // if we change ownerid, then we have to change name too since both belong to same owner
    function updateOfferOwnerIDAndNameByID(uint index, uint ownerid, string ownerName) returns (bool success) {
        if (index > offersCount || !isOffersZeroPositionInitialized()) {
            success = false;
        } else {
            offers[index].ownerId = ownerid;
            offers[index].ownerName = ownerName;
            success = true;
        }
    }
    function updateOfferMaterialTypeByID(uint index, string materialType) returns (bool success) {
        if (index > offersCount || !isOffersZeroPositionInitialized()) {
            success = false;
        } else {
            offers[index].materialType = materialType;
            success = true;
        }
    }
    function updateOfferQuantityByID(uint index, uint quantity) returns (bool success) {
        if (index > offersCount || !isOffersZeroPositionInitialized()) {
            success = false;
        } else {
            offers[index].quantity = quantity;
            success = true;
        }
    }
    function updateOfferSizeByID(uint index, string size) returns (bool success) {
        if (index > offersCount || !isOffersZeroPositionInitialized()) {
            success = false;
        } else {
            offers[index].size = size;
            success = true;
        }
    }
    function updateLatbyOfferID(uint index, string newlat) returns (bool success) {
        if (index > offersCount || !isLatLong(newlat) || !isOffersZeroPositionInitialized()) {
            success = false;
        } else {
            offers[index].lat = newlat;
            success = true;
        }
    }
    function updateLongbyOfferID(uint index, string newlong) returns (bool success) {
        if (index > offersCount || !isLatLong(newlong) || !isOffersZeroPositionInitialized()) {
            success = false;
        } else {
            offers[index].long = newlong;
            success = true;
        }    }

    //Provider helpers
    function createProvider(string name, string location) returns (uint providerID) {
        /*
            :string name: provider's string name, could funciton as 'primary key'
            :string location: any string value describing a place on the globe, ex: Manila, Paris, RUssia
            :return: current index value of 'row' about to be added as previously incremented by providerCount
        */
        if (providerDoesExist(providerCount)) {
            revert();
        }
        providers[providerCount] = Provider(providerCount, name, location);
        providerID = providerCount;
        providerCount++;
    }
    function getProvidersIntIndexArray() constant returns (uint[] provArray) {
        uint[] memory arr = new uint[](providerCount);
        
        for (uint i = 0;i < providerCount;i++) {
            arr[i] = i;
        }

        provArray = arr;
    }
    function getProviderById(uint index)
    constant returns (uint idRet, string name, string location)
    {
        /*for (uint8 i = 0; i<providerCount; i++) {//fetches first unique, prevents duplicates but slower
            if (providers[i].id == id) {
                idRet = providers[i].id;
                name = providers[i].name;
                location = providers[i].location;

                return;
            }
        }*/

        if (index < providerCount) {
            idRet = providers[index].id;
            name = providers[index].name;
            location = providers[index].location;
        }
    }
    function updateProviderName(uint index, string name) returns (bool success) {
        if (index > providerCount || !isProvidersZeroPositionInitialized()) {
            success = false;
        } else {
            providers[index].name = name;
            success = true;
        }    }
    function updateProviderLocation(uint index, string location) returns (bool success) {
        if (index > providerCount || !isProvidersZeroPositionInitialized()) {
            success = false;
        } else {
            providers[index].location = location;
            success = true;
        }    }

    //Recipient helpers
    function createRecipient(string name, string location) returns (uint recipientID) {
        /*
            :string name: recipient's string name, could funciton as 'primary key'
            :string location: any string value describing a place on the globe, ex: Manila, Paris, RUssia
            :return: current index value of 'row' about to be added as previously incremented by recipientCount
        */
        if (recipientDoesExist(recipientCount)) {
            revert();
        }

        recipients[recipientCount] = Recipient(recipientCount, name, location);
        recipientID = recipientCount;
        recipientCount++;
    }
    function getRecipientById(uint index)
    constant returns (uint idRet, string name, string location)
    {
        if (index < recipientCount) {
            idRet = recipients[index].id;
            name = recipients[index].name;
            location = recipients[index].location;
        }
    }
    function getRecipientsIntIndexArray() constant returns (uint[] recipientArray) {
        uint[] memory temp = new uint[](recipientCount);
        
        for (uint i = 0;i < recipientCount;i++) {
            temp[i] = i;
        }

        recipientArray = temp;
    }
    function updateRecipientName(uint index, string name) returns (bool success) {
        if (index > recipientCount || !isRecipientsZeroPositionInitialized()) {
            success = false;
        } else {
            recipients[index].name = name;
            success = true;
        }    }
    function updateRecipientLocation(uint index, string location) returns (bool success) {
        if (index > recipientCount || !isRecipientsZeroPositionInitialized()) {
            success = false;
        } else {
            recipients[index].location = location;
            success = true;
        }    }

    //Tx helpers
    function createTx(uint id, string provider, string recipient, string location) returns (uint txID) {
        /*if (txDoesExist(id)) { // not sure why its not working
            revert();
        }*/
        transactions[txCount] = Tx(txCount, provider, recipient, location);
        txID = txCount;
        txCount++;
    }
    function getTxById(uint index)
    constant returns (uint idRet, string provider, string recipient, string location)
    {
        if (index < txCount) {
            idRet = transactions[index].id;
            provider = transactions[index].provider;
            recipient = transactions[index].recipient;
            location = transactions[index].location;
        }
    }
    function updateTxProvider(uint index, string provider) returns (bool success) {
        if (index > txCount || !isTxZeroPositionInitialized()) {
            success = false;
        } else {
            transactions[index].provider = provider;
            success = true;
        }    }
    function updateTxRecipient(uint index, string recipient) returns (bool success) {
        if (index > txCount || !isTxZeroPositionInitialized()) {
            success = false;
        } else {
            transactions[index].recipient = recipient;
            success = true;
        }    }
    function updateTxLocation(uint index, string location) returns (bool success) {
        if (index > txCount || !isTxZeroPositionInitialized()) {
            success = false;
        } else {
            transactions[index].location = location;
            success = true;
        }    }


    // Utility functions
    function isNeedsZeroPositionInitialized()
    constant returns (bool isInit)
    {
        if (needsCount == 0) {
            isInit = false;
        } else {
            isInit = true;
        }
    }
    function isOffersZeroPositionInitialized()
    constant returns (bool isInit)
    {
        if (offersCount == 0) {
            isInit = false;
        } else {
            isInit = true;
        }
    }
    function isProvidersZeroPositionInitialized()
    constant returns (bool isInit)
    {
        if (providerCount == 0) {
            isInit = false;
        } else {
            isInit = true;
        }
    }
    function isRecipientsZeroPositionInitialized()
    constant returns (bool isInit)
    {
        if (recipientCount == 0) {
            isInit = false;
        } else {
            isInit = true;
        }
    }
    function isTxZeroPositionInitialized()
    constant returns (bool isInit)
    {
        if (txCount == 0) {
            isInit = false;
        } else {
            isInit = true;
        }
    }
    function isLatLong(string input)
    constant returns (bool islatlong)
    {
        /*
        * simply checks if string contains a period to match longitude, latitude decimal format
         */

        // efficient?
        var s = input.toSlice();
        var delim = ".".toSlice();
        var parts = new string[](s.count(delim) + 1);
        if (parts.length > 1) {
            return true;
        }
        return false;
    }
    function createUniqueIDInt()
    constant returns (uint uniqueIDInt)
    {

    }
    function createUniqueIDString()
    constant returns (string uniqueIDString)
    {

    }
    function indexWithinBounds(uint index, uint bound)
    constant returns (bool inBounds)
    {
        //!(recipientID > 0 && recipientID < recipientCount+1)
        if (index >= bound + 1) {
            return true;
        }
        return false;
    }
    function offerDoesExist(uint offerid)
    constant returns (bool offerExists)
    {
        var (id, ownerid, ownerName, materialType, quantity, size, long, lat) = getOfferByID(offerid);

        // checking for valid "primary keys" values on data struct - change if storing IPFS hash references
        if (!indexWithinBounds(id, offersCount) && !indexWithinBounds(ownerid, providerCount) && isEmptyString(ownerName) && isEmptyString(materialType)/* && isLatLong(long) && isLatLong(lat)*/) {
            return false;
        }
        return true;
    }
    function needDoesExist(uint needid)
    constant returns (bool needExists)
    {
        var (id, ownerid, ownerName, materialType, quantity, size, long, lat) = getNeedByID(needid);

        // just to get rid of the unused vars error. doesnt affect constant function tx cost - still free
        quantity = quantity;
        size = size;
        long = long;
        lat = lat;

        // checking for valid "primary keys" values on data struct - change if storing IPFS hash references
        if (!(indexWithinBounds(id, needsCount)) && !(indexWithinBounds(ownerid, providerCount)) && isEmptyString(ownerName) && isEmptyString(materialType)) {
            return false;
        }
        return true;
    }
    function providerDoesExist(uint id)
    constant returns (bool provExists)
    {
        var (providerID, name, location) = getProviderById(id);
        //!(providerID > 0 && providerID < providerCount+1)

        // checking for valid "primary keys" values on data struct - change if storing IPFS hash references
        if (!indexWithinBounds(providerID, providerCount) && isEmptyString(name) && isEmptyString(location)) {
            return false;
        }
        return true;
    }
    function recipientDoesExist(uint id)
    constant returns (bool recExists)
    {
        var (recipientID, name, location) = getRecipientById(id);

        // checking for valid "primary keys" values on data struct - change if storing IPFS hash references
        if (!(indexWithinBounds(recipientID, recipientCount)) && isEmptyString(name) && isEmptyString(location)) {
            return false;
        }
        return true;
    }
    function txDoesExist(uint id)
    constant returns (bool txExists)
    {
        var (txID, provider, recipient, location) = getTxById(id);

        // checking for valid "primary keys" values on data struct - change if storing IPFS hash references
        // I think i have a logic error here - always returns false.
        // Oddly, recipientDoesExist and providerdoesExist (same condition) return correct values
        if (!(txID >= 0 && txID < txCount+1) && isEmptyString(provider) && isEmptyString(recipient) && isEmptyString(location)) {
            return false;
        }
        return true;
    }
    function isEmptyString(string input)
    constant returns (bool empty)
    {
        bytes memory tempEmptyStringTest = bytes(input); // Uses memory
        if (tempEmptyStringTest.length == 0) {
            return true;
        } else {
            return false;
        }
    }
}