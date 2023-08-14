require 'nokogiri' # Require gem nokogiri to read XML files

# In game folder, Data/Localization/English.pak must be unpacked (LSLib Toolkit for example)
# Then convert Localization\English\english.loca to english.xml
file = File.open('english.xml', "r:UTF-8", &:read)
xml_localization = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# XXX_pak is the folder where I unpacked XXX.pak
# Shared_pak\Public\Shared\ClassDescriptions\ClassDescriptions.lsx
file = File.open('E:\BG3_Unpack\Shared_pak\Public\Shared\ClassDescriptions\ClassDescriptions.lsx', "r:UTF-8", &:read)
xml1 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
# Shared_pak\Public\SharedDev\ClassDescriptions\ClassDescriptions.lsx
file = File.open('E:\BG3_Unpack\Shared_pak\Public\SharedDev\ClassDescriptions\ClassDescriptions.lsx', "r:UTF-8", &:read)
xml2 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# Redirect output to a file instead of the console
$stdout = File.new( './ClassDescriptions.txt', 'w' )

puts "=====  Parsing start   ====="
puts ""

# Parse the localization, create an hash: loca[UID] = human readable text
loca = {}
xml_localization.xpath('/contentList/content').each do |item|
    loca[item["contentuid"]] = item.text
end

# Loop on ClassDescription of both file
(xml1.xpath('//node[@id="ClassDescription"]')+xml2.xpath('//node[@id="ClassDescription"]')).each do |item|
    # Store each attribute and its value
    storage = {}
    item.xpath('attribute').each do |attr|
        # If parameter doesn't have a 'value' param, use 'handle' instead
        storage[attr["id"]] = attr["value"] != nil ? attr["value"] : attr["handle"]  
    end

    # Ability ID to text
    ability = ["", "Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"]
    # Display the data
    puts "Class " + loca[storage["DisplayName"]]
    storage.each do |key, val|
        case key
        when "Description", "DisplayName"
            puts "    #{key}: #{loca[val]}"
        when "PrimaryAbility", "SpellCastingAbility"
            puts "    #{key}: #{val} (#{ability[val.to_i]})"
        else
            puts "    #{key}: #{val}"
        end
    end
    puts ""
end

puts "===== Parsing finished ====="