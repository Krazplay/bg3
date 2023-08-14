require 'nokogiri' # Require gem nokogiri to read XML files

# In game folder, Data/Localization/English.pak must be unpacked (LSLib Toolkit for example)
# Then convert Localization\English\english.loca to english.xml
file = File.open('english.xml', "r:UTF-8", &:read)
xml_localization = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# XXX_pak is the folder where I unpacked XXX.pak
file = File.open('E:\BG3_Unpack\Shared_pak\Public\Shared\Levelmaps\LevelMapValues.lsx', "r:UTF-8", &:read)
xml1 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
# Handle if the file doesn't exist in SharedDev
begin
    file = File.open('E:\BG3_Unpack\Shared_pak\Public\SharedDev\Levelmaps\LevelMapValues.lsx', "r:UTF-8", &:read)
    xml2 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
rescue
    xml2= Nokogiri::XML("")
end

# Redirect output to a file instead of the console
stdout = File.new( './LevelMapValues.txt', 'w' )

# Need ClassDescriptions to replace PreferredClassUUID
file = File.open('E:\BG3_Unpack\Shared_pak\Public\Shared\ClassDescriptions\ClassDescriptions.lsx', "r:UTF-8", &:read)
xml3 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
file = File.open('E:\BG3_Unpack\Shared_pak\Public\SharedDev\ClassDescriptions\ClassDescriptions.lsx', "r:UTF-8", &:read)
xml4 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

puts "=====  Parsing start   ====="
puts ""

#########################################
# Filling up classDescription variable for later use
pathx = '//node[@id="ClassDescription"]'
classDescription = {}
(xml3.xpath(pathx)+xml4.xpath(pathx)).each do |item|
    # Store each attribute and its value
    storage = {}
    item.xpath('attribute').each do |attr|
        # If parameter doesn't have a 'value' param, use 'handle' instead
        storage[attr["id"]] = attr["value"] != nil ? attr["value"] : attr["handle"]  
    end
    classDescription[storage["UUID"]] = storage.clone();
end
#########################################

# Parse the localization, create an hash: loca[UID] = human readable text
loca = {}
xml_localization.xpath('/contentList/content').each do |item|
    loca[item["contentuid"]] = item.text
end

# Loop on the interesting nodes of both file
pathx = '//node[@id="LevelMapSeries"]'
data = {} # store all the data because of references (for example ParentUUID references an UUID in the same file)
(xml1.xpath(pathx)+xml2.xpath(pathx)).each do |item|
    # Store each attribute and its value
    storage = {}
    item.xpath('attribute').each do |attr|
        # If parameter doesn't have a 'value' param, use 'handle' instead
        storage[attr["id"]] = attr["value"] != nil ? attr["value"] : attr["handle"]  
    end
    data[storage["UUID"]] = storage.clone();
end

# Display the data
data.each do |uid, storage|
    puts "LevelMapSeries " + storage["Name"]
    storage.each do |key, val|
        case key
        when "Description", "DisplayName"
            puts "    #{key}: #{loca[val]}"
        when "ParentUUID"
            puts "    #{key}: #{data[val]["Name"]}"
        when "PreferredClassUUID"
            puts "    #{key}: #{classDescription[val]["Name"]}"
        else
            puts "    #{key}: #{val}"
        end
    end
    puts ""
end

puts "===== Parsing finished ====="